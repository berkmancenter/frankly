import { z } from "zod";

// Define the simulation DSL. Types are inferred from these schemas, and the
// loader validates files against them.

export const UserProfile = z.object({
  name: z.string().min(1),
  role: z.enum(["host", "participant"]).default("participant"),
});

export const Bot = z.object({
  id: z.string().min(1),
  user: UserProfile,
  camera: z.boolean().default(false),
  microphone: z.boolean().default(false),
});

export const MeetingSettings = z.object({
  breakouts: z
    .object({
      roomSize: z.number().int().positive(),
    })
    .optional(),
});

export const Simulation = z
  .object({
    scenario: z.string().min(1),
    meeting: MeetingSettings.default({}),
    bots: z.array(Bot).min(1),
  })
  // Ensures unique bot ids
  .superRefine((run, ctx) => {
    const seen = new Set<string>();
    run.bots.forEach((bot, index) => {
      if (seen.has(bot.id)) {
        ctx.addIssue({
          code: "custom",
          path: ["bots", index, "id"],
          message: `Duplicate bot id "${bot.id}"`,
        });
      }
      seen.add(bot.id);
    });
  });

export type UserProfile = z.infer<typeof UserProfile>;
export type Bot = z.infer<typeof Bot>;
export type MeetingSettings = z.infer<typeof MeetingSettings>;
export type Simulation = z.infer<typeof Simulation>;
