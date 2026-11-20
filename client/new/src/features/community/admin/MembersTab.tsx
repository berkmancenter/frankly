import CheckIcon from "@mui/icons-material/Check";
import CloseIcon from "@mui/icons-material/Close";
import FileDownloadOutlinedIcon from "@mui/icons-material/FileDownloadOutlined";
import InfoOutlinedIcon from "@mui/icons-material/InfoOutlined";
import SearchIcon from "@mui/icons-material/Search";
import Badge from "@mui/material/Badge";
import Box from "@mui/material/Box";
import CircularProgress from "@mui/material/CircularProgress";
import IconButton from "@mui/material/IconButton";
import Link from "@mui/material/Link";
import MenuItem from "@mui/material/MenuItem";
import Select from "@mui/material/Select";
import Tab from "@mui/material/Tab";
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import TableCell from "@mui/material/TableCell";
import TableHead from "@mui/material/TableHead";
import TablePagination from "@mui/material/TablePagination";
import TableRow from "@mui/material/TableRow";
import Tabs from "@mui/material/Tabs";
import TextField from "@mui/material/TextField";
import Tooltip from "@mui/material/Tooltip";
import Typography from "@mui/material/Typography";
import { msg } from "@lingui/core/macro";
import type { MessageDescriptor } from "@lingui/core";
import { useLingui } from "@lingui/react/macro";
import { useMemo, useState } from "react";
import type {
  Community,
  JoinRequest,
  MemberDetails,
  MembershipStatus,
  PublicUser,
} from "@/api/types";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { Avatar } from "@/components/Avatar";
import { ShareSection } from "@/components/ShareSection";
import { ErrorState, LoadingState } from "@/components/States";
import { useToast } from "@/components/Toast";
import {
  useJoinRequests,
  useMembers,
  useResolveJoinRequest,
  useSetMemberRole,
} from "@/queries/communities";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors, fontSizes } from "@/theme/tokens";
import { appName } from "@/utils/appInfo";
import { downloadText, toCsv } from "@/utils/csv";
import { isMember, roleLabel } from "@/utils/membership";
import { useIsMobile } from "@/utils/useResponsive";

const PAGE_SIZE = 10;
const MANAGING_COMMUNITY_URL: string =
  import.meta.env.VITE_HELP_CENTER_MANAGING_COMMUNITY_URL ?? "";

// Highest first. Nobody can be made the owner from here.
const ROLES: readonly MembershipStatus[] = [
  "owner",
  "admin",
  "moderator",
  "facilitator",
  "member",
];

const ROLE_DESCRIPTIONS: Partial<Record<MembershipStatus, MessageDescriptor>> =
  {
    member: msg({
      id: "permissionsMemberDescription",
      message:
        "Someone who has joined the community. May attend events, create posts, and receive community announcements.",
    }),
    facilitator: msg({
      id: "permissionsFacilitatorDescription",
      message: "Can schedule and host events based on existing templates.",
    }),
    moderator: msg({
      id: "permissionsModeratorDescription",
      message:
        "Can create/edit templates and events, remove unwanted content, move participants between rooms, and respond to help requests.",
    }),
    admin: msg({
      id: "permissionsAdminDescription",
      message:
        "Full control over community settings, member roles, and all content.",
    }),
    owner: msg({
      id: "permissionsOwnerDescription",
      message: "All admin capabilities, can add/remove other admins.",
    }),
  };

// Where the role help opens, below the icon.
const TOOLTIP_PLACEMENT = "bottom-start";

/* eslint-disable lingui/no-unlocalized-strings -- column titles and name of the exported file, which is not translated */
const MEMBER_COLUMNS = ["#", "Name", "Email", "Member status"];
const memberFileName = (communityId: string) =>
  `members-data-${communityId}.csv`;
/* eslint-enable lingui/no-unlocalized-strings */

const rank = (status: MembershipStatus) => ROLES.indexOf(status);

const MEMBERS = "members";
const REQUESTS = "requests";
type Section = typeof MEMBERS | typeof REQUESTS;

