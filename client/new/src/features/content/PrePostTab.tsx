import CloseIcon from "@mui/icons-material/Close";
import CheckIcon from "@mui/icons-material/Check";
import DeleteIcon from "@mui/icons-material/DeleteOutlined";
import EditIcon from "@mui/icons-material/Edit";
import ExpandLessIcon from "@mui/icons-material/ExpandLess";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import Box from "@mui/material/Box";
import Checkbox from "@mui/material/Checkbox";
import FormControlLabel from "@mui/material/FormControlLabel";
import IconButton from "@mui/material/IconButton";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState, type ReactNode } from "react";
import {
  PRE_POST_ATTRIBUTES,
  type PrePostAttribute,
  type PrePostCard,
  type PrePostLink,
} from "@/api/types";
import { AddMoreButton } from "@/components/AddMoreButton";
import { useConfirm } from "@/components/ConfirmDialog";
import { useToast } from "@/components/Toast";
import { wrapAnywhere } from "@/theme/freeText";
import { colors } from "@/theme/tokens";
import { cardHasData, emptyCard, finalLink } from "@/utils/prePost";
import { PrePostCardView } from "./PrePostCardView";

export type PrePostWhich = "pre" | "post";

// Stand-ins for the participant's details in the preview of a link.
/* eslint-disable lingui/no-unlocalized-strings */
const PREVIEW_WHO = (eventId: string) => ({
  userId: "{userId}",
  eventId,
  email: "{email}",
});
/* eslint-enable lingui/no-unlocalized-strings */

interface Props {
  pre: PrePostCard | undefined;
  post: PrePostCard | undefined;
  canEdit: boolean;
  /** Saves a card; `null` removes it. */
  onSave: (which: PrePostWhich, card: PrePostCard | null) => Promise<unknown>;
  /** Set on an event: the id (and community) that links are built for. Templates have none. */
  event?: { id: string; communityId: string };
  /** More sections for the top of the tab, such as the prerequisite. */
  children?: ReactNode;
}

// The CTAs tab, for an event or a template: the card people see after signing up and the one after the event.
// Editors see an "add" button for each card that does not exist yet; everyone else only sees cards with something in them.
export function PrePostTab({
  pre,
  post,
  canEdit,
  onSave,
  event,
  children,
}: Props) {
  const { t } = useLingui();
  const sections: {
    which: PrePostWhich;
    card: PrePostCard | undefined;
    add: string;
  }[] = [
    {
      which: "pre",
      card: pre,
      add: t({ id: "addPreEvent", message: "Add Pre-event" }),
    },
    {
      which: "post",
      card: post,
      add: t({ id: "addPostEvent", message: "Add Post-event" }),
    },
  ];
  return (
    <Box
      sx={{ display: "flex", flexDirection: "column", gap: "20px", pt: "24px" }}
    >
      {children}
      {sections.map(({ which, card, add }) => {
        if (!canEdit && !cardHasData(card)) return null;
        if (!card)
          return (
            <AddMoreButton
              key={which}
              label={add}
              onPress={() => onSave(which, emptyCard())}
            />
          );
        return (
          <CardPanel
            key={which}
            which={which}
            card={card}
            canEdit={canEdit}
            onSave={onSave}
            event={event}
          />
        );
      })}
    </Box>
  );
}

