import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import CloudDownloadIcon from "@mui/icons-material/CloudDownload";
import EditSquareIcon from "@mui/icons-material/EditSquare";
import GroupIcon from "@mui/icons-material/Group";
import SettingsIcon from "@mui/icons-material/Settings";
import Box from "@mui/material/Box";
import Tab from "@mui/material/Tab";
import Tabs from "@mui/material/Tabs";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useEffect, useState, type ReactElement } from "react";
import { useNavigate, useParams } from "react-router";
import { ADMIN_TABS, paths, type AdminTab } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { useIsRegistered } from "@/features/auth/useAuthSession";
import { useSignInDialog } from "@/features/auth/SignInDialog";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { fontSizes } from "@/theme/tokens";
import { useIsMobile } from "@/utils/useResponsive";
import { DataTab } from "./DataTab";
import { MembersTab } from "./MembersTab";
import { OverviewTab } from "./OverviewTab";
import { SettingsTab } from "./SettingsTab";

const isTab = (value: string | undefined): value is AdminTab =>
  ADMIN_TABS.includes(value as AdminTab);

const ICON_ABOVE = "top";
const ICON_BESIDE = "start";

// A short window has no room for the heading, and a virtual keyboard would cover the content.
const SHORT_WINDOW = "@media (max-height:600px)";

// Manage Community: admins only. The open tab is state of this page; the address follows it
// without a navigation, so reloading or sharing the link lands on the same tab.
export function CommunityAdminPage() {
  const { t } = useLingui();
  const { community, permissions } = useCommunityScope();
  const params = useParams();
  const [tab, setTab] = useState<AdminTab>(
    isTab(params.tab) ? params.tab : ADMIN_TABS[0],
  );
  const registered = useIsRegistered();
  const signIn = useSignInDialog();
  const isMobile = useIsMobile();
  const navigate = useNavigate();

  const { open } = signIn;
  useEffect(() => {
    if (!registered) void open();
  }, [registered, open]);

  const choose = (next: AdminTab) => {
    setTab(next);
    // Keep the router's own history entry data; only the address changes.
    window.history.replaceState(
      window.history.state,
      "",
      paths.community(community.displayId).admin(next),
    );
  };

  if (!permissions.canEditCommunity) {
    return (
      <>
        <Box
          sx={{
            minHeight: "60vh",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            textAlign: "center",
            px: "20px",
          }}
        >
          <Typography>
            {t({
              id: "mustBeAdminToAccessSection",
              message: "Must be logged in and an admin to access this section",
            })}
          </Typography>
        </Box>
        {signIn.dialog}
      </>
    );
  }

  const labels: Record<AdminTab, string> = {
    profile: t({ id: "profile", message: "Profile" }),
    members: t({ id: "members", message: "Members" }),
    data: t({ id: "eventData", message: "Event Data" }),
    settings: t({ id: "settings", message: "Settings" }),
  };
  const icons: Record<AdminTab, ReactElement> = {
    profile: <EditSquareIcon />,
    members: <GroupIcon />,
    data: <CloudDownloadIcon />,
    settings: <SettingsIcon />,
  };

  return (
    <Box
      component="main"
      sx={{
        maxWidth: 1115,
        mx: "auto",
        mt: "20px",
        px: isMobile ? "20px" : 0,
        pb: "100px",
      }}
    >
      <Box sx={{ pb: "16px", [SHORT_WINDOW]: { display: "none" } }}>
        <ActionButton
          type="text"
          icon={<ArrowBackIcon />}
          onPress={() => navigate(paths.community(community.displayId).home)}
        >
          {community.name}
        </ActionButton>
        <Typography
          component="h1"
          noWrap
          sx={{ py: "8px", fontSize: fontSizes["3xl"] }}
        >
          {t({ id: "manageCommunity", message: "Manage Community" })}
        </Typography>
      </Box>
      <Tabs
        value={tab}
        onChange={(_, next: AdminTab) => choose(next)}
        variant="fullWidth"
        aria-label={t({ id: "manageCommunity", message: "Manage Community" })}
      >
        {ADMIN_TABS.map((name) => (
          <Tab
            key={name}
            value={name}
            icon={icons[name]}
            iconPosition={isMobile ? ICON_ABOVE : ICON_BESIDE}
            label={labels[name]}
            sx={{
              gap: isMobile ? 0 : "8px",
              fontSize: isMobile ? 9 : fontSizes.md,
            }}
          />
        ))}
      </Tabs>
      <Box sx={{ pt: "20px" }}>
        {tab === "profile" && <OverviewTab />}
        {tab === "members" && <MembersTab />}
        {tab === "data" && <DataTab />}
        {tab === "settings" && <SettingsTab />}
      </Box>
      {signIn.dialog}
    </Box>
  );
}
