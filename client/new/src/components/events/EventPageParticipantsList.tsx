import ButtonBase from "@mui/material/ButtonBase";
import { useLingui } from "@lingui/react/macro";
import type { Event } from "@/api/types";
import { useEventParticipants } from "@/queries/events";
import { isMeetingLive } from "@/utils/participants";
import { ParticipantsRow } from "./ParticipantsRow";

interface Props {
  event: Event;
  iconSize?: number;
  maxAvatars?: number;
  // When given, the row is a button (the host and moderators open the full list from it).
  onOpen?: () => void;
}

// Who is going to the event: avatars and a head count, narrowed to the people in the room while it is live.
export function EventPageParticipantsList({ event, iconSize = 34, maxAvatars = 6, onOpen }: Props) {
  const { t } = useLingui();
  const participants = useEventParticipants(event.id).data;
  const row = (
    <ParticipantsRow
      event={event}
      presentOnly={isMeetingLive(event, participants ?? [])}
      iconSize={iconSize}
      maxAvatars={maxAvatars}
    />
  );
  if (!onOpen) return row;
  return (
    <ButtonBase
      onClick={onOpen}
      aria-label={t({ id: "seeWhoIsGoing", message: "See who is going" })}
      sx={{ justifyContent: "flex-start", textAlign: "left", maxWidth: "100%", borderRadius: "10px" }}
    >
      {row}
    </ButtonBase>
  );
}