// A card with its title bar: collapse, switch between reading and editing, and delete.
function CardPanel({
  which,
  card,
  canEdit,
  onSave,
  event,
}: { which: PrePostWhich; card: PrePostCard; canEdit: boolean } & Pick<
  Props,
  "onSave" | "event"
>) {
  const { t } = useLingui();
  const toast = useToast();
  const { confirm, dialog } = useConfirm();
  const isNew = JSON.stringify(card) === JSON.stringify(emptyCard());
  const [expanded, setExpanded] = useState(true);
  const [editing, setEditing] = useState(canEdit && isNew);

  const title =
    which === "pre"
      ? t({ id: "preEvent", message: "Pre-event" })
      : t({ id: "postEvent", message: "Post-event" });
  const onDelete = async () => {
    const yes = await confirm({
      title:
        which === "pre"
          ? t({ id: "deletePreEventItem", message: "Delete Pre-Event Item" })
          : t({ id: "deletePostEventItem", message: "Delete Post-Event Item" }),
      mainText:
        which === "pre"
          ? t({
              id: "confirmDeletePreEventItem",
              message:
                "Are you sure you want to delete this pre-event agenda item? This action cannot be undone.",
            })
          : t({
              id: "confirmDeletePostEventItem",
              message:
                "Are you sure you want to delete this post-event agenda item? This action cannot be undone.",
            }),
      confirmText: t({ id: "delete", message: "Delete" }),
      cancelText: t({ id: "cancel", message: "Cancel" }),
      destructive: true,
    });
    if (yes)
      await onSave(which, null).catch(() =>
        toast.error(t`Something went wrong. Please try again.`),
      );
  };

  return (
    <Box
      component="section"
      sx={{
        border: 1,
        borderColor: colors.outline,
        borderRadius: "20px",
        p: "20px",
        bgcolor: colors.surfaceContainerLowest,
      }}
    >
      <Box sx={{ display: "flex", alignItems: "center", gap: "4px" }}>
        <Typography
          component="h3"
          sx={{ flex: 1, fontSize: 20, fontWeight: 500 }}
        >
          {title}
        </Typography>
        {canEdit && (
          <>
            {!editing && (
              <IconButton
                aria-label={t({ id: "deleteCard", message: "Delete card" })}
                onClick={onDelete}
              >
                <DeleteIcon />
              </IconButton>
            )}
            <IconButton
              aria-label={
                editing
                  ? t({ id: "viewCard", message: "View card" })
                  : t({ id: "editCard", message: "Edit card" })
              }
              onClick={() => {
                setExpanded(true);
                setEditing(!editing);
              }}
            >
              {editing ? <CloseIcon /> : <EditIcon />}
            </IconButton>
          </>
        )}
        <IconButton
          aria-label={
            expanded
              ? t({ id: "collapseCard", message: "Collapse" })
              : t({ id: "expandCard", message: "Expand" })
          }
          aria-expanded={expanded}
          onClick={() => setExpanded(!expanded)}
        >
          {expanded ? <ExpandLessIcon /> : <ExpandMoreIcon />}
        </IconButton>
      </Box>
      {expanded && (
        <Box sx={{ pt: "20px" }}>
          {canEdit && editing ? (
            <CardEditor
              key={JSON.stringify(card)}
              which={which}
              saved={card}
              eventId={event?.id ?? ""}
              onDelete={onDelete}
              onSave={async (next) => {
                await onSave(which, next);
                setEditing(false);
              }}
            />
          ) : event ? (
            <PrePostCardView event={event} card={card} />
          ) : (
            <PrePostCardView card={card} />
          )}
        </Box>
      )}
      {dialog}
    </Box>
  );
}

