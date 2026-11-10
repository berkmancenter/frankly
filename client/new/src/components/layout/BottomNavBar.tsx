import AddIcon from '@mui/icons-material/Add';
import TodayRoundedIcon from '@mui/icons-material/TodayRounded';
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import { useNavigate } from 'react-router';
import { paths } from '@/app/paths';
import { useCreateEventDialog } from '@/features/events/CreateEventDialog';
import { appSize, colors } from "@/theme/tokens";
import { ProfileMenu } from './ProfileMenu';
import { SelectableNavigationIcon } from './SelectableNavigationIcon';

/** Home page bottom bar (below 1000px): just the profile avatar, right-aligned. */
export function HomeBottomNavBar() {
  return (
    <Box
      sx={{
        bgcolor: colors.surfaceContainer,
        height: appSize.bottomNavBarHeight,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'flex-end',
        pr: '24px',
        flexShrink: 0,
      }}
    >
      <ProfileMenu menuAbove />
    </Box>
  );
}

/** Community bottom bar (below 1000px): my events, optional "create event", profile. */
export function CommunityBottomNavBar({ showCreateEventButton }: { showCreateEventButton: boolean }) {
  const navigate = useNavigate();
  const createEvent = useCreateEventDialog();
  return (
    <Box
      component="nav"
      aria-label="Bottom navigation"
      sx={{
        bgcolor: colors.surfaceContainer,
        py: '16px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-evenly',
        flexShrink: 0,
      }}
    >
      <SelectableNavigationIcon
        label="My events"
        selected={false}
        icon={<TodayRoundedIcon sx={{ fontSize: 30 }} />}
        onClick={() => navigate(paths.settings({ initialSection: 'events' }))}
      />
      {showCreateEventButton && (
        <IconButton
          aria-label="Create an event"
          onClick={() => createEvent.open()}
          sx={{ bgcolor: 'primary.main', color: 'primary.contrastText', '&:hover': { bgcolor: 'primary.main', opacity: 0.9 } }}
        >
          <AddIcon />
        </IconButton>
      )}
      <ProfileMenu menuAbove />
      {createEvent.dialog}
    </Box>
  );
}
