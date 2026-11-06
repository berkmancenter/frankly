import Box from '@mui/material/Box';
import Tooltip from '@mui/material/Tooltip';
import type { Community } from '@/api/types';
import { initials } from '@/lib/format';

/** `CommunityCircleIcon`: the community's picture in a circle (tooltip = its name). */
export function CommunityCircleIcon({
  community,
  size = 42,
  bordered = false,
}: {
  community: Pick<Community, 'name' | 'profileImageUrl'>;
  size?: number;
  bordered?: boolean;
}) {
  return (
    <Tooltip title={community.name}>
      <Box
        sx={{
          width: size,
          height: size,
          borderRadius: '50%',
          bgcolor: 'm3.onPrimaryContainer',
          border: bordered ? '1px solid' : 'none',
          borderColor: 'm3.onPrimaryContainer',
          boxSizing: 'border-box',
          overflow: 'hidden',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
          color: 'm3.primaryContainer',
          fontWeight: 600,
        }}
      >
        {community.profileImageUrl ? (
          <img
            src={community.profileImageUrl}
            alt=""
            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          />
        ) : (
          initials(community.name)
        )}
      </Box>
    </Tooltip>
  );
}