// The Members tab: who belongs, their roles, and who is waiting to be let in.
export function MembersTab() {
  const { t } = useLingui();
  const { community } = useCommunityScope();
  const isMobile = useIsMobile();
  const members = useMembers(community.id);
  const requests = useJoinRequests(community.id);
  const toast = useToast();
  const [section, setSection] = useState<Section>(MEMBERS);
  const [search, setSearch] = useState("");

  const waiting = requests.data?.length ?? 0;

  const download = () => {
    const rows = [...(members.data ?? [])]
      .sort((a, b) => rank(a.membership.status) - rank(b.membership.status))
      .filter(
        ({ membership }) =>
          isMember(membership.status) && membership.status !== "owner",
      )
      .map(({ user, membership, email }, index) => [
        index + 1,
        user.displayName,
        email ?? "",
        membership.status,
      ]);
    if (rows.length === 0) {
      toast.error(
        t({
          id: "noMembersFoundToExport",
          message: "No members found to export.",
        }),
      );
      return;
    }
    downloadText(
      memberFileName(community.id),
      toCsv([MEMBER_COLUMNS, ...rows]),
    );
  };

  return (
    <Box>
      <Box
        sx={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          gap: "10px",
          pt: "8px",
        }}
      >
        <TextField
          size="small"
          sx={{ maxWidth: 450, flex: 1 }}
          placeholder={t({
            id: "filterMemberListByName",
            message: "Filter member list by name",
          })}
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          slotProps={{
            input: { startAdornment: <SearchIcon sx={{ mr: "8px" }} /> },
            htmlInput: {
              "aria-label": t({
                id: "filterMemberListByName",
                message: "Filter member list by name",
              }),
            },
          }}
        />
        {!isMobile && (
          <ActionButton
            type="text"
            icon={<FileDownloadOutlinedIcon />}
            onPress={download}
          >
            {t({ id: "downloadMembersData", message: "Download members data" })}
          </ActionButton>
        )}
      </Box>
      <Tabs
        value={section}
        onChange={(_, next: Section) => setSection(next)}
        variant="fullWidth"
        sx={{ mt: "12px", mb: "20px" }}
      >
        <Tab value={MEMBERS} label={t({ id: "members", message: "Members" })} />
        <Tab
          value={REQUESTS}
          label={
            <Box sx={{ display: "flex", alignItems: "center", gap: "8px" }}>
              {`${t({ id: "requests", message: "Requests" })} (${waiting})`}
              <Badge variant="dot" color="error" invisible={waiting === 0} />
            </Box>
          }
        />
      </Tabs>
      {section === MEMBERS ? (
        <MembersList community={community} search={search} query={members} />
      ) : (
        <RequestsList community={community} query={requests} />
      )}
    </Box>
  );
}

function RoleHelp() {
  const { t } = useLingui();
  return (
    <Tooltip
      arrow
      placement={TOOLTIP_PLACEMENT}
      slotProps={{
        tooltip: {
          sx: {
            bgcolor: colors.surfaceContainerLowest,
            color: colors.onSurfaceVariant,
            boxShadow: 3,
            p: "16px",
            fontSize: fontSizes.sm,
            whiteSpace: "pre-line",
          },
        },
        arrow: { sx: { color: colors.surfaceContainerLowest } },
      }}
      title={
        <Box>
          {t({
            id: "rolesTooltip",
            message:
              "Member roles determine permissions and \naccess within the community.",
          })}
          {MANAGING_COMMUNITY_URL && (
            <Box sx={{ pt: "8px" }}>
              <Link
                href={MANAGING_COMMUNITY_URL}
                target="_blank"
                rel="noopener noreferrer"
                sx={{ fontWeight: 700 }}
              >
                {t({
                  id: "seeManagingYourCommunity",
                  message: "See Managing Your Community for details.",
                })}
              </Link>
            </Box>
          )}
        </Box>
      }
    >
      <IconButton size="small" aria-label={t({ id: "role", message: "Role" })}>
        <InfoOutlinedIcon />
      </IconButton>
    </Tooltip>
  );
}

// A role picker: each choice says what the role can do. Pending requests use it to pick the role to approve with.
function RoleSelect({
  value,
  onChange,
  label,
  loading = false,
}: {
  value: MembershipStatus;
  onChange: (status: MembershipStatus) => void;
  label: string;
  loading?: boolean;
}) {
  const { i18n } = useLingui();
  const isMobile = useIsMobile();
  if (loading) return <CircularProgress size={24} aria-label={label} />;
  if (value === "owner")
    return <Typography>{i18n._(roleLabel("owner"))}</Typography>;
  return (
    <Select
      size="small"
      value={value}
      onChange={(event) => onChange(event.target.value as MembershipStatus)}
      fullWidth={isMobile}
      sx={{
        minWidth: isMobile ? 150 : 280,
        maxWidth: isMobile ? undefined : 300,
      }}
      inputProps={{ "aria-label": label }}
      renderValue={(status) => i18n._(roleLabel(status))}
    >
      {ROLES.map((role) => (
        <MenuItem
          key={role}
          value={role}
          disabled={role === "owner"}
          sx={{ whiteSpace: "normal" }}
        >
          <Box>
            <Typography sx={{ fontWeight: 700 }}>
              {i18n._(roleLabel(role))}
            </Typography>
            <Typography variant="body2" sx={{ color: colors.onSurfaceVariant }}>
              {i18n._(ROLE_DESCRIPTIONS[role]!)}
            </Typography>
          </Box>
        </MenuItem>
      ))}
    </Select>
  );
}

