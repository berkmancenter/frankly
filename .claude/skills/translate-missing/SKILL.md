---
name: translate-missing
description: Fill in missing translations (empty msgstr) in the Lingui PO catalogs under client/new/src/locales for es, zh and zh-Hant-TW. Use when asked to translate untranslated or missing strings.
---

Translate every untranslated message in `client/new/src/locales/{es,zh,zh-Hant-TW}/messages.po`. English (`en`) is the source locale.

## Find what is missing
A message is missing when its `msgstr` is `""` with no continuation line, in a non-`en` catalog. Skip:
- the header entry (empty `msgid`) and obsolete entries (lines starting `#~`)
- already-translated entries, which you must never change

Source text: if the entry has `#. js-lingui-explicit-id`, the msgid is a key, so use the same msgid's `msgstr` in `en/messages.po`. Otherwise the msgid is the English text. If an explicit-id entry has no English text, skip it and report it. Other `#.` lines are translator context; use them.

## Translate
- Messages are ICU MessageFormat. Keep every `{variable}`, `<0>…</0>` tag, `#`, and ICU keyword (`plural`, `select`, `one`, `other`, `=0`) exactly as written; translate only the human-readable text.
- Preserve leading/trailing whitespace and punctuation; some strings are fragments concatenated in code.
- Keep "Frankly" and other brand names untranslated.
- Friendly, clear, inclusive tone; informal register where the language has one.
- Locales: `es` = neutral Latin American Spanish; `zh` = Simplified Chinese; `zh-Hant-TW` = Traditional Chinese as used in Taiwan.

## Apply
Do not make hundreds of individual Edit calls. Write a throwaway script in the scratchpad directory (never in the repo) that takes a JSON map of msgid to translation per locale and rewrites only the matching `msgstr` lines in place, escaping `\`, `"` and newlines. Process in batches of ~40 messages per locale to keep quality high.

## Verify
Re-run the missing-entry search: each locale should have zero missing (except reported skips). Check that each translation's placeholders match its source. Then report counts per locale and anything skipped. Suggest running `npm run locales:compile`-equivalent (`lingui compile`) if the user wants the `.js` catalogs refreshed. Do not commit.
