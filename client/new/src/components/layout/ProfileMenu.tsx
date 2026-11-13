import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import Menu from '@mui/material/Menu';
import MenuItem from '@mui/material/MenuItem';
import { t } from '@lingui/core/macro';
import { Trans } from '@lingui/react/macro';
import { useState } from 'react';
import { useNavigate } from 'react-router';
import { paths } from '@/app/paths';
import { Avatar } from '@/components/Avatar';
import { useAuthService } from '@/api/ApiProvider';
import { SignInButtons } from '@/features/auth/SignInButtons';
import { useIsRegistered } from '@/features/auth/useAuthSession';
import { useCurrentUser } from '@/queries/me';
import { colors } from "@/theme/tokens";

/**
 * `ProfileOrLogin`: for a signed-in user the avatar, opening a menu with "My Profile", "My Events"
 * and "Sign Out"; for a visitor without an account, the Log In / Sign Up buttons.
 */
export function ProfileMenu({ menuAbove = false }: { menuAbove?: boolean }) {
  const user = useCurrentUser();
  const navigate = useNavigate();
  const auth = useAuthService();
  const registered = useIsRegistered();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const close = () => setAnchor(null);

  if (!registered) return <SignInButtons />;
  if (!user) return null;
  return (
    <Box sx={{ px: '8px' }}>
      <IconButton
        aria-label={t({ id: 'profileMenu.profileButton', message: 'Profile Button' })}
        onClick={(e) => setAnchor(e.currentTarget)}
        sx={{ p: '4px' }}
      >
        <Avatar name={user.displayName} imageUrl={user.imageUrl} size={42} />
      </IconButton>
      <Menu
        anchorEl={anchor}
        open={!!anchor}
        onClose={close}
        anchorOrigin={{ vertical: menuAbove ? 'top' : 'bottom', horizontal: 'right' }}
        transformOrigin={{ vertical: menuAbove ? 'bottom' : 'top', horizontal: 'right' }}
        slotProps={{
          paper: { sx: { width: 200, borderRadius: '8px', bgcolor: colors.surfaceContainerLowest, maxHeight: 400 } },
        }}
      >
        <MenuItem
          onClick={() => {
            close();
            navigate(paths.settings({ initialSection: 'profile' }));
          }}
        >
          <Trans id="profileMenu.myProfile">My Profile</Trans>
        </MenuItem>
        <MenuItem
          onClick={() => {
            close();
            navigate(paths.settings({ initialSection: 'events' }));
          }}
        >
          <Trans id="profileMenu.myEvents">My Events</Trans>
        </MenuItem>
        <MenuItem
          onClick={() => {
            close();
            void auth.signOut();
          }}
        >
          <Trans id="profileMenu.signOut">Sign Out</Trans>
        </MenuItem>
      </Menu>
    </Box>
  );
}
