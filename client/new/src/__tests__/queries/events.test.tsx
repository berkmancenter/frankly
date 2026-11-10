// @vitest-environment jsdom
import { act, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import type { NewEventInput } from "@/api/types";
import { community, event, me, user } from "@/__tests__/support/fixtures";
import { useCommunity, useMyCommunities } from "@/queries/communities";
import {
  useAllEvents,
  useCreateEvent,
  useEventParticipants,
  useUpcomingEvents,
} from "@/queries/events";
import { qk } from "@/queries/keys";
import { useMe } from "@/queries/me";
import { renderQueryHook } from "@/__tests__/support/hookHarness";

describe("useUpcomingEvents", () => {
  it("lists a community's upcoming events", async () => {
    const events = [event({ id: "e1" }), event({ id: "e2", title: "Second" })];
    const listUpcoming = vi.fn(async () => events);
    const { result, queryClient } = renderQueryHook(() => useUpcomingEvents("c1"), {
      api: { events: { listUpcoming } },
    });
    expect(result.current.isPending).toBe(true);
    await waitFor(() => expect(result.current.data).toEqual(events));
    expect(listUpcoming).toHaveBeenCalledWith("c1");
    expect(queryClient.getQueryData(qk.upcomingEvents("c1"))).toEqual(events);
  });

  it("stays idle until a community id exists", async () => {
    const listUpcoming = vi.fn(async () => [event()]);
    const { result, rerender } = renderQueryHook((id: string | undefined) => useUpcomingEvents(id), {
      api: { events: { listUpcoming } },
      initialProps: undefined,
    });
    expect(result.current.fetchStatus).toBe("idle");
    expect(listUpcoming).not.toHaveBeenCalled();
    rerender("c1");
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });

  it("reports an error when the list fails", async () => {
    const { result } = renderQueryHook(() => useUpcomingEvents("c1"), {
      api: { events: { listUpcoming: async () => { throw new Error("boom"); } } },
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});

describe("useAllEvents", () => {
  it("lists every event of a community under its own key", async () => {
    const listAll = vi.fn(async () => [event({ id: "past", scheduledTime: "2020-01-01T00:00:00.000Z" })]);
    const { result, queryClient } = renderQueryHook(() => useAllEvents("c1"), { api: { events: { listAll } } });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(listAll).toHaveBeenCalledWith("c1");
    expect(queryClient.getQueryData(qk.allEvents("c1"))).toHaveLength(1);
    expect(queryClient.getQueryData(qk.upcomingEvents("c1"))).toBeUndefined();
  });
});

describe("useEventParticipants", () => {
  const participants = [{ participant: { userId: "u1", eventId: "e1", status: "active" as const, isPresent: false }, user: user() }];

  it("lists the participants of an event", async () => {
    const listParticipants = vi.fn(async () => participants);
    const { result } = renderQueryHook(() => useEventParticipants("e1"), { api: { events: { listParticipants } } });
    await waitFor(() => expect(result.current.data).toEqual(participants));
    expect(listParticipants).toHaveBeenCalledWith("e1");
  });

  it("does not fetch without an event id", () => {
    const listParticipants = vi.fn(async () => participants);
    const { result } = renderQueryHook(() => useEventParticipants(undefined), { api: { events: { listParticipants } } });
    expect(result.current.fetchStatus).toBe("idle");
    expect(listParticipants).not.toHaveBeenCalled();
  });

  it("does not fetch when explicitly disabled, and fetches once enabled", async () => {
    const listParticipants = vi.fn(async () => participants);
    const { result, rerender } = renderQueryHook((enabled: boolean) => useEventParticipants("e1", enabled), {
      api: { events: { listParticipants } },
      initialProps: false,
    });
    expect(result.current.fetchStatus).toBe("idle");
    expect(listParticipants).not.toHaveBeenCalled();

    rerender(true);
    await waitFor(() => expect(result.current.data).toEqual(participants));
  });
});

describe("useCreateEvent", () => {
  const input: NewEventInput = {
    communityId: "c1",
    templateId: "t1",
    scheduledTime: "2030-01-01T18:00:00.000Z",
    durationInMinutes: 60,
    eventType: "hosted",
    isPublic: true,
  };

  /** Mounts the lists a new event can affect, plus an unrelated community's list. */
  const setup = (create: (input: NewEventInput) => Promise<ReturnType<typeof event>>) => {
    const listUpcoming = vi.fn(async (id: string) => [event({ communityId: id })]);
    const listAll = vi.fn(async (id: string) => [event({ communityId: id })]);
    const getByDisplayId = vi.fn(async () => community());
    const listMine = vi.fn(async () => [community()]);
    const get = vi.fn(async () => me());
    const harness = renderQueryHook(
      () => ({
        upcoming: useUpcomingEvents("c1"),
        all: useAllEvents("c1"),
        otherUpcoming: useUpcomingEvents("c2"),
        community: useCommunity("civic-lab"),
        mine: useMyCommunities(),
        me: useMe(),
        mutation: useCreateEvent(),
      }),
      {
        api: {
          events: { create, listUpcoming, listAll },
          communities: { getByDisplayId, listMine },
          me: { get },
        },
      },
    );
    const settled = () =>
      waitFor(() => {
        const r = harness.result.current;
        expect(r.upcoming.isSuccess && r.all.isSuccess && r.otherUpcoming.isSuccess && r.community.isSuccess && r.mine.isSuccess && r.me.isSuccess).toBe(true);
      });
    return { ...harness, settled, listUpcoming, listAll, getByDisplayId, listMine, get };
  };

  it("creates the event through the api with the given input", async () => {
    const created = event({ id: "new", communityId: "c1" });
    const create = vi.fn(async () => created);
    const { result, settled } = setup(create);
    await settled();

    let returned: unknown;
    await act(async () => {
      returned = await result.current.mutation.mutateAsync(input);
    });

    expect(create).toHaveBeenCalledWith(input);
    expect(returned).toEqual(created);
  });

  it("refetches the event lists and community data for the event's community", async () => {
    const { result, settled, listUpcoming, listAll, getByDisplayId, listMine } = setup(async () =>
      event({ id: "new", communityId: "c1" }),
    );
    await settled();
    expect(listUpcoming).toHaveBeenCalledTimes(2); // c1 and c2

    await act(() => result.current.mutation.mutateAsync(input));

    await waitFor(() => expect(listUpcoming).toHaveBeenCalledTimes(3));
    expect(listUpcoming).toHaveBeenLastCalledWith("c1");
    expect(listAll).toHaveBeenCalledTimes(2);
    // Anything under qk.communities() (the onboarding progress lives on the community).
    expect(getByDisplayId).toHaveBeenCalledTimes(2);
    expect(listMine).toHaveBeenCalledTimes(2);
  });

  it("leaves another community's list and unrelated queries alone", async () => {
    const { result, settled, listUpcoming, get } = setup(async () => event({ id: "new", communityId: "c1" }));
    await settled();

    await act(() => result.current.mutation.mutateAsync(input));

    const callsForOther = listUpcoming.mock.calls.filter(([id]) => id === "c2");
    expect(callsForOther).toHaveLength(1);
    expect(get).toHaveBeenCalledTimes(1);
  });

  it("invalidates by the community of the event the server returned", async () => {
    const { result, settled, listUpcoming } = setup(async () => event({ id: "new", communityId: "c2" }));
    await settled();

    await act(() => result.current.mutation.mutateAsync(input));

    await waitFor(() => expect(listUpcoming).toHaveBeenCalledTimes(3));
    expect(listUpcoming).toHaveBeenLastCalledWith("c2");
  });

  it("rejects and refetches nothing when creation fails", async () => {
    const { result, settled, listUpcoming, listAll, getByDisplayId } = setup(async () => {
      throw new Error("denied");
    });
    await settled();

    await act(async () => {
      await expect(result.current.mutation.mutateAsync(input)).rejects.toThrow("denied");
    });

    await waitFor(() => expect(result.current.mutation.isError).toBe(true));
    expect(listUpcoming).toHaveBeenCalledTimes(2);
    expect(listAll).toHaveBeenCalledTimes(1);
    expect(getByDisplayId).toHaveBeenCalledTimes(1);
  });
});
