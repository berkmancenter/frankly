import CheckIcon from '@mui/icons-material/Check';
import EditIcon from '@mui/icons-material/Edit';
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { useState } from 'react';
import { useApi } from '@/api/ApiProvider';
import type { CommunityResource } from '@/api/types';
import { ActionButton } from '@/components/ActionButton';
import { AppDialog } from '@/components/AppDialog';
import { Img } from '@/components/Img';
import { useToast } from '@/components/Toast';
import { useCreateResource, useUpdateResource } from '@/queries/content';
import { useCommunityScope } from '@/scopes/CommunityScope';

/**
 * "Add a resource": paste a URL, press ✓ to look up its preview, edit the title,
 * then Post. The unfurl is a one-shot request owned by this dialog, not a cached query.
 */
export function ResourceDialog({ resource, onClose }: { resource?: CommunityResource; onClose: () => void }) {
  const { community } = useCommunityScope();
  const api = useApi();
  const toast = useToast();
  const create = useCreateResource(community.id);
  const update = useUpdateResource(community.id);

  const [url, setUrl] = useState(resource?.url ?? '');
  const [loadedUrl, setLoadedUrl] = useState(resource?.url ?? '');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [title, setTitle] = useState(resource?.title ?? '');
  const [image, setImage] = useState(resource?.image);
  const [editingTitle, setEditingTitle] = useState(false);

  const dirty = url.trim() !== loadedUrl;
  const loaded = !!loadedUrl && !dirty;

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const preview = await api.resources.preview(url.trim());
      setLoadedUrl(url.trim());
      setTitle(preview.title);
      setImage(preview.image);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Could not load that link.');
    } finally {
      setLoading(false);
    }
  };

  const post = async () => {
    try {
      if (resource) await update.mutateAsync({ resourceId: resource.id, patch: { url: loadedUrl, title, image } });
      else await create.mutateAsync({ url: loadedUrl, title, image });
      toast.success(resource ? 'Resource updated' : 'Resource added');
      onClose();
    } catch {
      toast.error('Something went wrong. Please try again.');
    }
  };

  return (
    <AppDialog open onClose={onClose} fullscreenOnMobile maxWidth={600}>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: '50px', pt: '10px' }}>
        <Box>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <TextField
              fullWidth
              placeholder="Paste or enter URL"
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              error={!!error}
              slotProps={{ htmlInput: { 'aria-label': 'Resource URL' } }}
              sx={{ '& .MuiOutlinedInput-root': { '& fieldset': { borderColor: error ? 'm3.error' : 'primary.main' }, bgcolor: error ? 'm3.errorContainer' : undefined } }}
            />
            {dirty && url.trim() && (
              <IconButton
                aria-label="Load link"
                onClick={load}
                sx={{ width: 50, height: 50, bgcolor: 'primary.main', color: 'primary.contrastText', '&:hover': { bgcolor: 'primary.main', opacity: 0.9 } }}
              >
                <CheckIcon />
              </IconButton>
            )}
          </Box>
          {error && (
            <Typography variant="bodySmall" sx={{ color: 'm3.error', mt: '8px' }}>
              {error}
            </Typography>
          )}
          {loading && (
            <Box sx={{ mt: '10px', px: '10px', py: '30px', border: '1px dashed', borderColor: 'm3.onPrimaryContainer', borderRadius: '4px', display: 'flex', justifyContent: 'center' }}>
              <CircularProgress size={28} />
            </Box>
          )}
        </Box>

        {loaded && !loading && (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px', mt: '-30px' }}>
            <Box sx={{ position: 'relative' }}>
              <Img src={image} width={80} height={80} radius="10px" />
              <Box sx={{ position: 'absolute', top: -6, right: -6, width: 20, height: 20, borderRadius: '50%', bgcolor: 'm3.surfaceContainerLowest', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 1 }}>
                <EditIcon sx={{ fontSize: 15, color: 'primary.main' }} />
              </Box>
            </Box>
            <Box sx={{ flex: 1, minWidth: 0, display: 'flex', alignItems: 'center', gap: '10px' }}>
              {editingTitle ? (
                <>
                  <TextField fullWidth multiline maxRows={3} value={title} onChange={(e) => setTitle(e.target.value)} slotProps={{ htmlInput: { 'aria-label': 'Resource title' } }} />
                  <IconButton aria-label="Save title" onClick={() => setEditingTitle(false)} sx={{ bgcolor: 'primary.main', color: 'primary.contrastText', '&:hover': { bgcolor: 'primary.main' } }}>
                    <CheckIcon />
                  </IconButton>
                </>
              ) : (
                <>
                  <Typography sx={{ fontSize: 16, fontWeight: 500, flex: 1 }}>{title}</Typography>
                  <IconButton aria-label="Edit title" onClick={() => setEditingTitle(true)}>
                    <EditIcon sx={{ fontSize: 18 }} />
                  </IconButton>
                </>
              )}
            </Box>
          </Box>
        )}

        <Box sx={{ mt: loaded ? '-30px' : '-30px' }}>
          <Divider sx={{ borderColor: 'm3.onPrimaryContainer', mb: '20px' }} />
          <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
            <ActionButton text="Post" disabled={!loaded || title.trim() === ''} onPress={post} />
          </Box>
        </Box>
      </Box>
    </AppDialog>
  );
}
