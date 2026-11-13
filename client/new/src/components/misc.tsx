import SchoolOutlinedIcon from '@mui/icons-material/SchoolOutlined';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { Trans } from '@lingui/react/macro';
import { colors, fontSizes } from "@/theme/tokens";

/** `PrerequisiteBadge`: shown in place of the participants on an event the user can't open yet. */
export function PrerequisiteBadge() {
  return (
    <Box sx={{ p: '8px' }}>
      <Box
        sx={{
          p: '8px',
          borderRadius: '10px',
          bgcolor: colors.errorContainer,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '10px',
        }}
      >
        <Box
          sx={{
            width: 24,
            height: 24,
            borderRadius: '50%',
            bgcolor: colors.onErrorContainer,
            color: colors.errorContainer,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            flexShrink: 0,
          }}
        >
          <SchoolOutlinedIcon sx={{ fontSize: 20 }} />
        </Box>
        <Typography sx={{ fontWeight: 500, color: colors.onErrorContainer, fontSize: fontSizes.sm }}>
          <Trans id="prerequisiteBadge.text">Prerequisite Required</Trans>
        </Typography>
      </Box>
    </Box>
  );
}
