import { useLingui } from "@lingui/react/macro";
import type { AgendaItemType } from "@/api/types";

// The name of each kind of agenda step.
export function useAgendaTypeLabel() {
  const { t } = useLingui();
  return (type: AgendaItemType): string => {
    switch (type) {
      case "text":
        return t({ id: "agendaTypeText", message: "Text" });
      case "video":
        return t({ id: "video", message: "Video" });
      case "image":
        return t({ id: "image", message: "Image" });
      case "poll":
        return t({ id: "agendaTypePoll", message: "Poll" });
      case "wordCloud":
        return t({ id: "wordCloud", message: "Word Cloud" });
      case "userSuggestions":
        return t({ id: "suggestions", message: "Suggestions" });
    }
  };
}
