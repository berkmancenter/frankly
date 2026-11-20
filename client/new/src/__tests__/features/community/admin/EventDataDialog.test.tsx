// @vitest-environment jsdom
import { act, screen, waitFor } from "@testing-library/react";
import { useState } from "react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { ChatRecord } from "@/api/types";
import { event } from "@/__tests__/support/fixtures";
import { renderWithProviders } from "@/__tests__/support/renderWithProviders";
import { EventDataDialog } from "@/features/community/admin/EventDataDialog";
import type { EventRecordings } from "@/queries/eventData";
import { downloadText } from "@/utils/csv";
import { openLinks } from "@/utils/openLinks";

vi.mock("@/utils/csv", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/utils/csv")>()),
  downloadText: vi.fn(),
}));
vi.mock("@/utils/openLinks", () => ({ openLinks: vi.fn(async () => {}) }));

beforeEach(() => {
  vi.mocked(downloadText).mockClear();
  vi.mocked(openLinks).mockClear();
});

const recordings = (over: Partial<EventRecordings> = {}): EventRecordings => ({
  video: { kind: "ready", parts: 2 },
  transcript: { kind: "ready", parts: 1 },
  repairNow: () => {},
  ...over,
});

const chatLine = (over: Partial<ChatRecord> = {}): ChatRecord => ({
  createdAt: "2030-01-05T18:05:00.000Z",
  userId: "ada",
  message: "Hello",
  roomId: "",
  deleted: false,
  ...over,
});

interface Setup {
  props?: Partial<Parameters<typeof EventDataDialog>[0]>;
  api?: object;
}

function setup({ props = {}, api = {} }: Setup = {}) {
  const onClose = vi.fn();
  const view = renderWithProviders(
    <EventDataDialog
      event={event({ id: "e1", surveyQuestions: [{ id: "q", title: "Color?", type: "multipleChoice", options: [], answers: [] }] })}
      registered={3}
      inPast
      hasRecording
      hasTranscript
      recordings={recordings()}
      onClose={onClose}
      {...props}
    />,
    {
      api: {
        events: {
          chatMessages: async () => [chatLine(), chatLine({ message: "Bye" })],
          suggestionsAndPolls: async () => ({
            suggestions: [{ userId: "ada", message: "Tea", roomId: "", deleted: false }],
            polls: [{ userId: "bob", question: "Ready?", response: "Yes", roomId: "" }],
          }),
          registrants: async () => [
            { userId: "ada", displayName: "Ada", email: "ada@example.com", memberStatus: "member", answers: ["Red"] },
          ],
          breakoutRooms: async () => [],
          recordingUrls: async () => ["https://files.test/v1.mp4", "https://files.test/v2.mp4"],
          transcriptUrls: async () => ["https://files.test/t.csv"],
          ...api,
        },
      } as never,
    },
  );
  return { onClose, ...view };
}

const choice = (name: RegExp | string) => screen.getByRole("checkbox", { name });
const download = () => userEvent.click(screen.getByRole("button", { name: "Download" }));

