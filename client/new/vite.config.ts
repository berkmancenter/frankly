/// <reference types="vitest/config" />
import { fileURLToPath, URL } from "node:url";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";
import { lingui } from "@lingui/vite-plugin";
import migrated from "./migrated-routes.json";

// Standalone (`npm run dev`) serves from "/". Behind the dev proxy (`npm run dev:proxied`,
// `npm run build:proxied`) every asset URL — module graph, HMR socket, chunks — lives under
// `assetBase` from migrated-routes.json, which is how the proxy tells React's files from
// Flutter's. Page URLs themselves never carry the prefix.
const base = process.env.PROXIED === "1" ? migrated.assetBase : "/";

export default defineConfig({
  base,
  plugins: [react(), lingui({ macroTransform: true })],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
  server: {
    port: 5173,
    // The proxy's upstream address is fixed, so fail loudly rather than drift to 5174.
    strictPort: true,
  },
  build: {
    // The Firebase vendor chunk is ~515 kB (Auth + Firestore, needed on every page) and cannot be
    // split usefully; the limit sits just above it so any other chunk growing still warns.
    chunkSizeWarningLimit: 600,
    rollupOptions: {
      output: {
        // Long-lived vendor chunks: app code changes far more often than these.
        manualChunks(id) {
          // Function form (not the object form) so transitive deps such as
          // react/jsx-runtime land in the react chunk; the object form left them
          // in a circular chunk with mui and broke it at load time.
          if (!id.includes("node_modules")) return undefined;
          if (
            /node_modules\/(react|react-dom|react-router|scheduler)\//.test(id)
          )
            return "react";
          if (/node_modules\/(@mui|@emotion)\//.test(id)) return "mui";
          if (/node_modules\/(firebase|@firebase)\//.test(id))
            return "firebase";
          if (/node_modules\/(@tanstack|xstate|@xstate)\//.test(id))
            return "state";
          return undefined;
        },
      },
    },
  },
  test: {
    // Machines are plain TypeScript and run in node; tests that need a DOM opt in to jsdom
    // with a `// @vitest-environment jsdom` docblock.
    environment: "node",
    include: ["src/**/*.test.{ts,tsx}"],
    setupFiles: ["src/__tests__/support/setup.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "json-summary"],
    },
  },
});
