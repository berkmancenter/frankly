import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import type { Event, PrePostCard } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { useUserEmail } from "@/queries/tags";
import { useCurrentUserId } from "@/queries/me";
import { freeText, wrapAnywhere } from "@/theme/freeText";
import { colors } from "@/theme/tokens";
import { finalLink } from "@/utils/prePost";

// A card's headline, message and the buttons that open its links, with the participant's details added.
export function PrePostCardView({
  event,
  card,
  onDone,
}: {
  // Absent on a template, where there is no one to build links for yet.
  event?: Pick<Event, "id" | "communityId">;
  card: PrePostCard;
  onDone?: () => void;
}) {
  const { t } = useLingui();
  const meId = useCurrentUserId();
  const email = useUserEmail(meId ?? "", event?.communityId, !!meId && !!event).data;

  const open = (url: string) => window.open(url, "_blank", "noopener,noreferrer");
  const links = card.links.flatMap((link) => {
    const url = finalLink(link, { userId: meId, eventId: event?.id ?? "", email });
    return url ? [{ url, text: link.buttonText?.trim() || t({ id: "openLink", message: "Open Link" }) }] : [];
  });

  return (
    <Box sx={{ display: "flex", flexDirection: "column", gap: "10px", alignItems: "flex-start" }}>
      {card.headline && (
        <Typography component="h3" sx={{ fontSize: 20, fontWeight: 500, ...wrapAnywhere }}>
          {card.headline}
        </Typography>
      )}
      {card.message && (
        <Typography sx={{ color: colors.onSurfaceVariant, ...freeText }}>
          {card.message}
        </Typography>
      )}
      <Box sx={{ display: "flex", gap: "8px", flexWrap: "wrap", justifyContent: "space-between", width: "100%", pt: "10px" }}>
        {onDone && (
          <ActionButton type="outline" onPress={onDone}>
            {links.length > 0 ? t({ id: "close", message: "Close" }) : t({ id: "next", message: "Next" })}
          </ActionButton>
        )}
        <Box sx={{ display: "flex", gap: "8px", flexWrap: "wrap" }}>
          {links.map(({ url, text }) => (
            <ActionButton key={url} onPress={() => open(url)}>
              {text}
            </ActionButton>
          ))}
        </Box>
      </Box>
    </Box>
  );
}
