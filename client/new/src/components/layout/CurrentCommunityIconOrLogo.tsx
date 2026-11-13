import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { Link } from "react-router";
import { paths } from "@/app/paths";
import { CommunityCircleIcon } from "@/components/CommunityCircleIcon";
import { useIsMobile } from "@/utils/useResponsive";
import { useCommunityScopeOrNull } from "@/scopes/CommunityScope";

/** Left side of the nav bar: the community's circle icon inside a community, else the logo + BETA pill. */
export function CurrentCommunityIconOrLogo() {
  const scope = useCommunityScopeOrNull();
  const isMobile = useIsMobile();

  if (scope) {
    return (
      <IconButton
        component={Link}
        to={paths.community(scope.community.displayId).home}
        aria-label={scope.community.name}
        sx={{ p: "8px", pl: isMobile ? "1px" : "8px" }}
      >
        <CommunityCircleIcon
          community={scope.community}
          size={42}
          bordered={isMobile}
        />
      </IconButton>
    );
  }
  return (
    <IconButton
      component={Link}
      to={paths.home}
      aria-label={t`Frankly home`}
      sx={{ p: "8px", pl: isMobile ? "1px" : "8px", borderRadius: "8px" }}
    >
      <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
        <img
          src="/media/logo.png"
          alt={t`Frankly Logo`}
          style={{
            width: 100,
            height: isMobile ? 40 : 80,
            objectFit: "contain",
          }}
        />
        <Typography
          component="span"
          sx={{
            bgcolor: "#E5E0D6",
            color: "primary.main",
            borderRadius: "64px",
            px: "12px",
            py: "2px",

            lineHeight: 1.2,
          }}
        >
          BETA
        </Typography>
      </Box>
    </IconButton>
  );
}
