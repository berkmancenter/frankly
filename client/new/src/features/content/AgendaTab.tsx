import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState, type ReactNode } from "react";
import type { AgendaItem } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AddMoreButton } from "@/components/AddMoreButton";
import { useConfirm } from "@/components/ConfirmDialog";
import { useToast } from "@/components/Toast";
import { colors } from "@/theme/tokens";
import { duplicateOf, newItem } from "@/utils/agenda";
import { useClock } from "@/utils/clock";
import { AgendaStepCard } from "./agenda/AgendaStepCard";

// What the tab can do to the agenda; an event and a template each supply their own.
export interface AgendaActions {
  save: (item: AgendaItem) => Promise<unknown>;
  remove: (itemId: string) => Promise<unknown>;
  reorder: (ids: string[]) => Promise<unknown>;
  clear: () => Promise<unknown>;
}

interface Props {
  items: AgendaItem[];
  canEdit: boolean;
  actions: AgendaActions;
  /** Steps start folded away, so a long agenda reads as a list of titles. */
  startsCollapsed?: boolean;
  /** What sits above the agenda, such as the sign-up questions on an event. */
  above?: ReactNode;
}

// The agenda of an event or a template. Everyone can read it; editors add, edit, duplicate, delete, move and clear steps.
export function AgendaTab({ items, canEdit, actions, startsCollapsed = false, above }: Props) {
  const { t } = useLingui();
  const toast = useToast();
  const clock = useClock();
  const { confirm, dialog } = useConfirm();
  // Steps being written that are not saved yet: a new one, or a copy of an existing one.
  const [unsaved, setUnsaved] = useState<AgendaItem[]>([]);

  const newId = () => String(clock.now().getTime() + unsaved.length);
  const drop = (id: string) => setUnsaved((current) => current.filter((item) => item.id !== id));

  const move = async (index: number, direction: -1 | 1) => {
    const ids = items.map((item) => item.id);
    const target = index + direction;
    if (target < 0 || target >= ids.length) return;
    [ids[index], ids[target]] = [ids[target]!, ids[index]!];
    try {
      await actions.reorder(ids);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : t`Something went wrong. Please try again.`);
    }
  };

  const clearAll = async () => {
    const yes = await confirm({
      title: t({ id: "deleteAllAgendaItems", message: "Delete All Agenda Items" }),
      mainText: t({
        id: "confirmDeleteAllAgendaItems",
        message: "Are you sure you want to delete all agenda items from this event? This action cannot be undone.",
      }),
      confirmText: t({ id: "delete", message: "Delete" }),
      cancelText: t({ id: "cancel", message: "Cancel" }),
      destructive: true,
    });
    if (!yes) return;
    try {
      await actions.clear();
      toast.success(t({ id: "agendaItemsWereRemoved", message: "Agenda items were removed" }));
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  const all = [...items.map((item) => ({ item, saved: true })), ...unsaved.map((item) => ({ item, saved: false }))];
  return (
    <Box sx={{ pt: "24px", display: "flex", flexDirection: "column", gap: "20px" }}>
      {above}
      <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <Typography component="h3" sx={{ fontSize: 22 }}>
          {t({ id: "agendaTitle", message: "Agenda" })}
        </Typography>
        {canEdit && items.length > 0 && (
          <ActionButton type="text" icon={<CloseIcon fontSize="small" />} onPress={clearAll}>
            {t({ id: "clearAll", message: "Clear all" })}
          </ActionButton>
        )}
      </Box>
      {all.length === 0 && (
        <Typography sx={{ color: colors.onSurfaceVariant }}>
          {t({ id: "noAgendaForEvent", message: "There is no agenda for this event." })}
        </Typography>
      )}
      <Box component="ol" sx={{ listStyle: "none", m: 0, p: 0, display: "flex", flexDirection: "column", gap: "20px" }}>
        {all.map(({ item, saved }, index) => (
          <AgendaStepCard
            key={item.id}
            item={item}
            unsaved={!saved}
            canEdit={canEdit}
            startsCollapsed={startsCollapsed}
            canMoveUp={saved && index > 0}
            canMoveDown={saved && index < items.length - 1}
            onSave={async (next) => {
              await actions.save(next);
              drop(item.id);
            }}
            onDelete={async () => {
              if (saved) await actions.remove(item.id);
              else drop(item.id);
            }}
            onDuplicate={() => {
              setUnsaved((current) => [...current, duplicateOf(item, newId())]);
              toast.success(t({ id: "agendaItemWasDuplicated", message: "Agenda item was duplicated!" }));
            }}
            onMove={(direction) => move(index, direction)}
          />
        ))}
      </Box>
      {canEdit && unsaved.length === 0 && (
        <AddMoreButton
          label={t({ id: "addAgendaItem", message: "Add agenda item" })}
          onPress={() => setUnsaved((current) => [...current, newItem(newId())])}
        />
      )}
      {dialog}
    </Box>
  );
}
