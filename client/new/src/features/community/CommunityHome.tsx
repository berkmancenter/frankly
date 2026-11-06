import EditIcon from '@mui/icons-material/Edit';
import Box from '@mui/material/Box';
import ButtonBase from '@mui/material/ButtonBase';
import IconButton from '@mui/material/IconButton';
import Typography from '@mui/material/Typography';
import { useState } from 'react';
import { Link } from 'react-router';
import type { Community } from '@/api/types';
import { paths } from '@/app/paths';
import { CommunityMembershipButton } from '@/components/CommunityMembershipButton';
import { ConstrainedBody } from '@/components/ConstrainedBody';
import { EmptyPageContent } from '@/components/EmptyPageContent';
import { EventCard } from '@/components/events/EventCards';
import { Img } from '@/components/Img';
import { ShareSection } from '@/components/ShareSection';
import { LoadingState, ErrorState } from '@/components/States';
import { ThickOutlineButton } from '@/components/ThickOutlineButton';
import { useCreateEventDialog } from '@/features/events/CreateEventDialog';
import { useIsMobile } from '@/lib/useResponsive';
import { useAllEvents, useUpcomingEvents } from '@/queries/events';
import { useCommunityScope } from '@/scopes/CommunityScope';
import { appSize, appText } from '@/theme/typography';

const ABOUT_LIMIT = 160;

/** Community landing page: hero card, about, contact/share/follow, and upcoming events. */
export function CommunityHome() {
  const { community, permissions } = useCommunityScope();
  const isMobile = useIsMobile();
  const events = useUpcomingEvents(community.id);
  const createEvent = useCreateEventDialog();
  const [shown, setShown] = useState(20);

  const eventsBlock = (
    <EventsBlock
      events={events.data}
      loading={events.isPending}
      error={events.isError}
      shown={shown}
      onShowMore={() => setShown((n) => n + 5)}
      onCreate={() => createEvent.open()}
    />
  );

  const contact = <ContactSection community={community} />;
  const about = community.description ? <AboutSection description={community.description} /> : null;

  return (
    <Box component="main">
      {isMobile ? (
        <>
          <Box sx={{ height: window.innerWidth > appSize.maxCarouselSize ? 30 : 0 }} />
          <Box sx={{ position: 'relative' }}>
            <Box sx={{ maxWidth: appSize.maxCarouselSize, mx: 'auto', borderRadius: window.innerWidth > appSize.maxCarouselSize ? '10px' : 0, overflow: 'hidden' }}>
              <CommunityDetail community={community} />
            </Box>
            {permissions.canEditCommunity && (
              <Box sx={{ position: 'absolute', top: 20, right: 20 }}>
                <EditCommunityButton displayId={community.displayId} />
              </Box>
            )}
          </Box>
          <ConstrainedBody maxWidth={524}>
            <Box sx={{ height: 30 }} />
            {eventsBlock}
            <Box sx={{ height: 30 }} />
            {about && (
              <>
                {about}
                <Box sx={{ height: 30 }} />
              </>
            )}
            {contact}
            <Box sx={{ height: 30 }} />
          </ConstrainedBody>
        </>
      ) : (
        <>
          <ConstrainedBody>
            <Box sx={{ height: 48 }} />
            <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: '52px' }}>
              <Box sx={{ flex: 1, minWidth: 0 }}>
                <Box sx={{ position: 'relative', borderRadius: '10px', overflow: 'hidden' }}>
                  <CommunityDetail community={community} />
                  {permissions.canEditCommunity && (
                    <Box sx={{ position: 'absolute', top: 20, right: 20 }}>
                      <EditCommunityButton displayId={community.displayId} />
                    </Box>
                  )}
                </Box>
                <Box sx={{ height: 30 }} />
                {about && (
                  <>
                    {about}
                    <Box sx={{ height: 20 }} />
                  </>
                )}
                {contact}
                <Box sx={{ height: 30 }} />
              </Box>
              <Box sx={{ flex: 1, minWidth: 0 }}>{eventsBlock}</Box>
            </Box>
          </ConstrainedBody>
          <Box sx={{ height: 100 }} />
        </>
      )}
      {createEvent.dialog}
    </Box>
  );
}

function EditCommunityButton({ displayId }: { displayId: string }) {
  return (
    // `IconButton.filled`: primary-colored disc with a white pencil.
    <IconButton
      component={Link}
      to={paths.community(displayId).admin()}
      aria-label="Edit community"
      sx={{ bgcolor: 'primary.main', color: 'primary.contrastText', '&:hover': { bgcolor: 'primary.main', opacity: 0.9 } }}
    >
      <EditIcon />
    </IconButton>
  );
}

