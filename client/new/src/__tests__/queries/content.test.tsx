// @vitest-environment jsdom
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { act, renderHook, waitFor } from "@testing-library/react";
import type { ReactNode } from "react";
import { describe, expect, it } from "vitest";
import type { Api } from "@/api/api";
import { BackendProvider } from "@/api/ApiProvider";
import { createFakeApi } from "@/__tests__/support/fakeApi";
import { announcement, resource } from "@/__tests__/support/fixtures";
import { qk } from "@/queries/keys";
import {
  useAnnouncements,
  useCreateAnnouncement,
  useCreateResource,
  useRemoveAnnouncement,
  useRemoveResource,
  useResources,
  useUpdateResource,
} from "@/queries/content";

const COMMUNITY = "c1";

function setup(apiOverrides: Parameters<typeof createFakeApi>[0] = {}) {
  const api: Api = createFakeApi(apiOverrides);
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: Infinity }, mutations: { retry: false } },
  });
  const wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <BackendProvider backend={{ api }}>{children}</BackendProvider>
    </QueryClientProvider>
  );
  return { api, queryClient, wrapper };
}

const isInvalidated = (qc: QueryClient, key: readonly unknown[]) =>
  qc.getQueryState(key)?.isInvalidated === true;

const failing = (message: string) => async () => {
  throw new Error(message);
};

