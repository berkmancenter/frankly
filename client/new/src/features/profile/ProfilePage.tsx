import Box from "@mui/material/Box";
import Tab from "@mui/material/Tab";
import Tabs from "@mui/material/Tabs";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { appName } from "@/utils/appInfo";
import { useDocumentTitle } from "@/utils/useDocumentTitle";
import { useSearchParams } from "react-router";
import { PROFILE_SECTIONS, type ProfileSection } from "@/app/paths";
import { StandalonePage } from "@/app/layouts/StandalonePage";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { useIsRegistered } from "@/features/auth/useAuthSession";
import { EventsTab } from "./EventsTab";
import { NotificationsTab } from "./NotificationsTab";
import { ProfileTab } from "./ProfileTab";

const COMMUNITY_PARAM = "communityId";

const isSection = (value: string | null): value is ProfileSection =>
  PROFILE_SECTIONS.includes(value as ProfileSection);

/**
 * `/profile`: the signed-in user's own page, in three tabs (my events, profile, notifications).
 */
export function ProfilePage() {
  const { t } = useLingui();
  useDocumentTitle(t({ id: "appNameUserSettings", message: `${appName} - User Settings` }));
  const registered = useIsRegistered();
  const [params, setParams] = useSearchParams();
  // Query parameter values, not UI text.
  // eslint-disable-next-line lingui/no-unlocalized-strings
  const requested = params.get("section");
  const [events, profile, notifications] = PROFILE_SECTIONS;
  const section: ProfileSection = isSection(requested) ? requested : events;
  const communityId = params.get(COMMUNITY_PARAM) ?? undefined;
  const labels: Record<ProfileSection, string> = {
    events: t({ id: "myEvents", message: "My Events" }),
    profile: t({ id: "profile", message: "Profile" }),
    notifications: t({ id: "notifications", message: "Notifications" }),
  };

  return (
    <StandalonePage>
      <Box component="main" sx={{ pt: "30px", pb: "100px" }}>
        {!registered ? (
          <Typography sx={{ py: "40px", textAlign: "center" }}>
            {t({
              id: "mustBeLoggedInToAccessThisSection",
              message: "Must be logged in to access this section",
            })}
          </Typography>
        ) : (
          <>
            <ConstrainedBody>
              <Tabs
                value={section}
                onChange={(_, next: ProfileSection) =>
                  setParams(
                    (current) => {
                      const updated = new URLSearchParams(current);
                      // eslint-disable-next-line lingui/no-unlocalized-strings
                      updated.set("section", next);
                      return updated;
                    },
                    { replace: true },
                  )
                }
                sx={{ width: "100%" }}
              >
                {PROFILE_SECTIONS.map((name) => (
                  <Tab key={name} value={name} label={labels[name]} />
                ))}
              </Tabs>
            </ConstrainedBody>
            {section === events && <EventsTab />}
            {section === profile && (
              <ConstrainedBody>
                <ProfileTab />
              </ConstrainedBody>
            )}
            {section === notifications && (
              <ConstrainedBody>
                <NotificationsTab initialCommunityId={communityId} />
              </ConstrainedBody>
            )}
          </>
        )}
      </Box>
    </StandalonePage>
  );
}