/** The square hero: community color, picture, name and tagline. */
function CommunityDetail({ community }: { community: Community }) {
  return (
    <Box
      sx={{
        width: '100%',
        aspectRatio: '1',
        maxHeight: appSize.maxCarouselSize,
        bgcolor: 'primary.main',
        p: '24px',
        boxSizing: 'border-box',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        textAlign: 'center',
      }}
    >
      {community.profileImageUrl && (
        <Img src={community.profileImageUrl} radius="200px" width={200} height={200} sx={{ maxWidth: '45%', height: 'auto', aspectRatio: '1' }} />
      )}
      <Typography variant="headlineMedium" sx={{ color: 'primary.contrastText', mt: '24px' }}>
        {community.name}
      </Typography>
      {community.tagLine && (
        <Typography variant="titleMedium" sx={{ color: 'primary.contrastText', mt: '16px' }}>
          {community.tagLine}
        </Typography>
      )}
    </Box>
  );
}

function AboutSection({ description }: { description: string }) {
  const [expanded, setExpanded] = useState(false);
  const long = description.length > ABOUT_LIMIT;
  const text = !long || expanded ? description : `${description.slice(0, ABOUT_LIMIT)}...`;
  return (
    <Box>
      <Typography variant="titleMedium">About Us</Typography>
      <Typography variant="bodyMedium" sx={{ mt: '10px', whiteSpace: 'pre-wrap' }}>
        {text}
      </Typography>
      {long && (
        <ButtonBase onClick={() => setExpanded((e) => !e)} sx={{ mt: '10px', display: 'block' }}>
          <Typography variant="bodyMedium" sx={{ textDecoration: 'underline', color: 'primary.main' }}>
            {expanded ? 'Less' : 'Read More'}
          </Typography>
        </ButtonBase>
      )}
    </Box>
  );
}

function ContactSection({ community }: { community: Community }) {
  const { status } = useCommunityScope();
  const isMember = status !== 'nonmember' && status !== 'banned' && status !== 'attendee';
  const email = community.contactEmail;
  const subject = `Join ${community.name} on Frankly`;
  const body = `Hey, check out ${community.name} on Frankly!`;
  return (
    <Box>
      {email && (
        <>
          <Typography sx={{ ...appText.headline4, color: 'primary.main' }}>Contact</Typography>
          <Box sx={{ height: 10 }} />
          <Typography
            component="a"
            href={`mailto:${email}`}
            sx={{ ...appText.bodyMedium, color: 'primary.main', textDecoration: 'none' }}
          >
            {email}
          </Typography>
          <Box sx={{ height: 10 }} />
        </>
      )}
      <ShareSection
        url={paths.community(community.displayId).home}
        subject={subject}
        body={body}
        size={39}
        iconSize={16}
        buttonPadding={0}
        justify="flex-start"
      />
      <Box sx={{ height: 30 }} />
      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: '12px' }}>
        {!isMember && <CommunityMembershipButton community={community} />}
        {community.settings.allowDonations && <ThickOutlineButton text="Donate" />}
      </Box>
    </Box>
  );
}

function EventsBlock({
  events,
  loading,
  error,
  shown,
  onShowMore,
  onCreate,
}: {
  events: ReturnType<typeof useUpcomingEvents>['data'];
  loading: boolean;
  error: boolean;
  shown: number;
  onShowMore: () => void;
  onCreate: () => void;
}) {
  const { community, permissions } = useCommunityScope();
  const all = useAllEvents(community.id);
  if (loading) return <LoadingState height={200} />;
  if (error) return <ErrorState message="There was an error loading events. Please refresh." />;

  if (!events || events.length === 0) {
    if (permissions.canEditCommunity) {
      const hasEvents = (all.data?.length ?? 1) > 0;
      return (
        <EmptyPageContent
          type="events"
          subtitleText={hasEvents ? 'No events found' : 'Create your first event'}
          onButtonPress={onCreate}
        />
      );
    }
    return <EmptyPageContent type="events" onButtonPress={permissions.canCreateEvent ? onCreate : undefined} />;
  }

  return (
    <Box>
      <Typography sx={{ ...appText.headline4, color: 'primary.main' }}>Upcoming Events</Typography>
      <Box sx={{ height: 10 }} />
      <Box sx={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
        {events.slice(0, shown).map((e) => (
          <EventCard key={e.id} event={e} />
        ))}
      </Box>
      {events.length > shown && (
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: '20px' }}>
          <ButtonBase
            onClick={onShowMore}
            sx={{ width: 150, height: 40, borderRadius: '10px', border: '1px solid', borderColor: 'm3.onSurface' }}
          >
            <Typography sx={appText.eyebrowSmall}>See More Events</Typography>
          </ButtonBase>
        </Box>
      )}
    </Box>
  );
}
