import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { StandalonePage } from '@/app/layouts/StandalonePage';
import { fontSizes } from "@/theme/tokens";

/** "This URL was not found". */
export function NotFoundPage({ message = 'This URL was not found' }: { message?: string }) {
  return (
    <StandalonePage>
      <Box sx={{ minHeight: '60vh', display: 'flex', alignItems: 'center', justifyContent: 'center', textAlign: 'center', px: '20px' }}>
        <Typography sx={{ fontSize: fontSizes.md }}>{message}</Typography>
      </Box>
    </StandalonePage>
  );
}
