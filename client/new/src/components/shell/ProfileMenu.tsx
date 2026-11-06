import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import Menu from '@mui/material/Menu';
import MenuItem from '@mui/material/MenuItem';
import { useState } from 'react';
import { useNavigate } from 'react-router';
import { paths } from '@/app/paths';
import { Avatar } from '@/components/Avatar';
import { useToast } from '@/components/Toast';
import { useCurrentUser } from '@/queries/me';

/**
 * `ProfileOrLogin`: the user's avatar; opens a menu with "My Profile", "My Events", "Sign Out".
 * (Auth is faked, so Sign Out only explains itself.)
 */
export function ProfileMenu({ menuAbove = false }: { menuAbove?: boolean }) {
  const user = useCurrentUser();
  const navigate = useNavigate();
  const toast = useToast();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const close = () => setAnchor(null);

  if (!user) return null;
  return (
    <Box sx={{ px: '8px' }}>
      <IconButton aria-label="Profile Button" onClick={(e) => setAnchor(e.currentTarget)} sx={{ p: '4px' }}>
        <Avatar name={user.displayName} imageUrl={user.imageUrl} size={42} />
      </IconButton>
      <Menu
        anchorEl={anchor}
        open={!!anchor}
        onClose={close}
        anchorOrigin={{ vertical: menuAbove ? 'top' : 'bottom', horizontal: 'right' }}
        transformOrigin={{ vertical: menuAbove ? 'bottom' : 'top', horizontal: 'right' }}
        slotProps={{
          paper: { sx: { width: 200, borderRadius: '8px', bgcolor: 'm3.surfaceContainerLowest', maxHeight: 400 } },
        }}
      >
        <MenuItem
          onClick={() => {
            close();
            navigate(paths.settings({ initialSection: 'profile' }));
          }}
        >
          My Profile
        </MenuItem>
        <MenuItem
          onClick={() => {
            close();
            navigate(paths.settings({ initialSection: 'events' }));
          }}
        >
          My Events
        </MenuItem>
        <MenuItem
          onClick={() => {
            close();
            toast.show('Sign-in is faked in this prototype: you are always the local user.');
          }}
        >
          Sign Out
        </MenuItem>
      </Menu>
    </Box>
  );
}
