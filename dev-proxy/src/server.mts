#!/usr/bin/env node
import { spawn, type ChildProcess } from "node:child_process";
import { fileURLToPath } from "node:url";
import { createProxy } from "./proxy.mjs";
import { loadConfig } from "./rules.mjs";

// This file runs from `dist/`, one level below the dev-proxy folder.
const root = fileURLToPath(new URL("../../", import.meta.url));
const configPath = fileURLToPath(
  new URL("../../client/new/migrated-routes.json", import.meta.url),
);

// Not 4000: that is the Firebase emulator UI's default.
const port = Number(process.env.PORT ?? 3000);
const flutterUrl = process.env.FLUTTER_URL ?? "http://localhost:5000";
const reactUrl = process.env.REACT_URL ?? "http://localhost:5173";
const verbose = true;
const withReact = process.argv.includes("--with-react");

const config = loadConfig(configPath);
const stamp = (): string => new Date().toTimeString().slice(0, 8);
const log = (line: string): void => console.log(`[proxy ${stamp()}] ${line}`);

const server = createProxy({ config, flutterUrl, reactUrl, log, verbose });

let react: ChildProcess | undefined;
if (withReact) {
  // Same port the proxy forwards to, so REACT_URL=http://localhost:5273 just works.
  const reactPort = new URL(reactUrl).port || "5173";
  react = spawn(
    "npm",
    ["--prefix", "client/new", "run", "dev:proxied", "--", "--port", reactPort],
    {
      cwd: root,
      stdio: "inherit",
    },
  );
  react.on("exit", (code) => {
    log(`React dev server exited (${code}); shutting down.`);
    process.exit(code ?? 1);
  });
}

// Wait for Flutter to be ready before starting the proxy
async function waitForFlutter(): Promise<void> {
  let warned = false;
  for (;;) {
    try {
      await fetch(flutterUrl, { signal: AbortSignal.timeout(2000) });
      return;
    } catch {
      if (!warned) {
        log(`Waiting for Flutter at ${flutterUrl}…`);
        warned = true;
      }
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }
}

await waitForFlutter();

log(`Flutter is ready at ${flutterUrl}; starting proxy on port ${port}`);

server.listen(port, () => {
  log(`http://localhost:${port}`);
  log(
    `  React   ${reactUrl}   ← ${config.routes.length} page routes + ${config.assetBase} + ${config.staticPrefixes.join(" ")}`,
  );
  for (const r of config.routes) log(`            ${r}`);
  log(`  Flutter ${flutterUrl}   ← everything else`);
});

server.on("error", (err: NodeJS.ErrnoException) => {
  log(
    err.code === "EADDRINUSE"
      ? `Port ${port} is already in use (set PORT=…).`
      : String(err),
  );
  react?.kill();
  process.exit(1);
});

for (const signal of ["SIGINT", "SIGTERM"] as const) {
  process.on(signal, () => {
    react?.kill(signal);
    server.close();
    process.exit(0);
  });
}
