import { QueryClient, partialMatchKey } from "@tanstack/react-query";
import { describe, expect, it } from "vitest";
import { qk } from "@/queries/keys";

/** Whether invalidating `prefix` would touch a query stored under `key`. */
const covers = (prefix: readonly unknown[], key: readonly unknown[]) => partialMatchKey(key, prefix);

describe("query keys", () => {
  it("are pure functions of the ids they depend on", () => {
    expect(qk.members("c1")).toEqual(qk.members("c1"));
    expect(qk.members("c1")).not.toEqual(qk.members("c2"));
    expect(qk.user("u1")).toEqual(["users", "u1"]);
    expect(qk.me()).toEqual(["me"]);
    expect(qk.communityByDisplayId("civic-lab")).toEqual(["communities", "by-display-id", "civic-lab"]);
    expect(qk.threadComments("th1")).toEqual(["threads", "th1", "comments"]);
  });

  it("give every per-community resource a distinct key under the community prefix", () => {
    const keys = [
      qk.members("c1"),
      qk.templates("c1"),
      qk.upcomingEvents("c1"),
      qk.allEvents("c1"),
      qk.threads("c1"),
      qk.resources("c1"),
      qk.announcements("c1"),
    ];
    expect(new Set(keys.map((k) => JSON.stringify(k))).size).toBe(keys.length);
    for (const key of keys) expect(covers(qk.community("c1"), key)).toBe(true);
  });

  it("keeps one community's prefix from covering another community's queries", () => {
    expect(covers(qk.community("c1"), qk.templates("c2"))).toBe(false);
    expect(covers(qk.community("c1"), qk.upcomingEvents("c2"))).toBe(false);
  });

  it("nests the community lists under qk.communities()", () => {
    expect(covers(qk.communities(), qk.myCommunities())).toBe(true);
    expect(covers(qk.communities(), qk.communityByDisplayId("civic-lab"))).toBe(true);
    // The per-community subtree is a different tree from the community lookups.
    expect(covers(qk.communities(), qk.members("c1"))).toBe(false);
  });

  it("nests the upcoming and all event lists under one community's events", () => {
    const eventsPrefix = ["community", "c1", "events"] as const;
    expect(covers(eventsPrefix, qk.upcomingEvents("c1"))).toBe(true);
    expect(covers(eventsPrefix, qk.allEvents("c1"))).toBe(true);
    expect(covers(eventsPrefix, qk.templates("c1"))).toBe(false);
  });

  it("lets a thread prefix reach that thread's comments only", () => {
    expect(covers(qk.thread("th1"), qk.threadComments("th1"))).toBe(true);
    expect(covers(qk.thread("th1"), qk.threadComments("th2"))).toBe(false);
  });

  it("invalidates exactly the covered queries in a real cache", async () => {
    const queryClient = new QueryClient();
    queryClient.setQueryData(qk.templates("c1"), []);
    queryClient.setQueryData(qk.templates("c2"), []);
    queryClient.setQueryData(qk.me(), {});

    await queryClient.invalidateQueries({ queryKey: qk.community("c1") });

    expect(queryClient.getQueryState(qk.templates("c1"))?.isInvalidated).toBe(true);
    expect(queryClient.getQueryState(qk.templates("c2"))?.isInvalidated).toBe(false);
    expect(queryClient.getQueryState(qk.me())?.isInvalidated).toBe(false);
  });
});
