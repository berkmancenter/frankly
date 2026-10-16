import { beforeEach, expect, jest, test } from "@jest/globals";

jest.mock("firebase-admin", () => ({
  firestore: jest.fn(),
  storage: jest.fn(),
}));

jest.mock("../session_artifacts", () => ({
  VTT_FLUSH_WAIT_MS: 1000,
  listSessionFiles: jest.fn(),
  listUntilMp4: jest.fn(),
  mp4sOf: jest.fn(),
  vttsOf: jest.fn(),
  registerMp4s: jest.fn(),
  registerVtts: jest.fn(),
  mergeTranscript: jest.fn(),
}));

import * as admin from "firebase-admin";
import * as sessionArtifacts from "../session_artifacts";
import { produceSessions } from "../produce_sessions";

interface RecordingSession {
  status?: string;
  gcsPrefix?: string;
  agoraResourceId?: string;
  agoraSid?: string;
  agoraRttAgentId?: string;
}

function fakeEvent(before: RecordingSession | undefined, after: RecordingSession | undefined) {
  const ref = { id: "sess1" };
  return {
    params: { sessionId: "sess1" },
    data: {
      before: { data: () => before },
      after: { data: () => after, ref },
    },
  };
}

function mockStorage() {
  (admin.storage as unknown as jest.Mock).mockReturnValue({ bucket: () => ({}) });
}

beforeEach(() => {
  jest.clearAllMocks();
  mockStorage();
  (sessionArtifacts.mp4sOf as unknown as jest.Mock).mockImplementation((files) =>
    (files as { name: string }[]).filter((f) => f.name.endsWith(".mp4")),
  );
  (sessionArtifacts.vttsOf as unknown as jest.Mock).mockImplementation((files) =>
    (files as { name: string }[]).filter((f) => f.name.endsWith(".vtt")),
  );
});

test("does nothing when before or after data is missing", async () => {
  await produceSessions.run(fakeEvent(undefined, { status: "stopped" }) as never);
  expect(sessionArtifacts.listSessionFiles).not.toHaveBeenCalled();
});

test("does nothing when status did not change", async () => {
  await produceSessions.run(
    fakeEvent({ status: "stopped" }, { status: "stopped" }) as never,
  );
  expect(sessionArtifacts.listSessionFiles).not.toHaveBeenCalled();
});

test("does nothing when the new status is not stopped", async () => {
  await produceSessions.run(
    fakeEvent({ status: "starting" }, { status: "recording" }) as never,
  );
  expect(sessionArtifacts.listSessionFiles).not.toHaveBeenCalled();
});

test("skips post-processing when there is no gcsPrefix", async () => {
  await produceSessions.run(
    fakeEvent({ status: "recording" }, { status: "stopped" }) as never,
  );
  expect(sessionArtifacts.listSessionFiles).not.toHaveBeenCalled();
});

test("registers mp4/vtt artifacts already present and merges the transcript", async () => {
  (sessionArtifacts.listSessionFiles as unknown as jest.Mock).mockImplementation(async () => ([
    { name: "p/a.mp4" },
    { name: "p/a.vtt" },
  ]));
  (sessionArtifacts.registerMp4s as unknown as jest.Mock).mockImplementation(async () => (undefined));
  (sessionArtifacts.registerVtts as unknown as jest.Mock).mockImplementation(async () => (undefined));
  (sessionArtifacts.mergeTranscript as unknown as jest.Mock).mockImplementation(async () => ("p/a.csv"));

  await produceSessions.run(
    fakeEvent({ status: "recording" }, { status: "stopped", gcsPrefix: "p" }) as never,
  );

  expect(sessionArtifacts.listUntilMp4).not.toHaveBeenCalled();
  expect(sessionArtifacts.registerMp4s).toHaveBeenCalledWith(
    expect.anything(),
    [{ name: "p/a.mp4" }],
  );
  expect(sessionArtifacts.registerVtts).toHaveBeenCalledWith(
    expect.anything(),
    [{ name: "p/a.vtt" }],
  );
  expect(sessionArtifacts.mergeTranscript).toHaveBeenCalled();
});

test("waits for the MP4 to appear when a recording ran but none is listed yet", async () => {
  (sessionArtifacts.listSessionFiles as unknown as jest.Mock).mockImplementation(async () => ([]));
  (sessionArtifacts.listUntilMp4 as unknown as jest.Mock).mockImplementation(async () => ({
    files: [{ name: "p/a.mp4" }],
    waitedMs: 5000,
  }));
  (sessionArtifacts.registerMp4s as unknown as jest.Mock).mockImplementation(async () => (undefined));

  await produceSessions.run(
    fakeEvent(
      { status: "recording" },
      { status: "stopped", gcsPrefix: "p", agoraResourceId: "res1" },
    ) as never,
  );

  expect(sessionArtifacts.listUntilMp4).toHaveBeenCalled();
  expect(sessionArtifacts.registerMp4s).toHaveBeenCalledWith(
    expect.anything(),
    [{ name: "p/a.mp4" }],
  );
});

test("does not merge a transcript when no VTT files are found", async () => {
  (sessionArtifacts.listSessionFiles as unknown as jest.Mock).mockImplementation(async () => ([{ name: "p/a.mp4" }]));

  await produceSessions.run(
    fakeEvent({ status: "recording" }, { status: "stopped", gcsPrefix: "p" }) as never,
  );

  expect(sessionArtifacts.mergeTranscript).not.toHaveBeenCalled();
  expect(sessionArtifacts.registerVtts).not.toHaveBeenCalled();
});

test("continues post-processing even if registering MP4s throws", async () => {
  (sessionArtifacts.listSessionFiles as unknown as jest.Mock).mockImplementation(async () => ([{ name: "p/a.vtt" }]));
  (sessionArtifacts.registerMp4s as unknown as jest.Mock).mockImplementation(async () => { throw new Error("boom"); });
  (sessionArtifacts.registerVtts as unknown as jest.Mock).mockImplementation(async () => (undefined));
  (sessionArtifacts.mergeTranscript as unknown as jest.Mock).mockImplementation(async () => ("p/a.csv"));

  await expect(
    produceSessions.run(
      fakeEvent({ status: "recording" }, { status: "stopped", gcsPrefix: "p" }) as never,
    ),
  ).resolves.toBeUndefined();

  expect(sessionArtifacts.registerVtts).toHaveBeenCalled();
  expect(sessionArtifacts.mergeTranscript).toHaveBeenCalled();
});
