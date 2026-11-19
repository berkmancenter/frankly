import type { Event, PrePostCard } from "@/api/types";
import { AppDialog } from "@/components/AppDialog";
import { PrePostCardView } from "@/features/content/PrePostCardView";

// Shown once, right after someone signs up, when the host left them a message or links.
export function PrePostEventDialog({ event, card, onClose }: { event: Event; card: PrePostCard; onClose: () => void }) {
  return (
    <AppDialog open onClose={onClose} maxWidth={700} padding={40}>
      <PrePostCardView event={event} card={card} onDone={onClose} />
    </AppDialog>
  );
}
