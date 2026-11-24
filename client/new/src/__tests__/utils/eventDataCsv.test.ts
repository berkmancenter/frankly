import { describe, expect, it } from "vitest";
import {
  chatCsv,
  formatStamp,
  formatUtcStamp,
  pollsSuggestionsCsv,
  registrationCsv,
  roomName,
  sanitizeCell,
} from "@/utils/events/eventDataCsv";
import { emotionEmoji } from "@/utils/emotions";

// Local, so the expected text does not depend on the machine's time zone.
const local = (...parts: [number, number, number, number, number]) => new Date(...parts).toISOString();

const rooms = [
  { roomId: "r1", roomName: "Room 1", participantIds: ["ada"] },
  { roomId: "r2", roomName: "Room 2", participantIds: [] },
];
const lines = (csv: string) => csv.split("\r\n");

describe("stamps", () => {
  it("writes a local time like Jan 5 2030, 6:00PM", () => {
    expect(formatStamp(local(2030, 0, 5, 18, 0))).toBe("Jan 5 2030, 6:00PM");
    expect(formatStamp(local(2030, 11, 31, 0, 5))).toBe("Dec 31 2030, 12:05AM");
    expect(formatStamp(local(2030, 5, 1, 12, 30))).toBe("Jun 1 2030, 12:30PM");
  });

  it("writes UTC times as a sortable stamp", () => {
    expect(formatUtcStamp("2030-01-05T18:00:07.000Z")).toBe("2030-01-05 18:00:07 UTC");
  });

  it("writes nothing for a missing time", () => {
    expect(formatStamp(undefined)).toBe("");
    expect(formatUtcStamp(undefined)).toBe("");
  });
});

describe("sanitizeCell", () => {
  it("quotes text a spreadsheet would run as a formula", () => {
    for (const text of ["=SUM(A1)", "+1", "-1", "@me", "\tx", "  =x"]) {
      expect(sanitizeCell(text)).toBe(`'${text}`);
    }
  });

  it("leaves everything else as it is", () => {
    expect(sanitizeCell("hello")).toBe("hello");
    expect(sanitizeCell("")).toBe("");
    expect(sanitizeCell(5)).toBe(5);
    expect(sanitizeCell(false)).toBe(false);
  });
});

describe("roomName", () => {
  it("names the main room, the waiting room and breakout rooms", () => {
    expect(roomName("", "e1", rooms)).toBe("Main room");
    expect(roomName("e1", "e1", rooms)).toBe("Main room");
    expect(roomName("waiting-room", "e1", rooms)).toBe("Waiting room");
    expect(roomName("r2", "e1", rooms)).toBe("Room 2");
  });

  it("falls back to the main room for a room it does not know", () => {
    expect(roomName("gone", "e1", rooms)).toBe("Main room");
    expect(roomName("gone", "e1", [])).toBe("Main room");
  });
});

describe("registrationCsv", () => {
  const registrants = [
    {
      userId: "ada",
      displayName: "Ada Lovelace",
      email: "ada@example.com",
      memberStatus: "member",
      registeredAt: "2030-01-01T10:00:00.000Z",
      firstPresentAt: local(2030, 0, 5, 18, 2),
      lastPresentAt: "2030-01-05T19:00:00.000Z",
      answers: ["Red", "North"],
    },
    { userId: "bob", displayName: "=Bob", email: "", memberStatus: "attendee", answers: [] },
  ];

  it("has a row per person with times, room and the answers beside their questions", () => {
    const csv = registrationCsv({ registrants, rooms, eventId: "e1", questionTitles: ["Color?", "Side?"] });
    expect(lines(csv)).toEqual([
      "User ID,Name,Email,Member Status,RSVP Time,Join Time,Last Active Time,Room Assigned,Question 1,Answer 1,Question 2,Answer 2",
      "ada,Ada Lovelace,ada@example.com,member,2030-01-01 10:00:00 UTC,\"Jan 5 2030, 6:02PM\",2030-01-05 19:00:00 UTC,Room 1,Color?,Red,Side?,North",
      "bob,'=Bob,,attendee,,,,Main room,Color?,,Side?,",
    ]);
  });

  it("has no question columns for an event without sign-up questions", () => {
    const csv = registrationCsv({ registrants: [registrants[1]!], rooms: [], eventId: "e1", questionTitles: [] });
    expect(lines(csv)[0]).toBe("User ID,Name,Email,Member Status,RSVP Time,Join Time,Last Active Time,Room Assigned");
  });
});

describe("chatCsv", () => {
  it("lists messages with their room, using the emoji for a reaction", () => {
    const csv = chatCsv({
      eventId: "e1",
      rooms,
      messages: [
        { createdAt: local(2030, 0, 5, 18, 5), userId: "ada", message: "Hello, all", roomId: "r1", deleted: false },
        { createdAt: local(2030, 0, 5, 18, 6), userId: "bob", emotion: "heart", roomId: "e1", deleted: true },
        { userId: "cy", roomId: "", deleted: false },
      ],
    });
    expect(lines(csv)).toEqual([
      "Time,User ID,Message,Room,Deleted",
      '"Jan 5 2030, 6:05PM",ada,"Hello, all",Room 1,false',
      `"Jan 5 2030, 6:06PM",bob,${emotionEmoji("heart")},Main room,true`,
      ",cy,,Main room,false",
    ]);
  });
});

describe("pollsSuggestionsCsv", () => {
  it("lists suggestions then polls, naming the prompt each suggestion answered", () => {
    const csv = pollsSuggestionsCsv({
      eventId: "e1",
      rooms,
      prompts: new Map([["a1", "Ideas?"]]),
      suggestions: [
        { createdAt: local(2030, 0, 5, 18, 10), userId: "ada", agendaItemId: "a1", message: "More tea", roomId: "r2", upvotes: 3, downvotes: 0, deleted: false },
        { userId: "bob", agendaItemId: "unknown", message: "Coffee", roomId: "", deleted: true },
      ],
      polls: [{ answeredAt: local(2030, 0, 5, 18, 20), userId: "cy", question: "Ready?", response: "Yes", roomId: "waiting-room" }],
    });
    expect(lines(csv)).toEqual([
      "Type,Time,User ID,Prompt,Response,Room,Upvotes,Downvotes,Deleted",
      'Suggestion,"Jan 5 2030, 6:10PM",ada,Ideas?,More tea,Room 2,3,0,false',
      "Suggestion,,bob,,Coffee,Main room,,,true",
      'Poll,"Jan 5 2030, 6:20PM",cy,Ready?,Yes,Waiting room,,,false',
    ]);
  });
});

describe("emotionEmoji", () => {
  it("has an emoji for every emotion", () => {
    expect(emotionEmoji("thumbsUp")).toBe("👍");
    expect(emotionEmoji("heartEyes")).toBe("😍");
  });
});
