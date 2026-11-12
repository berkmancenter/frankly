// @vitest-environment jsdom
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { act, renderHook, waitFor } from "@testing-library/react";
import type { ReactNode } from "react";
import { describe, expect, it, vi } from "vitest";
import type { Api } from "@/api/api";
import { BackendProvider } from "@/api/ApiProvider";
import type { DiscussionThread, DiscussionThreadComment } from "@/api/types";
import { createFakeApi } from "@/__tests__/support/fakeApi";
import { comment, thread } from "@/__tests__/support/fixtures";
import { qk } from "@/queries/keys";
import {
  useAddComment,
  useCreateThread,
  useSetThreadEmotion,
  useThreadComments,
  useThreads,
  useUpdateThread,
  useVoteThread,
} from "@/queries/threads";
import { createFakeAuth } from "@/__tests__/support/fakeAuth";

const COMMUNITY = "c1";
const ME = "u1";

function setup(apiOverrides: Parameters<typeof createFakeApi>[0] = {}) {
  const api: Api = createFakeApi(apiOverrides);
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: Infinity }, mutations: { retry: false } },
  });
  const wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <BackendProvider backend={{ api, auth: createFakeAuth() }}>{children}</BackendProvider>
    </QueryClientProvider>
  );
  return { api, queryClient, wrapper };
}

/** A promise the test settles by hand, to observe the cache while a request is in flight. */
function deferred<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, resolve, reject };
}

const isInvalidated = (qc: QueryClient, key: readonly unknown[]) =>
  qc.getQueryState(key)?.isInvalidated === true;

