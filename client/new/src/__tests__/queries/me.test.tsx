// @vitest-environment jsdom
import { waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { me, membership, user } from "@/__tests__/support/fixtures";
import { qk } from "@/queries/keys";
import {
  meQuery,
  useCurrentUser,
  useCurrentUserId,
  useMe,
  useMembership,
  useUser,
} from "@/queries/me";
import { renderQueryHook } from "@/__tests__/support/hookHarness";

describe("useMe", () => {
  it("loads the signed-in user and memberships from api.me.get", async () => {
    const data = me({ memberships: [membership({ communityId: "c1", status: "admin" })] });
    const { result, api } = renderQueryHook(() => useMe(), { api: { me: { get: async () => data } } });

    expect(result.current.isPending).toBe(true);
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(data);
    expect(api.me.get).toHaveBeenCalledTimes(1);
  });

  it("surfaces a failed load as an error", async () => {
    const { result } = renderQueryHook(() => useMe(), {
      api: { me: { get: async () => { throw new Error("offline"); } } },
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error).toEqual(new Error("offline"));
  });

  it("caches under qk.me() and shares one request between callers", async () => {
    const get = vi.fn(async () => me());
    const { result, queryClient } = renderQueryHook(() => [useMe(), useMe()] as const, { api: { me: { get } } });
    await waitFor(() => expect(result.current[0].isSuccess).toBe(true));
    expect(result.current[1].data).toBe(result.current[0].data);
    expect(get).toHaveBeenCalledTimes(1);
    expect(queryClient.getQueryData(qk.me())).toEqual(me());
  });

  it("treats data as fresh for a minute (no refetch on a second mount)", async () => {
    const get = vi.fn(async () => me());
    const first = renderQueryHook(() => useMe(), { api: { me: { get } } });
    await waitFor(() => expect(first.result.current.isSuccess).toBe(true));

    const second = renderQueryHook(() => useMe(), { api: { me: { get } }, queryClient: first.queryClient });
    expect(second.result.current.isSuccess).toBe(true);
    expect(get).toHaveBeenCalledTimes(1);
  });

  it("exposes query options keyed by qk.me() that call the injected api", async () => {
    const { api, queryClient } = renderQueryHook(() => null, { api: { me: { get: async () => me() } } });
    const options = meQuery(api);
    expect(options.queryKey).toEqual(qk.me());
    await expect(queryClient.fetchQuery(options)).resolves.toEqual(me());
  });
});

describe("useCurrentUser / useCurrentUserId", () => {
  const api = { me: { get: async () => me({ user: user({ id: "u9", displayName: "Grace Hopper" }) }) } };

  it("are undefined until me loads, then the user and the user's id", async () => {
    const { result } = renderQueryHook(() => ({ user: useCurrentUser(), id: useCurrentUserId() }), { api });
    expect(result.current).toEqual({ user: undefined, id: undefined });
    await waitFor(() => expect(result.current.id).toBe("u9"));
    expect(result.current.user).toEqual(user({ id: "u9", displayName: "Grace Hopper" }));
  });

  it("stay undefined when me fails to load", async () => {
    const get = vi.fn(async () => { throw new Error("nope"); });
    const { result } = renderQueryHook(() => useCurrentUserId(), { api: { me: { get } } });
    await waitFor(() => expect(get).toHaveBeenCalled());
    expect(result.current).toBeUndefined();
  });
});

describe("useMembership", () => {
  const memberships = [
    membership({ communityId: "c1", status: "member" }),
    membership({ communityId: "c2", status: "moderator" }),
  ];
  const api = { me: { get: async () => me({ memberships }) } };

  it("picks the current user's membership in the given community", async () => {
    const { result } = renderQueryHook(() => useMembership("c2"), { api });
    expect(result.current).toBeUndefined();
    await waitFor(() => expect(result.current).toEqual(memberships[1]));
  });

  it("is undefined for a community the user never interacted with", async () => {
    const { result, api: fake } = renderQueryHook(() => useMembership("c3"), { api });
    await waitFor(() => expect(fake.me.get).toHaveBeenCalled());
    await waitFor(() => expect(result.current).toBeUndefined());
  });

  it("is undefined when no community id is given", async () => {
    const { result, api: fake } = renderQueryHook(() => useMembership(undefined), { api });
    await waitFor(() => expect(fake.me.get).toHaveBeenCalled());
    expect(result.current).toBeUndefined();
  });

  it("re-selects without refetching when the community changes", async () => {
    const get = vi.fn(async () => me({ memberships }));
    const { result, rerender } = renderQueryHook((id: string) => useMembership(id), {
      api: { me: { get } },
      initialProps: "c1",
    });
    await waitFor(() => expect(result.current?.status).toBe("member"));

    rerender("c2");
    expect(result.current?.status).toBe("moderator");
    expect(get).toHaveBeenCalledTimes(1);
  });
});

describe("useUser", () => {
  it("fetches the public user by id", async () => {
    const get = vi.fn(async (id: string) => user({ id, displayName: "Katherine Johnson" }));
    const { result } = renderQueryHook(() => useUser("u7"), { api: { users: { get } } });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data?.displayName).toBe("Katherine Johnson");
    expect(get).toHaveBeenCalledWith("u7");
  });

  it("does not fetch while the id is undefined", async () => {
    const get = vi.fn(async () => user());
    const { result } = renderQueryHook(() => useUser(undefined), { api: { users: { get } } });
    expect(result.current.fetchStatus).toBe("idle");
    expect(result.current.isPending).toBe(true);
    expect(get).not.toHaveBeenCalled();
  });

  it("caches each user under its own key", async () => {
    const get = vi.fn(async (id: string) => user({ id }));
    const { result, queryClient } = renderQueryHook(() => useUser("u7"), { api: { users: { get } } });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(queryClient.getQueryData(qk.user("u7"))).toEqual(user({ id: "u7" }));
    expect(queryClient.getQueryData(qk.user("u8"))).toBeUndefined();
  });

  it("reports an error when the user cannot be loaded", async () => {
    const { result } = renderQueryHook(() => useUser("ghost"), {
      api: { users: { get: async () => { throw new Error("not found"); } } },
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
