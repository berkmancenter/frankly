import CircularProgress from '@mui/material/CircularProgress';
import { t } from '@lingui/core/macro';
import type { Community } from '@/api/types';
import { useFollowCommunity } from '@/queries/communities';
import { useMembership } from '@/queries/me';
import { ActionButton } from './ActionButton';
import { useToast } from './Toast';

/**
 * `CommunityMembershipButton`: "Follow", or the approval flow when the community requires it
 * ("Request To Follow" → "Follow Request Sent").
 */
export function CommunityMembershipButton({
  community,
  height,
  minWidth,
}: {
  community: Community;
  height?: number;
  minWidth?: number;
}) {
  const membership = useMembership(community.id);
  const follow = useFollowCommunity();
  const toast = useToast();

  if (follow.isPending && !follow.variables) return <CircularProgress size={42} />;

  const requiresApproval = community.settings.requireApprovalToJoin;
  const status = membership?.requestStatus;
  const pending = requiresApproval && status === 'pending';
  const label = !requiresApproval
    ? t`Follow`
    : pending
      ? t`Follow Request Sent`
      : status === 'approved'
        ? t`Follow`
        : t`Request To Follow`;

  return (
    <ActionButton
      text={label}
      height={height}
      minWidth={minWidth}
      disabled={pending}
      ariaLabel={t`Follow community`}
      onPress={async () => {
        try {
          await follow.mutateAsync(community.id);
          if (requiresApproval) toast.show(t`Follow request sent`);
        } catch {
          toast.error(t`Something went wrong. Please try again.`);
        }
      }}
    />
  );
}
