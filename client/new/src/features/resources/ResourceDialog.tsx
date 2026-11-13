import CheckIcon from '@mui/icons-material/Check';
import EditIcon from '@mui/icons-material/Edit';
import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import CircularProgress from '@mui/material/CircularProgress';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import { t } from '@lingui/core/macro';
import { useState } from 'react';
import { useApi } from '@/api/ApiProvider';
import type { CommunityResource } from '@/api/types';
import { ActionButton } from '@/components/ActionButton';
import { AppDialog } from '@/components/AppDialog';
import { Img } from '@/components/Img';
import { Upload } from '@/components/Upload';
import { useToast } from '@/components/Toast';
import { useCreateResource, useUpdateResource } from '@/queries/content';
import { useCommunityScope } from '@/scopes/CommunityScope';
import { colors, fontSizes } from "@/theme/tokens";

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
  const [uploadingImage, setUploadingImage] = useState(false);

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
      setError(e instanceof Error ? e.message : t`Could not load that link.`);
    } finally {
      setLoading(false);
    }
  };

  const post = async () => {
    try {
      if (resource) await update.mutateAsync({ resourceId: resource.id, patch: { url: loadedUrl, title, image } });
      else await create.mutateAsync({ url: loadedUrl, title, image });
      toast.success(resource ? t`Resource updated` : t`Resource added`);
      onClose();
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  return (
    <AppDialog open onClose={onClose} fullscreenOnMobile maxWidth={600}>
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: '50px', pt: '10px' }}>
        <Box>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <TextField
              fullWidth
              placeholder={t`Paste or enter URL`}
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              error={!!error}
              slotProps={{ htmlInput: { 'aria-label': t`Resource URL` } }}
              sx={{ '& .MuiOutlinedInput-root': { '& fieldset': { borderColor: error ? colors.error : 'primary.main' }, bgcolor: error ? colors.errorContainer : undefined } }}
            />
            {dirty && url.trim() && (
              <IconButton
                aria-label={t`Load link`}
                onClick={load}
                sx={{ width: 50, height: 50, bgcolor: 'primary.main', color: 'primary.contrastText', '&:hover': { bgcolor: 'primary.main', opacity: 0.9 } }}
              >
                <CheckIcon />
              </IconButton>
            )}
          </Box>
          {error && (
            <Typography sx={{ fontSize: fontSizes.xs, color: colors.error, mt: '8px' }}>
              {error}
            </Typography>
          )}
          {loading && (
            <Box sx={{ mt: '10px', px: '10px', py: '30px', border: '1px dashed', borderColor: colors.onPrimaryContainer, borderRadius: '4px', display: 'flex', justifyContent: 'center' }}>
              <CircularProgress size={28} />
            </Box>
          )}
        </Box>

        {loaded && !loading && (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px', mt: '-30px' }}>
            <ButtonBase
              aria-label={t`Change image`}
              onClick={() => setUploadingImage(true)}
              sx={{ position: 'relative', display: 'block', borderRadius: '10px' }}
            >
              <Img src={image} width={80} height={80} radius="10px" />
              <Box sx={{ position: 'absolute', top: -6, right: -6, width: 20, height: 20, borderRadius: '50%', bgcolor: colors.surfaceContainerLowest, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 1 }}>
                <EditIcon sx={{ fontSize: 15, color: 'primary.main' }} />
              </Box>
            </ButtonBase>
            <Box sx={{ flex: 1, minWidth: 0, display: 'flex', alignItems: 'center', gap: '10px' }}>
              {editingTitle ? (
                <>
                  <TextField fullWidth multiline maxRows={3} value={title} onChange={(e) => setTitle(e.target.value)} slotProps={{ htmlInput: { 'aria-label': t`Resource title` } }} />
                  <IconButton aria-label={t`Save title`} onClick={() => setEditingTitle(false)} sx={{ bgcolor: 'primary.main', color: 'primary.contrastText', '&:hover': { bgcolor: 'primary.main' } }}>
                    <CheckIcon />
                  </IconButton>
                </>
              ) : (
                <>
                  <Typography sx={{ fontSize: 16, fontWeight: 500, flex: 1 }}>{title}</Typography>
                  <IconButton aria-label={t`Edit title`} onClick={() => setEditingTitle(true)}>
                    <EditIcon sx={{ fontSize: 18 }} />
                  </IconButton>
                </>
              )}
            </Box>
          </Box>
        )}

        <Box sx={{ mt: loaded ? '-30px' : '-30px' }}>
          <Divider sx={{ borderColor: colors.onPrimaryContainer, mb: '20px' }} />
          <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
            <ActionButton text={t`Post`} disabled={!loaded || title.trim() === ''} onPress={post} />
          </Box>
        </Box>
      </Box>
      {/* A second dialog stacked above this one; closing it leaves this one open. */}
      <AppDialog open={uploadingImage} onClose={() => setUploadingImage(false)} maxWidth={500} padding={30} ariaLabel={t`Upload image`}>
        <Box sx={{ pt: '20px' }}>
          <Upload
            onUploaded={({ url }) => {
              setImage(url);
              setUploadingImage(false);
            }}
          />
        </Box>
      </AppDialog>
    </AppDialog>
  );
}