describe("EventDataDialog", () => {
  it("offers everything that can be taken from an event that is over", async () => {
    setup();
    expect(await screen.findByRole("checkbox", { name: /Recordings \(2 parts\)/ })).toBeInTheDocument();
    expect(choice("Registrations")).toBeChecked();
    expect(await screen.findByRole("checkbox", { name: "Chat Data (2 Items)" })).toBeInTheDocument();
    expect(await screen.findByRole("checkbox", { name: "Polls & Suggestions Data (2 Items)" })).toBeInTheDocument();
    expect(choice(/Transcripts \(CSV\) \(1 parts\)/)).toBeInTheDocument();
  });

  it("leaves out what an event that has not happened cannot have", async () => {
    setup({ props: { inPast: false } });
    await screen.findByRole("checkbox", { name: /Chat Data/ });
    expect(screen.queryByRole("checkbox", { name: /Recordings/ })).not.toBeInTheDocument();
    expect(screen.queryByRole("checkbox", { name: /Transcripts/ })).not.toBeInTheDocument();
  });

  it("leaves out recordings and transcripts the event does not make, and registrations nobody made", async () => {
    setup({ props: { hasRecording: false, hasTranscript: false, registered: 0 } });
    await screen.findByRole("checkbox", { name: /Chat Data/ });
    expect(screen.queryByRole("checkbox", { name: /Recordings/ })).not.toBeInTheDocument();
    expect(screen.queryByRole("checkbox", { name: /Transcripts/ })).not.toBeInTheDocument();
    expect(screen.queryByRole("checkbox", { name: "Registrations" })).not.toBeInTheDocument();
  });

  it("says when there is nothing in chat or in polls and suggestions", async () => {
    setup({ api: { chatMessages: async () => [], suggestionsAndPolls: async () => ({ suggestions: [], polls: [] }) } });
    expect(await screen.findByRole("checkbox", { name: "Chat Data (None)" })).toBeInTheDocument();
    expect(await screen.findByRole("checkbox", { name: "Polls & Suggestions Data (None)" })).toBeInTheDocument();
  });

  it("shows how far a recording and a transcript are, and holds them back until ready", async () => {
    setup({
      props: {
        recordings: recordings({ video: { kind: "preparing" }, transcript: { kind: "none" } }),
      },
    });
    const recording = await screen.findByRole("checkbox", { name: "Recordings (preparing...)" });
    expect(recording).toBeDisabled();
    expect(screen.getByRole("checkbox", { name: "Transcripts (CSV) (none)" })).toBeDisabled();
  });

  it("chooses a recording for the person when it becomes ready", async () => {
    let finish!: () => void;
    function Harness() {
      const [video, setVideo] = useState<EventRecordings["video"]>({ kind: "preparing" });
      finish = () => setVideo({ kind: "ready", parts: 1 });
      return (
        <EventDataDialog
          event={event({ id: "e1" })}
          registered={3}
          inPast
          hasRecording
          hasTranscript
          recordings={recordings({ video })}
          onClose={() => {}}
        />
      );
    }
    renderWithProviders(<Harness />, {
      api: { events: { chatMessages: async () => [], suggestionsAndPolls: async () => ({ suggestions: [], polls: [] }) } },
    });
    expect(await screen.findByRole("checkbox", { name: /Recordings/ })).not.toBeChecked();
    act(() => finish());
    await waitFor(() => expect(screen.getByRole("checkbox", { name: /Recordings/ })).toBeChecked());
  });

  it("downloads the registrations as a file", async () => {
    const { onClose } = setup();
    await download();
    await waitFor(() => expect(downloadText).toHaveBeenCalledTimes(1));
    const [name, csv] = vi.mocked(downloadText).mock.calls[0]!;
    expect(name).toBe("registration-data-e1.csv");
    expect(csv).toContain("User ID,Name,Email,Member Status");
    expect(csv).toContain("Question 1,Answer 1");
    expect(csv).toContain("ada,Ada,ada@example.com,member");
    expect(await screen.findByText("Download complete")).toBeInTheDocument();
    expect(onClose).toHaveBeenCalled();
  });

  it("downloads chat, polls and suggestions, and the recording and transcript links", async () => {
    setup();
    // The recording is ready, so it is already chosen.
    expect(await screen.findByRole("checkbox", { name: /Recordings/ })).toBeChecked();
    await userEvent.click(choice("Registrations"));
    await userEvent.click(choice("Chat Data (2 Items)"));
    await userEvent.click(choice("Polls & Suggestions Data (2 Items)"));
    await userEvent.click(choice(/Transcripts/));
    await download();
    await waitFor(() => expect(downloadText).toHaveBeenCalledTimes(2));
    expect(vi.mocked(downloadText).mock.calls.map(([name]) => name)).toEqual([
      "chat-data-e1.csv",
      "polls-suggestions-data-e1.csv",
    ]);
    expect(vi.mocked(downloadText).mock.calls[0]![1]).toContain("Time,User ID,Message,Room,Deleted");
    expect(vi.mocked(downloadText).mock.calls[1]![1]).toContain("Suggestion");
    expect(vi.mocked(openLinks).mock.calls.map(([urls]) => urls)).toEqual([
      ["https://files.test/v1.mp4", "https://files.test/v2.mp4"],
      ["https://files.test/t.csv"],
    ]);
  });

  it("says so, and downloads nothing, when the chosen data turns out to be empty", async () => {
    setup({ api: { chatMessages: async () => [] } });
    await userEvent.click(await screen.findByRole("checkbox", { name: "Chat Data (None)" }));
    await userEvent.click(choice("Registrations"));
    await download();
    expect(await screen.findByText("No chat data for this event.")).toBeInTheDocument();
    expect(downloadText).not.toHaveBeenCalled();
  });

  it("cannot download while nothing is chosen", async () => {
    setup();
    await userEvent.click(await screen.findByRole("checkbox", { name: /Recordings/ }));
    await userEvent.click(choice("Registrations"));
    expect(screen.getByRole("button", { name: "Download" })).toBeDisabled();
  });

  it("reports a failed download and stays open", async () => {
    const { onClose } = setup({
      api: {
        registrants: async () => {
          throw new Error("offline");
        },
      },
    });
    await download();
    expect(await screen.findByText("An error occurred")).toBeInTheDocument();
    expect(onClose).not.toHaveBeenCalled();
    expect(screen.getByRole("button", { name: "Download" })).toBeEnabled();
  });

  it("closes without downloading", async () => {
    const { onClose } = setup();
    await userEvent.click(screen.getByRole("button", { name: "Cancel" }));
    expect(onClose).toHaveBeenCalled();
    expect(downloadText).not.toHaveBeenCalled();
  });
});
