// @vitest-environment jsdom
import { waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { template } from "@/__tests__/support/fixtures";
import { qk } from "@/queries/keys";
import { templatesQuery, useHasAttendedTemplate, useTemplates } from "@/queries/templates";
import { renderQueryHook } from "@/__tests__/support/hookHarness";

describe("useTemplates", () => {
  it("lists a community's templates, including removed ones (filtering is the scope's job)", async () => {
    const templates = [template({ id: "t1" }), template({ id: "t2", status: "removed" })];
    const list = vi.fn(async () => templates);
    const { result, queryClient } = renderQueryHook(() => useTemplates("c1"), { api: { templates: { list } } });

    expect(result.current.isPending).toBe(true);
    await waitFor(() => expect(result.current.data).toEqual(templates));
    expect(list).toHaveBeenCalledWith("c1");
    expect(queryClient.getQueryData(qk.templates("c1"))).toEqual(templates);
  });

  it("waits for a community id before fetching", async () => {
    const list = vi.fn(async () => []);
    const { result, rerender } = renderQueryHook((id: string | undefined) => useTemplates(id), {
      api: { templates: { list } },
      initialProps: undefined,
    });
    expect(result.current.fetchStatus).toBe("idle");
    expect(list).not.toHaveBeenCalled();

    rerender("c1");
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(list).toHaveBeenCalledWith("c1");
  });

  it("surfaces a failed load as an error", async () => {
    const { result } = renderQueryHook(() => useTemplates("c1"), {
      api: { templates: { list: async () => { throw new Error("boom"); } } },
    });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });

  it("exposes query options keyed by community", async () => {
    const { api, queryClient } = renderQueryHook(() => null, { api: { templates: { list: async () => [template()] } } });
    const options = templatesQuery(api, "c1");
    expect(options.queryKey).toEqual(qk.templates("c1"));
    await expect(queryClient.fetchQuery(options)).resolves.toEqual([template()]);
  });
});

describe("useHasAttendedTemplate", () => {
  it("asks whether the current user attended the template", async () => {
    const hasAttendedTemplate = vi.fn(async () => true);
    const { result, queryClient } = renderQueryHook(() => useHasAttendedTemplate("t1"), {
      api: { events: { hasAttendedTemplate } },
    });
    await waitFor(() => expect(result.current.data).toBe(true));
    expect(hasAttendedTemplate).toHaveBeenCalledWith("t1");
    expect(queryClient.getQueryData(qk.attendedTemplate("t1"))).toBe(true);
  });

  it("returns false (not undefined) for a template the user has not attended", async () => {
    const { result } = renderQueryHook(() => useHasAttendedTemplate("t1"), {
      api: { events: { hasAttendedTemplate: async () => false } },
    });
    await waitFor(() => expect(result.current.data).toBe(false));
  });

  it("does not fetch for an event without a prerequisite template", async () => {
    const hasAttendedTemplate = vi.fn(async () => true);
    const { result } = renderQueryHook(() => useHasAttendedTemplate(undefined), {
      api: { events: { hasAttendedTemplate } },
    });
    expect(result.current.fetchStatus).toBe("idle");
    expect(result.current.data).toBeUndefined();
    expect(hasAttendedTemplate).not.toHaveBeenCalled();
  });
});
