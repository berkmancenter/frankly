import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { useLingui } from "@lingui/react/macro";
import { StandalonePage } from '@/app/layouts/StandalonePage';
import { fontSizes } from "@/theme/tokens";

/** "This URL was not found". */
export function NotFoundPage({ message }: { message?: string }) {
  const { t } = useLingui();
  return (
    <StandalonePage>
      <Box sx={{ minHeight: '60vh', display: 'flex', alignItems: 'center', justifyContent: 'center', textAlign: 'center', px: '20px' }}>
        <Typography sx={{ fontSize: fontSizes.md }}>{message ?? t`This URL was not found`}</Typography>
      </Box>
    </StandalonePage>
  );
}