describe("useResources", () => {
  it("loads the community's resources", async () => {
    const list = [resource({ id: "a" }), resource({ id: "b", title: "Guide" })];
    const { api, wrapper } = setup({ resources: { list: async () => list } });
    const { result } = renderHook(() => useResources(COMMUNITY), { wrapper });

    await waitFor(() => expect(result.current.data).toEqual(list));
    expect(api.resources.list).toHaveBeenCalledWith(COMMUNITY);
  });

  it("does not fetch until it knows which community", () => {
    const { api, wrapper } = setup({ resources: { list: async () => [] } });
    const { result } = renderHook(() => useResources(undefined), { wrapper });

    expect(result.current.fetchStatus).toBe("idle");
    expect(api.resources.list).not.toHaveBeenCalled();
  });

  it("reports an error when the list cannot be loaded", async () => {
    const { wrapper } = setup({ resources: { list: failing("boom") } });
    const { result } = renderHook(() => useResources(COMMUNITY), { wrapper });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});

describe("useCreateResource", () => {
  it("creates the resource and refetches the list that is on screen", async () => {
    let list = [resource({ id: "a" })];
    const created = resource({ id: "b", title: "Guide", url: "https://example.com/guide" });
    const { api, wrapper } = setup({
      resources: {
        list: async () => list,
        create: async () => {
          list = [...list, created];
          return created;
        },
      },
    });
    const { result } = renderHook(
      () => ({ list: useResources(COMMUNITY), create: useCreateResource(COMMUNITY) }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data).toHaveLength(1));

    await act(() =>
      result.current.create.mutateAsync({ title: "Guide", url: "https://example.com/guide", image: "https://img/g.png" }),
    );

    expect(api.resources.create).toHaveBeenCalledWith(COMMUNITY, {
      title: "Guide",
      url: "https://example.com/guide",
      image: "https://img/g.png",
    });
    await waitFor(() => expect(result.current.list.data?.map((r) => r.id)).toEqual(["a", "b"]));
  });

  it("does not touch the cache when creating fails", async () => {
    const { wrapper, queryClient } = setup({ resources: { create: failing("nope") } });
    queryClient.setQueryData(qk.resources(COMMUNITY), [resource()]);
    const { result } = renderHook(() => useCreateResource(COMMUNITY), { wrapper });

    await act(async () => {
      await expect(result.current.mutateAsync({ title: "x", url: "https://x.test" })).rejects.toThrow("nope");
    });

    expect(isInvalidated(queryClient, qk.resources(COMMUNITY))).toBe(false);
  });
});

describe("useUpdateResource", () => {
  it("sends the patch for that resource and invalidates the list", async () => {
    const { api, wrapper, queryClient } = setup({
      resources: { update: async () => resource({ title: "Renamed" }) },
    });
    queryClient.setQueryData(qk.resources(COMMUNITY), [resource()]);
    const { result } = renderHook(() => useUpdateResource(COMMUNITY), { wrapper });

    await act(() =>
      result.current.mutateAsync({ resourceId: "r1", patch: { title: "Renamed", url: "https://example.com/new" } }),
    );

    expect(api.resources.update).toHaveBeenCalledWith(COMMUNITY, "r1", {
      title: "Renamed",
      url: "https://example.com/new",
    });
    expect(isInvalidated(queryClient, qk.resources(COMMUNITY))).toBe(true);
  });

  it("surfaces the failure and leaves the list fresh", async () => {
    const { wrapper, queryClient } = setup({ resources: { update: failing("denied") } });
    queryClient.setQueryData(qk.resources(COMMUNITY), [resource()]);
    const { result } = renderHook(() => useUpdateResource(COMMUNITY), { wrapper });

    await act(async () => {
      await expect(result.current.mutateAsync({ resourceId: "r1", patch: { title: "x" } })).rejects.toThrow("denied");
    });

    expect(isInvalidated(queryClient, qk.resources(COMMUNITY))).toBe(false);
  });
});

describe("useRemoveResource", () => {
  it("removes the resource and refetches so it disappears from the list", async () => {
    let list = [resource({ id: "a" }), resource({ id: "b", title: "Guide" })];
    const { api, wrapper } = setup({
      resources: {
        list: async () => list,
        remove: async (_communityId: string, resourceId: string) => {
          list = list.filter((r) => r.id !== resourceId);
        },
      },
    });
    const { result } = renderHook(
      () => ({ list: useResources(COMMUNITY), remove: useRemoveResource(COMMUNITY) }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data).toHaveLength(2));

    await act(() => result.current.remove.mutateAsync("a"));

    expect(api.resources.remove).toHaveBeenCalledWith(COMMUNITY, "a");
    await waitFor(() => expect(result.current.list.data?.map((r) => r.id)).toEqual(["b"]));
  });

  it("keeps the list as it was when removal fails", async () => {
    const { wrapper, queryClient } = setup({ resources: { remove: failing("denied") } });
    queryClient.setQueryData(qk.resources(COMMUNITY), [resource()]);
    const { result } = renderHook(() => useRemoveResource(COMMUNITY), { wrapper });

    await act(async () => {
      await expect(result.current.mutateAsync("r1")).rejects.toThrow("denied");
    });

    expect(queryClient.getQueryData(qk.resources(COMMUNITY))).toEqual([resource()]);
    expect(isInvalidated(queryClient, qk.resources(COMMUNITY))).toBe(false);
  });
});

describe("useAnnouncements", () => {
  it("loads the community's announcements", async () => {
    const list = [announcement({ id: "a" }), announcement({ id: "b", message: "Second" })];
    const { api, wrapper } = setup({ announcements: { list: async () => list } });
    const { result } = renderHook(() => useAnnouncements(COMMUNITY), { wrapper });

    await waitFor(() => expect(result.current.data).toEqual(list));
    expect(api.announcements.list).toHaveBeenCalledWith(COMMUNITY);
  });

  it("does not fetch while disabled or before the community is known", () => {
    const { api, wrapper } = setup({ announcements: { list: async () => [] } });
    const disabled = renderHook(() => useAnnouncements(COMMUNITY, false), { wrapper });
    const unknown = renderHook(() => useAnnouncements(undefined), { wrapper });

    expect(disabled.result.current.fetchStatus).toBe("idle");
    expect(unknown.result.current.fetchStatus).toBe("idle");
    expect(api.announcements.list).not.toHaveBeenCalled();
  });

  it("starts fetching once enabled", async () => {
    const { api, wrapper } = setup({ announcements: { list: async () => [announcement()] } });
    const { result, rerender } = renderHook(({ enabled }) => useAnnouncements(COMMUNITY, enabled), {
      wrapper,
      initialProps: { enabled: false },
    });
    expect(api.announcements.list).not.toHaveBeenCalled();

    rerender({ enabled: true });

    await waitFor(() => expect(result.current.data).toHaveLength(1));
  });
});

describe("useCreateAnnouncement", () => {
  it("posts the announcement and refetches the list", async () => {
    let list = [announcement({ id: "a" })];
    const { api, wrapper } = setup({
      announcements: {
        list: async () => list,
        create: async () => {
          list = [announcement({ id: "b", message: "Potluck" }), ...list];
        },
      },
    });
    const { result } = renderHook(
      () => ({ list: useAnnouncements(COMMUNITY), create: useCreateAnnouncement(COMMUNITY) }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data).toHaveLength(1));

    await act(() => result.current.create.mutateAsync({ title: "News", message: "Potluck" }));

    expect(api.announcements.create).toHaveBeenCalledWith(COMMUNITY, { title: "News", message: "Potluck" });
    await waitFor(() => expect(result.current.list.data?.map((a) => a.id)).toEqual(["b", "a"]));
  });

  it("leaves the list fresh when posting fails", async () => {
    const { wrapper, queryClient } = setup({ announcements: { create: failing("nope") } });
    queryClient.setQueryData(qk.announcements(COMMUNITY), [announcement()]);
    const { result } = renderHook(() => useCreateAnnouncement(COMMUNITY), { wrapper });

    await act(async () => {
      await expect(result.current.mutateAsync({ message: "x" })).rejects.toThrow("nope");
    });

    expect(isInvalidated(queryClient, qk.announcements(COMMUNITY))).toBe(false);
  });
});

describe("useRemoveAnnouncement", () => {
  it("removes the announcement and refetches the list", async () => {
    let list = [announcement({ id: "a" }), announcement({ id: "b" })];
    const { api, wrapper } = setup({
      announcements: {
        list: async () => list,
        remove: async (_communityId: string, announcementId: string) => {
          list = list.filter((a) => a.id !== announcementId);
        },
      },
    });
    const { result } = renderHook(
      () => ({ list: useAnnouncements(COMMUNITY), remove: useRemoveAnnouncement(COMMUNITY) }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data).toHaveLength(2));

    await act(() => result.current.remove.mutateAsync("a"));

    expect(api.announcements.remove).toHaveBeenCalledWith(COMMUNITY, "a");
    await waitFor(() => expect(result.current.list.data?.map((a) => a.id)).toEqual(["b"]));
  });

  it("keeps the list when removal fails", async () => {
    const { wrapper, queryClient } = setup({ announcements: { remove: failing("denied") } });
    queryClient.setQueryData(qk.announcements(COMMUNITY), [announcement()]);
    const { result } = renderHook(() => useRemoveAnnouncement(COMMUNITY), { wrapper });

    await act(async () => {
      await expect(result.current.mutateAsync("a1")).rejects.toThrow("denied");
    });

    expect(isInvalidated(queryClient, qk.announcements(COMMUNITY))).toBe(false);
  });
});
