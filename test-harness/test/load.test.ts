import { describe, expect, it } from "vitest";
import { fileURLToPath } from "node:url";
import {
  loadSimulation,
  parseSimulation,
  SimulationDefinitionError,
} from "../src/dsl/load.ts";

const simulation = (name: string) =>
  fileURLToPath(new URL(`../simulations/${name}`, import.meta.url));

describe("loadSimulation", () => {
  it("loads the breakout simulation", () => {
    const run = loadSimulation(simulation("breakouts-8.yaml"));
    expect(run.scenario).toBe("breakouts");
    expect(run.bots).toHaveLength(9);
    expect(run.meeting.breakouts?.roomSize).toBe(4);
  });

  it("applies defaults", () => {
    const run = loadSimulation(simulation("breakouts-8.yaml"));
    const participant = run.bots.find((bot) => bot.id === "p1");
    expect(participant?.user.role).toBe("participant");
    expect(participant?.camera).toBe(false);
    expect(participant?.microphone).toBe(false);
  });

  it("reports a missing file clearly", () => {
    expect(() => loadSimulation(simulation("missing.yaml"))).toThrow(
      SimulationDefinitionError,
    );
  });
});

describe("parseSimulation", () => {
  const validBot = { id: "host", user: { name: "Host", role: "host" } };

  it("rejects a wrong type with the field path", () => {
    const definition = {
      scenario: "breakouts",
      meeting: { breakouts: { roomSize: "four" } },
      bots: [validBot],
    };
    expect(() => parseSimulation(definition)).toThrow(
      /meeting\.breakouts\.roomSize/,
    );
  });

  it("rejects an unknown role", () => {
    const definition = {
      scenario: "breakouts",
      bots: [{ id: "a", user: { name: "A", role: "admin" } }],
    };
    expect(() => parseSimulation(definition)).toThrow(/bots\.0\.user\.role/);
  });

  it("rejects a run with no bots", () => {
    expect(() => parseSimulation({ scenario: "breakouts", bots: [] })).toThrow(
      /bots/,
    );
  });

  it("rejects duplicate bot ids", () => {
    const definition = { scenario: "breakouts", bots: [validBot, validBot] };
    expect(() => parseSimulation(definition)).toThrow(/Duplicate bot id "host"/);
  });
});
