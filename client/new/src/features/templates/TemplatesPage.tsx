import SearchIcon from "@mui/icons-material/Search";
import TuneIcon from "@mui/icons-material/Tune";
import Box from "@mui/material/Box";
import Chip from "@mui/material/Chip";
import InputAdornment from "@mui/material/InputAdornment";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useMemo, useState } from "react";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { EmptyPageContent } from "@/components/EmptyPageContent";
import { TemplateCard } from "@/components/TemplateCard";
import { ErrorState, LoadingState } from "@/components/States";
import { useTemplateTags } from "@/queries/tags";
import { useTemplates } from "@/queries/templates";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors } from "@/theme/tokens";
import { filterTemplates, templateCategories } from "@/utils/templateSearch";

// Templates shown at first, and added by each "View more".
const PAGE_SIZE = 30;

/**
 * `/space/:displayId/discuss`: every active template of the community as a card, with a search box
 * and category filter. A card opens the template's page, which is not migrated yet.
 */
export function TemplatesPage() {
  const { t } = useLingui();
  const { community } = useCommunityScope();
  const templates = useTemplates(community.id);
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState<string>();
  const [tagId, setTagId] = useState<string>();
  const [shown, setShown] = useState(PAGE_SIZE);

  const active = useMemo(
    () => (templates.data ?? []).filter((template) => template.status === "active"),
    [templates.data],
  );
  const categories = useMemo(() => templateCategories(active), [active]);
  // Tags are a nicety: if they fail to load the page works without the filter.
  const templateTags = useTemplateTags(community.id).data;
  const tags = useMemo(() => {
    const activeIds = new Set(active.map((template) => template.id));
    const byId = new Map<string, { id: string; title: string }>();
    for (const { templateId, tag } of templateTags ?? []) {
      if (activeIds.has(templateId)) byId.set(tag.id, tag);
    }
    return [...byId.values()].sort((a, b) => a.title.localeCompare(b.title));
  }, [active, templateTags]);
  const matching = useMemo(() => {
    const found = filterTemplates(active, query, category);
    if (!tagId) return found;
    const tagged = new Set(
      (templateTags ?? []).filter(({ tag }) => tag.id === tagId).map(({ templateId }) => templateId),
    );
    return found.filter((template) => tagged.has(template.id));
  }, [active, query, category, tagId, templateTags]);

  return (
    <Box component="main" sx={{ pt: "30px", pb: "80px" }}>
      <ConstrainedBody>
        <Box sx={{ width: "100%" }}>
          {templates.isPending ? (
            <LoadingState height={400} />
          ) : templates.isError ? (
            <ErrorState
              message={t({
                id: "thereWasAnErrorLoadingEventTemplates",
                message: "There was an error loading event templates.",
              })}
            />
          ) : active.length === 0 ? (
            <Box sx={{ pt: "30px", display: "flex", justifyContent: "center" }}>
              <EmptyPageContent type="templates" showContainer={false} />
            </Box>
          ) : (
            <>
              <TextField
                fullWidth
                value={query}
                onChange={(event) => {
                  setQuery(event.target.value);
                  setShown(PAGE_SIZE);
                }}
                label={t({ id: "searchTemplates", message: "Search templates" })}
                sx={{ maxWidth: 450, mb: "12px" }}
                slotProps={{
                  input: {
                    startAdornment: (
                      <InputAdornment position="start">
                        <SearchIcon />
                      </InputAdornment>
                    ),
                  },
                }}
              />
              {categories.length > 0 && (
                <Box sx={{ display: "flex", flexWrap: "wrap", gap: "4px", mb: "20px" }}>
                  {categories.map((name) => (
                    <Chip
                      key={name}
                      label={name}
                      color={category === name ? "primary" : "default"}
                      aria-pressed={category === name}
                      onClick={() => {
                        setCategory(category === name ? undefined : name);
                        setShown(PAGE_SIZE);
                      }}
                    />
                  ))}
                </Box>
              )}
              {tags.length > 0 && (
                <Box sx={{ display: "flex", alignItems: "center", flexWrap: "wrap", gap: "4px", mb: "20px" }}>
                  <TuneIcon aria-hidden sx={{ mr: "6px" }} />
                  <Typography sx={{ mr: "10px" }}>{t({ id: "filter", message: "Filter" })}</Typography>
                  {tags.map((tag) => (
                    <Chip
                      key={tag.id}
                      label={`#${tag.title}`}
                      variant="outlined"
                      color={tagId === tag.id ? "primary" : "default"}
                      aria-pressed={tagId === tag.id}
                      onClick={() => {
                        setTagId(tagId === tag.id ? undefined : tag.id);
                        setShown(PAGE_SIZE);
                      }}
                    />
                  ))}
                </Box>
              )}
              {matching.length === 0 ? (
                <Typography sx={{ py: "40px", textAlign: "center", color: colors.onSurfaceVariant }}>
                  {t({ id: "noTemplatesFound", message: "No templates found." })}
                </Typography>
              ) : (
                <Box sx={{ display: "flex", flexWrap: "wrap", gap: "14px 8px" }}>
                  {matching.slice(0, shown).map((template) => (
                    <TemplateCard
                      key={template.id}
                      template={template}
                      to={paths.community(community.displayId).template(template.id)}
                    />
                  ))}
                </Box>
              )}
              {shown < matching.length && (
                <Box sx={{ py: "20px", display: "flex", justifyContent: "center" }}>
                  <ActionButton onPress={() => setShown((n) => n + PAGE_SIZE)}>
                    {t({ id: "viewMoreTemplates", message: "View more templates" })}
                  </ActionButton>
                </Box>
              )}
            </>
          )}
        </Box>
      </ConstrainedBody>
    </Box>
  );
}
