/**
 * Converts Flutter's ARB localization files (client/lib/l10n/app_*.arb) into the
 * PO catalogs Lingui reads (src/locales/<locale>/messages.po).
 *
 * ARB messages are already ICU MessageFormat, which is also what Lingui uses, so
 * message bodies are copied verbatim. The ARB key becomes an explicit Lingui
 * message id, and the `@key` description (if any) becomes an extracted comment.
 *
 * Run from client/new with: npm run locales:transpile
 */
import { readdirSync, readFileSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const ARB_DIR = join(here, "../../../lib/l10n");
const SOURCE_LOCALE = "en";

type ArbMeta = { description?: string };
type Arb = Record<string, string | ArbMeta>;

function poEscape(s: string): string {
  return s
    .replace(/\\/g, "\\\\")
    .replace(/"/g, '\\"')
    .replace(/\n/g, "\\n")
    .replace(/\r/g, "\\r")
    .replace(/\t/g, "\\t");
}

function readArb(file: string): Arb {
  return JSON.parse(readFileSync(join(ARB_DIR, file), "utf8")) as Arb;
}

function messageKeys(arb: Arb): string[] {
  return Object.keys(arb).filter((k) => !k.startsWith("@"));
}

function toPo(
  locale: string,
  arb: Arb,
  sourceKeys: string[],
  sourceArb: Arb,
): string {
  const lines: string[] = [
    'msgid ""',
    'msgstr ""',
    '"POT-Creation-Date: \\n"',
    '"MIME-Version: 1.0\\n"',
    '"Content-Type: text/plain; charset=utf-8\\n"',
    '"Content-Transfer-Encoding: 8bit\\n"',
    '"X-Generator: flutterTranspile.ts\\n"',
    `"Language: ${locale}\\n"`,
    "",
  ];

  for (const key of sourceKeys) {
    const meta = sourceArb[`@${key}`] as ArbMeta | undefined;
    if (meta?.description) {
      for (const d of meta.description.split("\n")) lines.push(`#. ${d}`);
    }
    lines.push("#. js-lingui-explicit-id");
    lines.push(`msgid "${poEscape(key)}"`);
    // Untranslated keys get an empty msgstr; Lingui falls back to the source locale.
    const value = arb[key];
    lines.push(`msgstr "${typeof value === "string" ? poEscape(value) : ""}"`);
    lines.push("");
  }

  return lines.join("\n");
}

const files = readdirSync(ARB_DIR).filter((f) => /^app_.+\.arb$/.test(f));
const arbs = new Map<string, Arb>();
for (const file of files) {
  const arb = readArb(file);
  const locale = (arb["@@locale"] as string | undefined) ?? file.slice(4, -4);
  arbs.set(locale, arb);
}

const sourceArb = arbs.get(SOURCE_LOCALE);
if (!sourceArb)
  throw new Error(`Missing source locale ${SOURCE_LOCALE} in ${ARB_DIR}`);
const sourceKeys = messageKeys(sourceArb).sort();

for (const [locale, arb] of arbs) {
  // Special case zh_Hant_TW to zh-Hant-TW
  const localeKey = locale === "zh_Hant_TW" ? "zh-Hant-TW" : locale;
  const outDir = join(here, locale);
  mkdirSync(outDir, { recursive: true });
  writeFileSync(
    join(outDir, "messages.po"),
    toPo(localeKey, arb, sourceKeys, sourceArb),
  );

  const missing = sourceKeys.filter((k) => typeof arb[k] !== "string").length;
  console.log(
    `${locale}: ${sourceKeys.length - missing}/${sourceKeys.length} translated -> ${locale}/messages.po`,
  );
}