function Person({ user }: { user: PublicUser | undefined }) {
  const { t } = useLingui();
  const name =
    user?.displayName || t({ id: "unknownUser", message: "Unknown User" });
  return (
    <Box sx={{ display: "flex", alignItems: "center", gap: "8px", py: "8px" }}>
      <Avatar name={name} imageUrl={user?.imageUrl} size={40} ring={false} />
      <Typography>{name}</Typography>
    </Box>
  );
}

const headerSx = { bgcolor: colors.surfaceContainer, fontWeight: 700 };

function MembersList({
  community,
  search,
  query,
}: {
  community: Community;
  search: string;
  query: ReturnType<typeof useMembers>;
}) {
  const { t } = useLingui();
  const toast = useToast();
  const setRole = useSetMemberRole(community.id);
  const [changing, setChanging] = useState<string | null>(null);
  const [page, setPage] = useState(0);

  const visible = useMemo(
    () =>
      (query.data ?? [])
        .filter(
          ({ membership }) =>
            isMember(membership.status) && !membership.invisible,
        )
        .sort((a, b) => rank(a.membership.status) - rank(b.membership.status)),
    [query.data],
  );
  const needle = search.trim().toLowerCase();
  const shown = needle
    ? visible.filter(
        ({ user, email }) =>
          user.displayName.toLowerCase().includes(needle) ||
          (email ?? "").toLowerCase().includes(needle),
      )
    : visible;

  if (query.isPending) return <LoadingState height={200} />;
  if (query.isError) {
    return (
      <ErrorState
        message={t({
          id: "errorLoadingCommunityMembers",
          message: "Something went wrong loading memberships. Please refresh.",
        })}
      />
    );
  }
  if (shown.length === 0) {
    return (
      <Typography sx={{ p: "8px" }}>
        {needle
          ? t({
              id: "noMatchingMembersFound",
              message: "No matching members found.",
            })
          : t({
              id: "errorLoadingCommunityMembers",
              message:
                "Something went wrong loading memberships. Please refresh.",
            })}
      </Typography>
    );
  }

  const change = async ({ user }: MemberDetails, status: MembershipStatus) => {
    setChanging(user.id);
    try {
      await setRole.mutateAsync({ userId: user.id, status });
    } catch {
      toast.error(
        t({
          id: "somethingWentWrongTryAgain",
          message: "Something went wrong. Please try again.",
        }),
      );
    } finally {
      setChanging(null);
    }
  };

  const lastPage = Math.max(0, Math.ceil(shown.length / PAGE_SIZE) - 1);
  const at = Math.min(page, lastPage);
  return (
    <Box
      sx={{
        bgcolor: colors.surfaceContainerLowest,
        borderRadius: "10px",
        overflow: "hidden",
      }}
    >
      <Table>
        <TableHead>
          <TableRow>
            <TableCell sx={headerSx}>
              {t({ id: "member", message: "Member" })}
            </TableCell>
            <TableCell sx={headerSx}>
              <Box sx={{ display: "flex", alignItems: "center" }}>
                {t({ id: "role", message: "Role" })}
                <RoleHelp />
              </Box>
            </TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {shown.slice(at * PAGE_SIZE, (at + 1) * PAGE_SIZE).map((member) => (
            <TableRow key={member.user.id}>
              <TableCell>
                <Person user={member.user} />
              </TableCell>
              <TableCell>
                <RoleSelect
                  value={member.membership.status}
                  label={`${t({ id: "role", message: "Role" })}: ${member.user.displayName}`}
                  loading={changing === member.user.id}
                  onChange={(status) => void change(member, status)}
                />
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <TablePagination
        component="div"
        count={shown.length}
        page={at}
        onPageChange={(_, next) => setPage(next)}
        rowsPerPage={PAGE_SIZE}
        rowsPerPageOptions={[PAGE_SIZE]}
      />
    </Box>
  );
}

function RequestsList({
  community,
  query,
}: {
  community: Community;
  query: ReturnType<typeof useJoinRequests>;
}) {
  const { t } = useLingui();
  const toast = useToast();
  const resolve = useResolveJoinRequest(community.id);
  const [roles, setRoles] = useState<Record<string, MembershipStatus>>({});
  const [page, setPage] = useState(0);

  if (query.isPending) return <LoadingState height={200} />;
  if (query.isError) {
    return (
      <ErrorState
        message={t({
          id: "errorLoadingRequests",
          message: "Something went wrong loading requests. Please refresh.",
        })}
      />
    );
  }

  const requests = query.data;
  if (requests.length === 0) return <NoRequests community={community} />;

  const roleOf = (request: JoinRequest): MembershipStatus =>
    roles[request.user.id] ?? "member";
  const answer = async (request: JoinRequest, approve: boolean) => {
    try {
      await resolve.mutateAsync({
        userId: request.user.id,
        approve,
        ...(approve ? { role: roleOf(request) } : {}),
      });
    } catch {
      toast.error(
        t({
          id: "somethingWentWrongTryAgain",
          message: "Something went wrong. Please try again.",
        }),
      );
    }
  };
  const approveAll = async () => {
    for (const request of requests) await answer(request, true);
  };

  const lastPage = Math.max(0, Math.ceil(requests.length / PAGE_SIZE) - 1);
  const at = Math.min(page, lastPage);
  return (
    <Box
      sx={{
        bgcolor: colors.surfaceContainerLowest,
        borderRadius: "10px",
        overflow: "hidden",
      }}
    >
      <Table>
        <TableHead>
          <TableRow>
            <TableCell sx={headerSx}>
              {t({ id: "followerRequest", message: "Follower Request" })}
            </TableCell>
            <TableCell sx={headerSx}>
              <Box sx={{ display: "flex", alignItems: "center" }}>
                {t({ id: "role", message: "Role" })}
                <RoleHelp />
              </Box>
            </TableCell>
            <TableCell sx={headerSx}>
              <ActionButton icon={<CheckIcon />} onPress={approveAll}>
                {t({ id: "approveAll", message: "Approve All" })}
              </ActionButton>
            </TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {requests
            .slice(at * PAGE_SIZE, (at + 1) * PAGE_SIZE)
            .map((request) => (
              <TableRow key={request.user.id}>
                <TableCell>
                  <Person user={request.user} />
                </TableCell>
                <TableCell>
                  <RoleSelect
                    value={roleOf(request)}
                    label={`${t({ id: "role", message: "Role" })}: ${request.user.displayName}`}
                    onChange={(status) =>
                      setRoles((current) => ({
                        ...current,
                        [request.user.id]: status,
                      }))
                    }
                  />
                </TableCell>
                <TableCell>
                  <Box sx={{ display: "flex", gap: "8px" }}>
                    <ActionButton
                      ariaLabel={`${t({ id: "approve", message: "Approve" })}: ${request.user.displayName}`}
                      height={48}
                      minWidth={48}
                      radius={24}
                      icon={<CheckIcon />}
                      onPress={() => answer(request, true)}
                    />
                    <ActionButton
                      type="outline"
                      ariaLabel={`${t({ id: "deny", message: "Deny" })}: ${request.user.displayName}`}
                      height={48}
                      minWidth={48}
                      radius={24}
                      icon={<CloseIcon />}
                      onPress={() => answer(request, false)}
                    />
                  </Box>
                </TableCell>
              </TableRow>
            ))}
        </TableBody>
      </Table>
      <TablePagination
        component="div"
        count={requests.length}
        page={at}
        onPageChange={(_, next) => setPage(next)}
        rowsPerPage={PAGE_SIZE}
        rowsPerPageOptions={[PAGE_SIZE]}
      />
    </Box>
  );
}

// With nobody waiting, the page invites the admin to bring more people in.
function NoRequests({ community }: { community: Community }) {
  const { t } = useLingui();
  const communityName = community.name;
  const subject = t({
    id: "joinCommunityOnApp",
    message: `Join ${communityName} on ${appName}`,
  });
  const body = t({
    id: "checkOutCommunityOnApp",
    message: `Hey, check out ${communityName} on ${appName}!`,
  });
  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: "20px",
        pt: "20px",
        textAlign: "center",
      }}
    >
      <Typography component="h2" sx={{ fontSize: fontSizes["2xl"] }}>
        {t({
          id: "noFollowRequestsCurrently",
          message: "No follow requests currently",
        })}
      </Typography>
      <Typography sx={{ fontSize: fontSizes.lg }}>
        {t({
          id: "shareYourCommunityWithOthers",
          message: "Share your community with others",
        })}
      </Typography>
      <Box sx={{ width: "100%", maxWidth: 350 }}>
        <ShareSection
          url={paths.community(community.displayId).home}
          subject={subject}
          body={body}
          size={39}
          iconSize={16}
          buttonPadding={0}
        />
      </Box>
    </Box>
  );
}
