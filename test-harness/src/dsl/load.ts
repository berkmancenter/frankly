import { readFileSync } from "node:fs";
import { parse } from "yaml";
import type { z } from "zod";
import { Simulation } from "./schema.ts";

export class SimulationDefinitionError extends Error {
  constructor(
    readonly source: string,
    readonly issues: string[],
  ) {
    super(
      `Invalid simulation definition in ${source}:\n  ${issues.join("\n  ")}`,
    );
  }
}

/** Validates already-parsed data and returns a typed simulation with defaults. */
export function parseSimulation(data: unknown, source = "<input>"): Simulation {
  const result = Simulation.safeParse(data);
  if (!result.success) {
    throw new SimulationDefinitionError(source, formatIssues(result.error));
  }
  return result.data;
}

/** Reads a YAML simulation definition from disk and validates it. */
export function loadSimulation(path: string): Simulation {
  let data: unknown;
  try {
    data = parse(readFileSync(path, "utf8"));
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    throw new SimulationDefinitionError(path, [`Could not read YAML: ${message}`]);
  }
  return parseSimulation(data, path);
}

function formatIssues(error: z.ZodError): string[] {
  return error.issues.map((issue) => {
    const path = issue.path.length > 0 ? issue.path.join(".") : "(root)";
    return `${path}: ${issue.message}`;
  });
}
