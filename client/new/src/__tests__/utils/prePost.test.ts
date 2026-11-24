import { describe, expect, it } from "vitest";
import { cardHasData, emptyCard, finalLink } from "@/utils/prePost";

const who = { userId: "u1", eventId: "e1", email: "a@b.co" };

describe("cardHasData", () => {
  it("is false for nothing, or blanks", () => {
    expect(cardHasData(undefined)).toBe(false);
    expect(cardHasData(emptyCard())).toBe(false);
    expect(cardHasData({ headline: " ", message: "", links: [{ url: " ", attributes: [] }] })).toBe(false);
  });
  it("is true for a headline, a message or a link", () => {
    expect(cardHasData({ ...emptyCard(), headline: "Hi" })).toBe(true);
    expect(cardHasData({ ...emptyCard(), message: "Hi" })).toBe(true);
    expect(cardHasData({ ...emptyCard(), links: [{ url: "https://x.co", attributes: [] }] })).toBe(true);
  });
});

describe("finalLink", () => {
  it("adds the chosen details, under the host's names", () => {
    const link = {
      url: "https://forms.example/s?lang=en",
      attributes: [
        { type: "userId" as const, queryParam: "uid" },
        { type: "email" as const, queryParam: "" },
      ],
    };
    expect(finalLink(link, who)).toBe("https://forms.example/s?lang=en&uid=u1&email=a%40b.co");
  });
  it("gives a bare address https, and refuses anything that is not a web link", () => {
    expect(finalLink({ url: "forms.example", attributes: [] }, who)).toBe("https://forms.example/");
    expect(finalLink({ url: "javascript:alert(1)", attributes: [] }, who)).toBeUndefined();
    expect(finalLink({ attributes: [] }, who)).toBeUndefined();
  });
});
