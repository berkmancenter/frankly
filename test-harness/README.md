# Frankly test harness

Describes multi-user meeting scenarios for testing the Frankly app.

```sh
cd test-harness
pnpm install
pnpm harness:typecheck
pnpm harness:test
```

## Simulations

A simulation describes who takes part in a run and how the meeting is set up,
not what anyone does. Simulation files live in `simulations/` as YAML. The
schemas in `src/dsl/schema.ts` define what a file may contain, and
`src/dsl/load.ts` validates a file and returns typed objects:

```ts
import { loadSimulation } from "./src/dsl/load.ts";

const simulation = loadSimulation("simulations/breakouts-8.yaml");
```

An invalid file fails with the path of each bad field, for example
`meeting.breakouts.roomSize: Invalid input: expected number, received string`.
