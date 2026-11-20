import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { Link } from "react-router";
import type { Community } from "@/api/types";
import { paths } from "@/app/paths";
import { CommunityCircleIcon } from "@/components/CommunityCircleIcon";
import { Img } from "@/components/Img";
import { colors, fontSizes } from "@/theme/tokens";
import { parseCommunityColor } from "@/theme/theme";
import { useDragScroll } from "@/utils/useDragScroll";

const CARD_SIZE = 295;
const CARD_GAP = 20;

// A horizontally scrolling row of cards, one per community, each linking to that community's home.
export function CommunitiesCarousel({
  communities,
}: {
  communities: Community[];
}) {
  const scrollRef = useDragScroll<HTMLUListElement>();
  return (
    <Box
      component="ul"
      ref={scrollRef}
      sx={{
        listStyle: "none",
        m: 0,
        p: 0,
        display: "flex",
        gap: `${CARD_GAP}px`,
        overflowX: "auto",
        scrollbarWidth: "none",
        "&::-webkit-scrollbar": { display: "none" },
      }}
    >
      {communities.map((community) => (
        <Box component="li" key={community.id} sx={{ flexShrink: 0 }}>
          <CommunityCard community={community} />
        </Box>
      ))}
    </Box>
  );
}

function CommunityCard({ community }: { community: Community }) {
  const { t } = useLingui();
  const banner = community.bannerImageUrl?.trim();
  return (
    <ButtonBase
      component={Link}
      to={paths.community(community.displayId).home}
      draggable={false}
      sx={{
        position: "relative",
        width: CARD_SIZE,
        height: CARD_SIZE,
        borderRadius: "10px",
        overflow: "hidden",
        bgcolor:
          parseCommunityColor(community.themeDarkColor) ?? colors.primary,
        color: colors.onPrimary,
      }}
    >
      {banner && (
        <>
          <Img
            src={banner}
            width="100%"
            height="100%"
            sx={{ position: "absolute", inset: 0 }}
          />
          {/* A 54% black wash keeps white text readable on any image. */}
          <Box
            sx={{ position: "absolute", inset: 0, bgcolor: "rgba(0,0,0,.54)" }}
          />
        </>
      )}
      <Box
        sx={{
          position: "relative",
          p: "16px",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <CommunityCircleIcon community={community} />
        <Typography
          sx={{
            mt: "10px",
            fontSize: fontSizes.md,
            textAlign: "center",
            textTransform: "uppercase",
          }}
        >
          {community.name ??
            t({ id: "unnamedCommunity", message: "Unnamed Community" })}
        </Typography>
        <Typography
          sx={{
            mt: "30px",
            width: 255,
            height: 78,
            fontSize: fontSizes["2xl"],
            lineHeight: 1.1,
            fontWeight: 700,
            textAlign: "center",
            display: "-webkit-box",
            WebkitBoxOrient: "vertical",
            WebkitLineClamp: 3,
            overflow: "hidden",
          }}
        >
          {community.tagLine ?? community.description ?? ""}
        </Typography>
      </Box>
    </ButtonBase>
  );
}
