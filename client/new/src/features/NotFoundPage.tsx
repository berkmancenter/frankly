import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { StandalonePage } from '@/app/layouts/StandalonePage';

/** "This URL was not found". */
export function NotFoundPage({ message = 'This URL was not found' }: { message?: string }) {
  return (
    <StandalonePage>
      <Box sx={{ minHeight: '60vh', display: 'flex', alignItems: 'center', justifyContent: 'center', textAlign: 'center', px: '20px' }}>
        <Typography variant="bodyLarge">{message}</Typography>
      </Box>
    </StandalonePage>
  );
}