describe("useThreads", () => {
  it("loads the community's threads", async () => {
    const posts = [thread({ id: "a" }), thread({ id: "b" })];
    const { api, wrapper } = setup({ threads: { list: async () => posts } });
    const { result } = renderHook(() => useThreads(COMMUNITY), { wrapper });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(posts);
    expect(api.threads.list).toHaveBeenCalledWith(COMMUNITY);
  });

  it("does not fetch until it knows which community", () => {
    const { api, wrapper } = setup({ threads: { list: async () => [] } });
    const { result } = renderHook(() => useThreads(undefined), { wrapper });

    expect(result.current.fetchStatus).toBe("idle");
    expect(api.threads.list).not.toHaveBeenCalled();
  });

  it("surfaces a failed load as an error", async () => {
    const { wrapper } = setup({
      threads: {
        list: async () => {
          throw new Error("boom");
        },
      },
    });
    const { result } = renderHook(() => useThreads(COMMUNITY), { wrapper });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});

describe("useThreadComments", () => {
  it("loads the comments of one thread", async () => {
    const comments = [comment({ id: "x" })];
    const { api, wrapper } = setup({ threads: { listComments: async () => comments } });
    const { result } = renderHook(() => useThreadComments("th9"), { wrapper });

    await waitFor(() => expect(result.current.data).toEqual(comments));
    expect(api.threads.listComments).toHaveBeenCalledWith("th9");
  });
});

describe("useCreateThread", () => {
  it("sends the new post to the API and refetches the thread list", async () => {
    let posts = [thread({ id: "old" })];
    const created = thread({ id: "new", content: "Fresh" });
    const { api, wrapper } = setup({
      threads: {
        list: async () => posts,
        create: async () => {
          posts = [created, ...posts];
          return created;
        },
      },
    });
    const { result } = renderHook(
      () => ({ list: useThreads(COMMUNITY), create: useCreateThread(COMMUNITY) }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data).toHaveLength(1));

    await act(() => result.current.create.mutateAsync({ content: "Fresh", imageUrl: "https://img/x.png" }));

    expect(api.threads.create).toHaveBeenCalledWith(COMMUNITY, { content: "Fresh", imageUrl: "https://img/x.png" });
    await waitFor(() => expect(result.current.list.data?.map((t) => t.id)).toEqual(["new", "old"]));
    expect(api.threads.list).toHaveBeenCalledTimes(2);
  });

  it("leaves the list alone when creating fails", async () => {
    const { wrapper, queryClient } = setup({
      threads: {
        list: async () => [thread()],
        create: async () => {
          throw new Error("nope");
        },
      },
    });
    const { result } = renderHook(
      () => ({ list: useThreads(COMMUNITY), create: useCreateThread(COMMUNITY) }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.isSuccess).toBe(true));

    await act(async () => {
      await expect(result.current.create.mutateAsync({ content: "x" })).rejects.toThrow("nope");
    });
    expect(isInvalidated(queryClient, qk.threads(COMMUNITY))).toBe(false);
  });
});

describe("useUpdateThread", () => {
  it("patches the thread, primes the detail cache and refreshes the list", async () => {
    const updated = thread({ id: "th1", content: "Edited" });
    const { api, wrapper, queryClient } = setup({
      threads: { list: async () => [updated], update: async () => updated },
    });
    queryClient.setQueryData(qk.thread("th1"), thread({ id: "th1", content: "Original" }));
    queryClient.setQueryData(qk.threads(COMMUNITY), [thread({ id: "th1", content: "Original" })]);
    const { result } = renderHook(() => useUpdateThread(COMMUNITY), { wrapper });

    await act(() =>
      result.current.mutateAsync({ threadId: "th1", patch: { content: "Edited", imageUrl: undefined } }),
    );

    expect(api.threads.update).toHaveBeenCalledWith("th1", { content: "Edited", imageUrl: undefined });
    expect(queryClient.getQueryData<DiscussionThread>(qk.thread("th1"))?.content).toBe("Edited");
    expect(isInvalidated(queryClient, qk.threads(COMMUNITY))).toBe(true);
  });
});

describe("useVoteThread", () => {
  const seed = (qc: QueryClient, t: DiscussionThread, others: DiscussionThread[] = []) => {
    qc.setQueryData(qk.threads(COMMUNITY), [t, ...others]);
    qc.setQueryData(qk.thread(t.id), t);
  };
  const listOf = (qc: QueryClient) => qc.getQueryData<DiscussionThread[]>(qk.threads(COMMUNITY));
  const detailOf = (qc: QueryClient, id = "th1") => qc.getQueryData<DiscussionThread>(qk.thread(id));

  it("applies a like to the list and the detail cache before the server answers", async () => {
    const vote = deferred<DiscussionThread>();
    const { api, wrapper, queryClient } = setup({ threads: { vote: () => vote.promise } });
    seed(queryClient, thread({ id: "th1", likedBy: ["u2"] }), [thread({ id: "th2" })]);
    const { result } = renderHook(() => useVoteThread(COMMUNITY, ME), { wrapper });

    act(() => result.current.mutate({ threadId: "th1", vote: "like" }));

    await waitFor(() => expect(listOf(queryClient)?.[0]?.likedBy).toEqual(["u2", ME]));
    expect(detailOf(queryClient)?.likedBy).toEqual(["u2", ME]);
    expect(listOf(queryClient)?.[1]).toEqual(thread({ id: "th2" }));
    expect(api.threads.vote).toHaveBeenCalledWith("th1", "like");
    expect(result.current.isPending).toBe(true);

    await act(async () => vote.resolve(thread()));
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });

  it("moves my vote from like to dislike", async () => {
    const { wrapper, queryClient } = setup({ threads: { vote: async () => thread() } });
    seed(queryClient, thread({ id: "th1", likedBy: [ME, "u2"], dislikedBy: ["u3"] }));
    const { result } = renderHook(() => useVoteThread(COMMUNITY, ME), { wrapper });

    await act(() => result.current.mutateAsync({ threadId: "th1", vote: "dislike" }));

    expect(detailOf(queryClient)).toMatchObject({ likedBy: ["u2"], dislikedBy: ["u3", ME] });
  });

  it("withdraws my vote on neutral, leaving other people's votes alone", async () => {
    const { wrapper, queryClient } = setup({ threads: { vote: async () => thread() } });
    seed(queryClient, thread({ id: "th1", likedBy: [ME, "u2"], dislikedBy: ["u3"] }));
    const { result } = renderHook(() => useVoteThread(COMMUNITY, ME), { wrapper });

    await act(() => result.current.mutateAsync({ threadId: "th1", vote: "neutral" }));

    expect(detailOf(queryClient)).toMatchObject({ likedBy: ["u2"], dislikedBy: ["u3"] });
  });

  it("does not record a vote for an unknown user", async () => {
    const { wrapper, queryClient } = setup({ threads: { vote: async () => thread() } });
    seed(queryClient, thread({ id: "th1", likedBy: ["u2"] }));
    const { result } = renderHook(() => useVoteThread(COMMUNITY, undefined), { wrapper });

    await act(() => result.current.mutateAsync({ threadId: "th1", vote: "like" }));

    expect(detailOf(queryClient)?.likedBy).toEqual(["u2"]);
  });

  it("rolls both caches back when the vote fails", async () => {
    const vote = deferred<DiscussionThread>();
    const { wrapper, queryClient } = setup({ threads: { vote: () => vote.promise } });
    const original = thread({ id: "th1", likedBy: ["u2"], dislikedBy: [ME] });
    seed(queryClient, original);
    const { result } = renderHook(() => useVoteThread(COMMUNITY, ME), { wrapper });

    act(() => result.current.mutate({ threadId: "th1", vote: "like" }));
    await waitFor(() => expect(detailOf(queryClient)?.likedBy).toContain(ME));

    await act(async () => vote.reject(new Error("offline")));
    await waitFor(() => expect(result.current.isError).toBe(true));

    expect(listOf(queryClient)).toEqual([original]);
    expect(detailOf(queryClient)).toEqual(original);
  });

  it("marks the list and the thread stale once the request settles, success or not", async () => {
    const { wrapper, queryClient } = setup({ threads: { vote: async () => thread() } });
    seed(queryClient, thread({ id: "th1" }));
    const { result } = renderHook(() => useVoteThread(COMMUNITY, ME), { wrapper });

    await act(() => result.current.mutateAsync({ threadId: "th1", vote: "like" }));

    expect(isInvalidated(queryClient, qk.threads(COMMUNITY))).toBe(true);
    expect(isInvalidated(queryClient, qk.thread("th1"))).toBe(true);
  });

  it("refetches an observed list after settling, replacing the optimistic guess with server truth", async () => {
    let server = thread({ id: "th1" });
    const { wrapper } = setup({
      threads: {
        list: async () => [server],
        vote: async () => {
          server = thread({ id: "th1", likedBy: [ME, "u2"] });
          return server;
        },
      },
    });
    const { result } = renderHook(
      () => ({ list: useThreads(COMMUNITY), vote: useVoteThread(COMMUNITY, ME) }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.isSuccess).toBe(true));

    await act(() => result.current.vote.mutateAsync({ threadId: "th1", vote: "like" }));

    await waitFor(() => expect(result.current.list.data?.[0]?.likedBy).toEqual([ME, "u2"]));
  });

  it("does nothing to caches that were never loaded", async () => {
    const { wrapper, queryClient } = setup({ threads: { vote: async () => thread() } });
    const { result } = renderHook(() => useVoteThread(COMMUNITY, ME), { wrapper });

    await act(() => result.current.mutateAsync({ threadId: "th1", vote: "like" }));

    expect(listOf(queryClient)).toBeUndefined();
    expect(detailOf(queryClient)).toBeUndefined();
  });
});

describe("useSetThreadEmotion", () => {
  const seed = (qc: QueryClient, t: DiscussionThread) => {
    qc.setQueryData(qk.threads(COMMUNITY), [t]);
    qc.setQueryData(qk.thread(t.id), t);
  };
  const detailOf = (qc: QueryClient) => qc.getQueryData<DiscussionThread>(qk.thread("th1"));

  it("shows my reaction immediately in both caches and sends it to the API", async () => {
    const pending = deferred<DiscussionThread>();
    const { api, wrapper, queryClient } = setup({ threads: { setEmotion: () => pending.promise } });
    seed(queryClient, thread({ id: "th1", emotions: [{ userId: "u2", emotion: "heart" }] }));
    const { result } = renderHook(() => useSetThreadEmotion(COMMUNITY, ME), { wrapper });

    act(() => result.current.mutate({ threadId: "th1", emotion: "hundred" }));

    await waitFor(() =>
      expect(detailOf(queryClient)?.emotions).toEqual([
        { userId: "u2", emotion: "heart" },
        { userId: ME, emotion: "hundred" },
      ]),
    );
    expect(queryClient.getQueryData<DiscussionThread[]>(qk.threads(COMMUNITY))?.[0]?.emotions).toHaveLength(2);
    expect(api.threads.setEmotion).toHaveBeenCalledWith("th1", "hundred");

    await act(async () => pending.resolve(thread()));
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
  });

  it("replaces my earlier reaction instead of adding a second one", async () => {
    const { wrapper, queryClient } = setup({ threads: { setEmotion: async () => thread() } });
    seed(queryClient, thread({ id: "th1", emotions: [{ userId: ME, emotion: "heart" }] }));
    const { result } = renderHook(() => useSetThreadEmotion(COMMUNITY, ME), { wrapper });

    await act(() => result.current.mutateAsync({ threadId: "th1", emotion: "plusOne" }));

    expect(detailOf(queryClient)?.emotions).toEqual([{ userId: ME, emotion: "plusOne" }]);
  });

  it("removes my reaction when cleared with null, keeping other people's", async () => {
    const { api, wrapper, queryClient } = setup({ threads: { setEmotion: async () => thread() } });
    seed(
      queryClient,
      thread({
        id: "th1",
        emotions: [
          { userId: ME, emotion: "heart" },
          { userId: "u2", emotion: "heart" },
        ],
      }),
    );
    const { result } = renderHook(() => useSetThreadEmotion(COMMUNITY, ME), { wrapper });

    await act(() => result.current.mutateAsync({ threadId: "th1", emotion: null }));

    expect(detailOf(queryClient)?.emotions).toEqual([{ userId: "u2", emotion: "heart" }]);
    expect(api.threads.setEmotion).toHaveBeenCalledWith("th1", null);
  });

  it("restores the previous reactions when the request fails", async () => {
    const { wrapper, queryClient } = setup({
      threads: {
        setEmotion: async () => {
          throw new Error("offline");
        },
      },
    });
    const original = thread({ id: "th1", emotions: [{ userId: "u2", emotion: "heart" }] });
    seed(queryClient, original);
    const { result } = renderHook(() => useSetThreadEmotion(COMMUNITY, ME), { wrapper });

    await act(async () => {
      await expect(result.current.mutateAsync({ threadId: "th1", emotion: "hundred" })).rejects.toThrow("offline");
    });

    expect(detailOf(queryClient)).toEqual(original);
    expect(queryClient.getQueryData(qk.threads(COMMUNITY))).toEqual([original]);
  });

  it("marks the list and the thread stale once settled", async () => {
    const { wrapper, queryClient } = setup({ threads: { setEmotion: async () => thread() } });
    seed(queryClient, thread({ id: "th1" }));
    const { result } = renderHook(() => useSetThreadEmotion(COMMUNITY, ME), { wrapper });

    await act(() => result.current.mutateAsync({ threadId: "th1", emotion: "heart" }));

    expect(isInvalidated(queryClient, qk.threads(COMMUNITY))).toBe(true);
    expect(isInvalidated(queryClient, qk.thread("th1"))).toBe(true);
  });
});

describe("useAddComment", () => {
  it("posts the comment (with its parent, for a reply) to the API", async () => {
    const added: DiscussionThreadComment = comment({ id: "new", comment: "Agreed" });
    const { api, wrapper } = setup({ threads: { addComment: async () => added } });
    const { result } = renderHook(() => useAddComment("th1", COMMUNITY), { wrapper });

    await act(() => result.current.mutateAsync({ comment: "Agreed", replyToCommentId: "cm0" }));

    expect(api.threads.addComment).toHaveBeenCalledWith("th1", { comment: "Agreed", replyToCommentId: "cm0" });
  });

  it("invalidates the comment list, the thread and the community's thread list", async () => {
    const { wrapper, queryClient } = setup({ threads: { addComment: async () => comment() } });
    queryClient.setQueryData(qk.threadComments("th1"), [comment()]);
    queryClient.setQueryData(qk.thread("th1"), thread({ id: "th1" }));
    queryClient.setQueryData(qk.threads(COMMUNITY), [thread({ id: "th1" })]);
    queryClient.setQueryData(qk.threadComments("other"), [comment({ threadId: "other" })]);
    const { result } = renderHook(() => useAddComment("th1", COMMUNITY), { wrapper });

    await act(() => result.current.mutateAsync({ comment: "Hi" }));

    expect(isInvalidated(queryClient, qk.threadComments("th1"))).toBe(true);
    expect(isInvalidated(queryClient, qk.thread("th1"))).toBe(true);
    expect(isInvalidated(queryClient, qk.threads(COMMUNITY))).toBe(true);
    expect(isInvalidated(queryClient, qk.threadComments("other"))).toBe(false);
  });

  it("refetches the comments on screen so the new one appears", async () => {
    let comments = [comment({ id: "a" })];
    const { wrapper } = setup({
      threads: {
        listComments: async () => comments,
        addComment: async () => {
          comments = [...comments, comment({ id: "b" })];
          return comments[1]!;
        },
      },
    });
    const { result } = renderHook(
      () => ({ list: useThreadComments("th1"), add: useAddComment("th1", COMMUNITY) }),
      { wrapper },
    );
    await waitFor(() => expect(result.current.list.data).toHaveLength(1));

    await act(() => result.current.add.mutateAsync({ comment: "second" }));

    await waitFor(() => expect(result.current.list.data?.map((c) => c.id)).toEqual(["a", "b"]));
  });

  it("does not invalidate anything when the comment is rejected", async () => {
    const { wrapper, queryClient } = setup({
      threads: {
        addComment: async () => {
          throw new Error("rejected");
        },
      },
    });
    queryClient.setQueryData(qk.threadComments("th1"), []);
    const onError = vi.fn();
    const { result } = renderHook(() => useAddComment("th1", COMMUNITY), { wrapper });

    await act(async () => {
      await result.current.mutateAsync({ comment: "x" }).catch(onError);
    });

    expect(onError).toHaveBeenCalled();
    expect(isInvalidated(queryClient, qk.threadComments("th1"))).toBe(false);
  });
});
