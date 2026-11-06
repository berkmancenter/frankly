import SchoolOutlinedIcon from '@mui/icons-material/SchoolOutlined';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';

/** `PrerequisiteBadge`: shown in place of the participants on an event the user can't open yet. */
export function PrerequisiteBadge() {
  return (
    <Box sx={{ p: '8px' }}>
      <Box
        sx={{
          p: '8px',
          borderRadius: '10px',
          bgcolor: 'm3.errorContainer',
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
            bgcolor: 'm3.onErrorContainer',
            color: 'm3.errorContainer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            flexShrink: 0,
          }}
        >
          <SchoolOutlinedIcon sx={{ fontSize: 20 }} />
        </Box>
        <Typography variant="bodyLarge" sx={{ fontWeight: 500, color: 'm3.onErrorContainer', fontSize: 14 }}>
          Prerequisite Required
        </Typography>
      </Box>
    </Box>
  );
}