function CardEditor({
  which,
  saved,
  eventId,
  onSave,
  onDelete,
}: {
  which: PrePostWhich;
  saved: PrePostCard;
  eventId: string;
  onSave: (card: PrePostCard) => Promise<unknown>;
  onDelete: () => unknown;
}) {
  const { t } = useLingui();
  const toast = useToast();
  const [card, setCard] = useState<PrePostCard>(saved);
  const dirty = JSON.stringify(card) !== JSON.stringify(saved);

  const setLink = (index: number, link: PrePostLink) =>
    setCard((current) => ({
      ...current,
      links: current.links.map((existing, i) =>
        i === index ? link : existing,
      ),
    }));

  const message =
    which === "pre"
      ? t({
          id: "enterMessageExampleBefore",
          message: 'Enter message (e.g. "Take this survey before the event")',
        })
      : t({
          id: "enterMessageExampleAfter",
          message: 'Enter message (e.g. "Take this survey after the event")',
        });
  const addLinks =
    which === "pre"
      ? t({
          id: "addActionLinksBefore",
          message:
            "Add action links participants should visit before the event",
        })
      : t({
          id: "addActionLinksAfter",
          message: "Add action links participants should visit after the event",
        });

  const save = async () => {
    try {
      await onSave(card);
      toast.success(t({ id: "cardSaved", message: "Saved" }));
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  return (
    <Box sx={{ display: "flex", flexDirection: "column", gap: "16px" }}>
      <TextField
        label={t({ id: "enterHeadline", message: "Enter Headline" })}
        value={card.headline}
        onChange={(change) =>
          setCard({ ...card, headline: change.target.value })
        }
      />
      <TextField
        label={message}
        value={card.message}
        multiline
        minRows={3}
        onChange={(change) =>
          setCard({ ...card, message: change.target.value })
        }
      />
      <Typography sx={{ color: colors.onSurfaceVariant }}>
        {addLinks}
      </Typography>
      {card.links.map((link, index) => (
        <Box
          key={index}
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: "10px",
            border: 1,
            borderColor: colors.outlineVariant,
            borderRadius: "10px",
            p: "14px",
          }}
        >
          <Box sx={{ display: "flex", justifyContent: "flex-end" }}>
            <IconButton
              size="small"
              aria-label={t({
                id: "removeActionLink",
                message: "Remove action link",
              })}
              onClick={() =>
                setCard({
                  ...card,
                  links: card.links.filter((_, i) => i !== index),
                })
              }
            >
              <CloseIcon fontSize="small" />
            </IconButton>
          </Box>
          <TextField
            size="small"
            label={t({ id: "buttonText", message: "Button Text" })}
            value={link.buttonText ?? ""}
            onChange={(change) =>
              setLink(index, { ...link, buttonText: change.target.value })
            }
          />
          <TextField
            size="small"
            label={t({ id: "enterUrl", message: "Enter URL" })}
            value={link.url ?? ""}
            onChange={(change) =>
              setLink(index, { ...link, url: change.target.value })
            }
          />
          <AttributeEditor
            link={link}
            onChange={(next) => setLink(index, next)}
          />
          <Typography
            variant="body2"
            sx={{ color: colors.onSurfaceVariant, ...wrapAnywhere }}
          >
            {t({ id: "urlPreview", message: "URL Preview" })}:{" "}
            {finalLink(link, PREVIEW_WHO(eventId)) ?? ""}
          </Typography>
        </Box>
      ))}
      <AddMoreButton
        label={t({ id: "addActionLink", message: "Add action link" })}
        onPress={() =>
          setCard({ ...card, links: [...card.links, { attributes: [] }] })
        }
      />
      <Box
        sx={{
          display: "flex",
          justifyContent: "flex-end",
          alignItems: "center",
          gap: "20px",
        }}
      >
        <IconButton
          aria-label={t({ id: "deleteCard", message: "Delete card" })}
          onClick={onDelete}
        >
          <DeleteIcon />
        </IconButton>
        {/* Saving is only possible once something changed. */}
        <IconButton
          aria-label={t({ id: "save", message: "Save" })}
          disabled={!dirty}
          onClick={save}
        >
          <CheckIcon />
        </IconButton>
      </Box>
    </Box>
  );
}

const ATTRIBUTE_LABELS = (
  t: ReturnType<typeof useLingui>["t"],
): Record<PrePostAttribute, string> => ({
  userId: t({ id: "attributeParticipantId", message: "Participant ID" }),
  eventId: t({ id: "attributeEventId", message: "Event ID" }),
  email: t({ id: "attributeEmail", message: "Email" }),
});

// Which of the participant's details get added to the link, and under what name.
function AttributeEditor({
  link,
  onChange,
}: {
  link: PrePostLink;
  onChange: (link: PrePostLink) => void;
}) {
  const { t } = useLingui();
  const labels = ATTRIBUTE_LABELS(t);
  return (
    <Box>
      <Typography variant="body2" sx={{ color: colors.onSurfaceVariant }}>
        {t({ id: "addUrlParameter", message: "Add URL Parameter" })}
      </Typography>
      {PRE_POST_ATTRIBUTES.map((type) => {
        const attribute = link.attributes.find(
          (candidate) => candidate.type === type,
        );
        return (
          <Box
            key={type}
            sx={{ display: "flex", alignItems: "center", gap: "10px" }}
          >
            <FormControlLabel
              sx={{ minWidth: 150 }}
              label={labels[type]}
              control={
                <Checkbox
                  checked={!!attribute}
                  onChange={(_change, checked) =>
                    onChange({
                      ...link,
                      attributes: checked
                        ? [...link.attributes, { type, queryParam: type }]
                        : link.attributes.filter(
                            (candidate) => candidate.type !== type,
                          ),
                    })
                  }
                />
              }
            />
            {attribute && (
              <TextField
                size="small"
                aria-label={t({ id: "urlParameter", message: "URL Parameter" })}
                value={attribute.queryParam}
                onChange={(change) =>
                  onChange({
                    ...link,
                    attributes: link.attributes.map((candidate) =>
                      candidate.type === type
                        ? { ...candidate, queryParam: change.target.value }
                        : candidate,
                    ),
                  })
                }
              />
            )}
          </Box>
        );
      })}
    </Box>
  );
}
