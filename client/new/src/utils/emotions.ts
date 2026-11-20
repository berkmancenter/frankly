import type { EmotionType } from "@/api/types";

const EMOJI: Record<EmotionType, string> = {
  thumbsUp: "👍",
  heart: "❤️",
  hundred: "💯",
  exclamation: "‼️",
  plusOne: "➕",
  laughWithTears: "😂",
  heartEyes: "😍",
};

export const emotionEmoji = (emotion: EmotionType): string => EMOJI[emotion];
