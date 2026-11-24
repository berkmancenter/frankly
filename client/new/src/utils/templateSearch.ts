import type { Template } from "@/api/types";

/** Distinct, non-empty categories in the order they first appear. */
export function templateCategories(templates: Template[]): string[] {
  return [
    ...new Set(
      templates.map((t) => t.category).filter((c): c is string => !!c),
    ),
  ];
}

/**
 * The templates matching a search and an optional category, best matches first: titles that start
 * with the query, then titles that contain it, then categories that contain it.
 * An empty query matches everything, in the given order.
 */
export function filterTemplates(
  templates: Template[],
  query: string,
  category?: string,
): Template[] {
  const needle = query.trim().toLowerCase();
  const inCategory = (t: Template) => !category || t.category === category;
  if (!needle) return templates.filter(inCategory);

  const title = (t: Template) => t.title.toLowerCase();
  const startsWith = templates.filter((t) => title(t).startsWith(needle));
  const contains = templates.filter(
    (t) => !title(t).startsWith(needle) && title(t).includes(needle),
  );
  const byCategory = templates.filter(
    (t) =>
      !title(t).includes(needle) &&
      (t.category ?? "").toLowerCase().includes(needle),
  );
  return [...startsWith, ...contains, ...byCategory].filter(inCategory);
}
