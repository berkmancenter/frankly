import EmailIcon from '@mui/icons-material/EmailOutlined';
import LinkIcon from '@mui/icons-material/Link';
import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import Tooltip from '@mui/material/Tooltip';
import { t } from '@lingui/core/macro';
import type { ReactNode } from 'react';
import { FacebookF, LinkedInIn, XLogo } from './BrandIcons';
import { useToast } from './Toast';

export type ShareType = 'facebook' | 'twitter' | 'linkedin' | 'email' | 'link';

interface ShareSectionProps {
  url: string;
  subject: string;
  body: string;
  /** Diameter of each round button (the Flutter default is 40). */
  size?: number;
  iconSize?: number;
  /** Margin around each button. */
  buttonPadding?: number;
  /** `space-evenly` spreads five buttons across the row; `start` packs them left. */
  justify?: 'space-evenly' | 'flex-start';
  onShare?: (type: ShareType) => void;
}

export const absoluteUrl = (path: string) =>
  path.startsWith('http') ? path : `${window.location.origin}${path}`;

/** `ShareSection`: five round, 1px-primary-bordered share buttons. */
export function ShareSection({
  url,
  subject,
  body,
  size = 40,
  iconSize = 20,
  buttonPadding = 10,
  justify = 'space-evenly',
  onShare,
}: ShareSectionProps) {
  const toast = useToast();
  const href = absoluteUrl(url);
  const enc = encodeURIComponent;

  const open = (target: string) => window.open(target, '_blank', 'noopener,noreferrer');

  const buttons: { type: ShareType; label: string; icon: ReactNode; run: () => void }[] = [
    {
      type: 'facebook',
      label: t({ id: 'shareSection.facebook', message: 'Share on Facebook' }),
      icon: <FacebookF sx={{ fontSize: iconSize }} />,
      run: () => open(`https://www.facebook.com/sharer/sharer.php?u=${enc(href)}`),
    },
    {
      type: 'twitter',
      label: t({ id: 'shareSection.twitter', message: 'Share on X' }),
      icon: <XLogo sx={{ fontSize: iconSize }} />,
      run: () => open(`https://twitter.com/intent/tweet?url=${enc(href)}&text=${enc(body)}`),
    },
    {
      type: 'linkedin',
      label: t({ id: 'shareSection.linkedin', message: 'Share on LinkedIn' }),
      icon: <LinkedInIn sx={{ fontSize: iconSize }} />,
      run: () => open(`https://www.linkedin.com/sharing/share-offsite/?url=${enc(href)}`),
    },
    {
      type: 'email',
      label: t({ id: 'shareSection.email', message: 'Share by email' }),
      icon: <EmailIcon sx={{ fontSize: iconSize }} />,
      run: () => {
        window.location.href = `mailto:?subject=${enc(subject)}&body=${enc(`${body}\n\n${href}`)}`;
      },
    },
    {
      type: 'link',
      label: t({ id: 'shareSection.copyLink', message: 'Copy link' }),
      icon: <LinkIcon sx={{ fontSize: iconSize }} />,
      run: () => {
        void navigator.clipboard?.writeText(href);
        toast.success(t({ id: 'shareSection.linkCopied', message: 'Link Copied!' }));
      },
    },
  ];

  return (
    <Box sx={{ display: 'flex', flexWrap: 'wrap', justifyContent: justify }}>
      {buttons.map((b) => (
        <Tooltip key={b.type} title={b.label}>
          <ButtonBase
            aria-label={b.label}
            onClick={() => {
              b.run();
              onShare?.(b.type);
            }}
            sx={{
              width: size,
              height: size,
              m: `${buttonPadding}px`,
              borderRadius: '50%',
              border: '1px solid',
              borderColor: 'primary.main',
              color: 'primary.main',
              bgcolor: 'transparent',
              boxSizing: 'border-box',
            }}
          >
            {b.icon}
          </ButtonBase>
        </Tooltip>
      ))}
    </Box>
  );
}
