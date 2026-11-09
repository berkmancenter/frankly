import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { ActionButton, type ActionButtonType } from './ActionButton';
import { colors, fontSizes } from "@/theme/tokens";

export type EmptyPageType = 'posts' | 'events' | 'resources';

const ICONS: Record<EmptyPageType, string> = {
  posts: '💬',
  events: '🗓',
  resources: '📋',
};

const BUTTONS: Record<EmptyPageType, string> = {
  posts: 'Create a post',
  events: 'Create an event',
  resources: 'Create a resource',
};

interface EmptyPageContentProps {
  type: EmptyPageType;
  /** Show the button (only when the user can act). */
  onButtonPress?: () => void;
  titleText?: string;
  subtitleText?: string;
  buttonText?: string;
  /** White rounded card behind the content. */
  showContainer?: boolean;
  buttonType?: ActionButtonType;
}

/** `EmptyPageContent`: 524x311 centered emoji + title + subtitle + optional button. */
export function EmptyPageContent({
  type,
  onButtonPress,
  titleText,
  subtitleText,
  buttonText,
  showContainer = true,
  buttonType = 'filled',
}: EmptyPageContentProps) {
  return (
    <Box
      sx={{
        height: 311,
        width: '100%',
        maxWidth: 524,
        p: '10px',
        boxSizing: 'border-box',
        borderRadius: '10px',
        bgcolor: showContainer ? colors.surfaceContainerLowest : 'transparent',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        textAlign: 'center',
      }}
    >
      <Box sx={{ fontSize: 62, lineHeight: 1.2 }} aria-hidden>
        {ICONS[type]}
      </Box>
      <Typography component="h3" sx={{ fontSize: fontSizes.xl, mt: '10px' }}>
        {titleText ?? `No ${type}`}
      </Typography>
      <Typography component="div" sx={{ fontSize: fontSizes.sm, fontWeight: 500, mt: '20px', width: 205 }}>
        {subtitleText ?? `When new ${type} are added, you'll see them here.`}
      </Typography>
      {onButtonPress && (
        <Box sx={{ mt: '20px' }}>
          <ActionButton type={buttonType} onPress={onButtonPress}>
            {buttonText ?? BUTTONS[type]}
          </ActionButton>
        </Box>
      )}
    </Box>
  );
}
