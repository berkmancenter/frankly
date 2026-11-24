import type {
  BreakoutRoomRecord,
  ChatRecord,
  PollRecord,
  RegistrantRecord,
  SuggestionRecord,
} from "@/api/types";
import { toCsv } from "@/utils/csv";
import { emotionEmoji } from "@/utils/emotions";

/* eslint-disable lingui/no-unlocalized-strings -- the layout of exported files, which is not translated */

export const registrationFileName = (eventId: string) => `registration-data-${eventId}.csv`;
export const chatFileName = (eventId: string) => `chat-data-${eventId}.csv`;
export const pollsSuggestionsFileName = (eventId: string) => `polls-suggestions-data-${eventId}.csv`;

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

// `Jan 5 2030, 6:00PM`, in the viewer's time zone.
export function formatStamp(iso: string | undefined): string {
  if (!iso) return "";
  const date = new Date(iso);
  const hour = date.getHours() % 12 || 12;
  const minute = String(date.getMinutes()).padStart(2, "0");
  return `${MONTHS[date.getMonth()]} ${date.getDate()} ${date.getFullYear()}, ${hour}:${minute}${date.getHours() < 12 ? "AM" : "PM"}`;
}

// `2030-01-05 18:00:00 UTC`
export function formatUtcStamp(iso: string | undefined): string {
  if (!iso) return "";
  return `${new Date(iso).toISOString().slice(0, 19).replace("T", " ")} UTC`;
}

// A spreadsheet runs text that starts like a formula, so such text gets a leading quote.
export function sanitizeCell(value: unknown): unknown {
  if (typeof value !== "string" || value === "") return value;
  return /^[\t\r]/.test(value) || /^[=+\-@]/.test(value.trim()) ? `'${value}` : value;
}

const sanitizeRows = (rows: unknown[][]) => rows.map((row) => row.map(sanitizeCell));

// Where a message or person was: a named breakout room, the waiting room, or the main room.
export function roomName(roomId: string, eventId: string, rooms: readonly BreakoutRoomRecord[]): string {
  if (!roomId || roomId === eventId) return "Main room";
  if (roomId === "waiting-room") return "Waiting room";
  return rooms.find((room) => room.roomId === roomId)?.roomName ?? "Main room";
}

export function registrationCsv({
  registrants,
  rooms,
  eventId,
  questionTitles,
}: {
  registrants: readonly RegistrantRecord[];
  rooms: readonly BreakoutRoomRecord[];
  eventId: string;
  /** The event's sign-up questions, in order. */
  questionTitles: readonly string[];
}): string {
  const header: unknown[] = [
    "User ID",
    "Name",
    "Email",
    "Member Status",
    "RSVP Time",
    "Join Time",
    "Last Active Time",
    "Room Assigned",
    // Each answer follows its question, so the question text is visible next to it.
    ...questionTitles.flatMap((_, index) => [`Question ${index + 1}`, `Answer ${index + 1}`]),
  ];
  const rows = registrants.map((person) => {
    // The person's own record of their room is cleared when they leave, so look in the rooms.
    const room = rooms.find((candidate) => candidate.participantIds.includes(person.userId));
    return [
      person.userId,
      person.displayName,
      person.email,
      person.memberStatus,
      formatUtcStamp(person.registeredAt),
      formatStamp(person.firstPresentAt),
      formatUtcStamp(person.lastPresentAt),
      room ? roomName(room.roomId, eventId, rooms) : "Main room",
      ...questionTitles.flatMap((title, index) => [title, person.answers[index] ?? ""]),
    ];
  });
  return toCsv(sanitizeRows([header, ...rows]));
}

export function chatCsv({
  messages,
  rooms,
  eventId,
}: {
  messages: readonly ChatRecord[];
  rooms: readonly BreakoutRoomRecord[];
  eventId: string;
}): string {
  const rows = messages.map((message) => [
    formatStamp(message.createdAt),
    message.userId,
    message.message ?? (message.emotion ? emotionEmoji(message.emotion) : ""),
    roomName(message.roomId, eventId, rooms),
    message.deleted,
  ]);
  return toCsv(sanitizeRows([["Time", "User ID", "Message", "Room", "Deleted"], ...rows]));
}

export function pollsSuggestionsCsv({
  suggestions,
  polls,
  rooms,
  eventId,
  /** Titles (or text) of the agenda steps, by id, naming what each suggestion answered. */
  prompts,
}: {
  suggestions: readonly SuggestionRecord[];
  polls: readonly PollRecord[];
  rooms: readonly BreakoutRoomRecord[];
  eventId: string;
  prompts: ReadonlyMap<string, string>;
}): string {
  const header = ["Type", "Time", "User ID", "Prompt", "Response", "Room", "Upvotes", "Downvotes", "Deleted"];
  const suggestionRows = suggestions.map((item) => [
    "Suggestion",
    formatStamp(item.createdAt),
    item.userId,
    (item.agendaItemId && prompts.get(item.agendaItemId)) || "",
    item.message,
    roomName(item.roomId, eventId, rooms),
    item.upvotes ?? "",
    item.downvotes ?? "",
    item.deleted,
  ]);
  // Votes and deletion mean nothing for a poll answer.
  const pollRows = polls.map((poll) => [
    "Poll",
    formatStamp(poll.answeredAt),
    poll.userId,
    poll.question,
    poll.response,
    roomName(poll.roomId, eventId, rooms),
    "",
    "",
    false,
  ]);
  return toCsv(sanitizeRows([header, ...suggestionRows, ...pollRows]));
}
/* eslint-enable lingui/no-unlocalized-strings */
