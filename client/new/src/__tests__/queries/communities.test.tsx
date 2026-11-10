// @vitest-environment jsdom
import { act, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { ApiError } from "@/api/api";
import type { Membership } from "@/api/types";
import { community, me, membership, user } from "@/__tests__/support/fixtures";
import {
  communityByDisplayIdQuery,
  myCommunitiesQuery,
  useCommunity,
  useFollowCommunity,
  useMembers,
  useMyCommunities,
  useUnfollowCommunity,
} from "@/queries/communities";
import { qk } from "@/queries/keys";
import { useMe } from "@/queries/me";
import { renderQueryHook } from "@/__tests__/support/hookHarness";

describe("useCommunity", () => {
  it("looks the community up by its display id", async () => {
    const getByDisplayId = vi.fn(async () => community({ name: "Civic Lab" }));
    const { result, queryClient } = renderQueryHook(() => useCommunity("civic-lab"), {
      api: { communities: { getByDisplayId } },
    });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.name).toBe("Civic Lab");
    expect(getByDisplayId).toHaveBeenCalledWith("civic-lab");
    expect(queryClient.getQueryData(qk.communityByDisplayId("civic-lab"))).toEqual(community());
  });

  it("surfaces a not-found error", async () => {
    const { result } = renderQueryHook(() => useCommunity("nope"), {
      api: { communities: { getByDisplayId: async () => { throw new ApiError("notFound", "no such community"); } } },
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error).toBeInstanceOf(ApiError);
    expect((result.current.error as ApiError).code).toBe("notFound");
  });

  it("refetches for a different display id and keeps the two apart in the cache", async () => {
    const getByDisplayId = vi.fn(async (displayId: string) => community({ id: displayId, displayId }));
    const { result, rerender, queryClient } = renderQueryHook((id: string) => useCommunity(id), {
      api: { communities: { getByDisplayId } },
      initialProps: "a",
    });
    await waitFor(() => expect(result.current.data?.displayId).toBe("a"));
    rerender("b");
    await waitFor(() => expect(result.current.data?.displayId).toBe("b"));
    expect(getByDisplayId).toHaveBeenCalledTimes(2);
    expect(queryClient.getQueryData(qk.communityByDisplayId("a"))).toMatchObject({ displayId: "a" });
  });

  it("does not refetch inside its 30 second stale window", async () => {
    const getByDisplayId = vi.fn(async () => community());
    const first = renderQueryHook(() => useCommunity("civic-lab"), { api: { communities: { getByDisplayId } } });
    await waitFor(() => expect(first.result.current.isSuccess).toBe(true));
    renderQueryHook(() => useCommunity("civic-lab"), {
      api: { communities: { getByDisplayId } },
      queryClient: first.queryClient,
    });
    expect(getByDisplayId).toHaveBeenCalledTimes(1);
  });

  it("exposes query options keyed by display id", async () => {
    const { api, queryClient } = renderQueryHook(() => null, {
      api: { communities: { getByDisplayId: async () => community() } },
    });
    const options = communityByDisplayIdQuery(api, "civic-lab");
    expect(options.queryKey).toEqual(qk.communityByDisplayId("civic-lab"));
    await expect(queryClient.fetchQuery(options)).resolves.toEqual(community());
  });
});

describe("useMyCommunities", () => {
  it("lists the communities the user belongs to", async () => {
    const mine = [community({ id: "c1" }), community({ id: "c2", displayId: "other" })];
    const { result, queryClient } = renderQueryHook(() => useMyCommunities(), {
      api: { communities: { listMine: async () => mine } },
    });
    await waitFor(() => expect(result.current.data).toEqual(mine));
    expect(queryClient.getQueryData(qk.myCommunities())).toEqual(mine);
  });

  it("exposes query options keyed by qk.myCommunities()", async () => {
    const { api, queryClient } = renderQueryHook(() => null, {
      api: { communities: { listMine: async () => [] } },
    });
    const options = myCommunitiesQuery(api);
    expect(options.queryKey).toEqual(qk.myCommunities());
    await expect(queryClient.fetchQuery(options)).resolves.toEqual([]);
  });
});

describe("follow / unfollow", () => {
  /** Mounts `me` and "my communities" so the mutations' invalidation shows up as refetches. */
  const setup = (overrides: { follow?: () => Promise<Membership>; unfollow?: () => Promise<void> } = {}) => {
    const get = vi.fn(async () => me());
    const listMine = vi.fn(async () => [community()]);
    const follow = vi.fn(overrides.follow ?? (async () => membership()));
    const unfollow = vi.fn(overrides.unfollow ?? (async () => undefined));
    const harness = renderQueryHook(
      () => ({
        me: useMe(),
        mine: useMyCommunities(),
        follow: useFollowCommunity(),
        unfollow: useUnfollowCommunity(),
      }),
      { api: { me: { get }, communities: { listMine, follow, unfollow } } },
    );
    const loaded = () =>
      waitFor(() => expect(harness.result.current.mine.isSuccess && harness.result.current.me.isSuccess).toBe(true));
    return { ...harness, loaded, get, listMine, follow, unfollow };
  };

  it("follows a community by id, then refetches me and my communities", async () => {
    const { result, loaded, follow, get, listMine } = setup();
    await loaded();

    await act(() => result.current.follow.mutateAsync("c1"));

    expect(follow).toHaveBeenCalledWith("c1");
    await waitFor(() => expect(get).toHaveBeenCalledTimes(2));
    await waitFor(() => expect(listMine).toHaveBeenCalledTimes(2));
  });

  it("unfollows a community by id, then refetches me and my communities", async () => {
    const { result, loaded, unfollow, get, listMine } = setup();
    await loaded();

    await act(() => result.current.unfollow.mutateAsync("c1"));

    expect(unfollow).toHaveBeenCalledWith("c1");
    await waitFor(() => expect(get).toHaveBeenCalledTimes(2));
    await waitFor(() => expect(listMine).toHaveBeenCalledTimes(2));
  });

  it("does not invalidate anything when following fails", async () => {
    const { result, loaded, get, listMine } = setup({
      follow: async () => {
        throw new Error("denied");
      },
    });
    await loaded();

    await act(async () => {
      await expect(result.current.follow.mutateAsync("c1")).rejects.toThrow("denied");
    });

    await waitFor(() => expect(result.current.follow.isError).toBe(true));
    expect(get).toHaveBeenCalledTimes(1);
    expect(listMine).toHaveBeenCalledTimes(1);
  });

  it("does not invalidate anything when unfollowing fails", async () => {
    const { result, loaded, get, listMine } = setup({
      unfollow: async () => {
        throw new Error("denied");
      },
    });
    await loaded();

    await act(async () => {
      await expect(result.current.unfollow.mutateAsync("c1")).rejects.toThrow("denied");
    });

    await waitFor(() => expect(result.current.unfollow.isError).toBe(true));
    expect(get).toHaveBeenCalledTimes(1);
    expect(listMine).toHaveBeenCalledTimes(1);
  });

  it("leaves other communities' cached data alone", async () => {
    const { result, loaded, queryClient } = setup();
    await loaded();
    queryClient.setQueryData(qk.members("c1"), []);

    await act(() => result.current.follow.mutateAsync("c1"));

    expect(queryClient.getQueryState(qk.members("c1"))?.isInvalidated).toBe(false);
  });
});

describe("useMembers", () => {
  it("lists a community's members with their memberships", async () => {
    const members = [
      { user: user({ id: "u1" }), membership: membership({ userId: "u1", status: "owner" }) },
      { user: user({ id: "u2", displayName: "Grace" }), membership: membership({ userId: "u2" }) },
    ];
    const listMembers = vi.fn(async () => members);
    const { result, queryClient } = renderQueryHook(() => useMembers("c1"), {
      api: { communities: { listMembers } },
    });
    await waitFor(() => expect(result.current.data).toEqual(members));
    expect(listMembers).toHaveBeenCalledWith("c1");
    expect(queryClient.getQueryData(qk.members("c1"))).toEqual(members);
  });

  it("keeps each community's members under its own key", async () => {
    const listMembers = vi.fn(async (id: string) => [
      { user: user({ id: `member-of-${id}` }), membership: membership({ communityId: id }) },
    ]);
    const { result, rerender } = renderQueryHook((id: string) => useMembers(id), {
      api: { communities: { listMembers } },
      initialProps: "c1",
    });
    await waitFor(() => expect(result.current.data?.[0]?.user.id).toBe("member-of-c1"));
    rerender("c2");
    await waitFor(() => expect(result.current.data?.[0]?.user.id).toBe("member-of-c2"));
  });

  it("reports an error when the list cannot be loaded", async () => {
    const { result } = renderQueryHook(() => useMembers("c1"), {
      api: { communities: { listMembers: async () => { throw new Error("boom"); } } },
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
