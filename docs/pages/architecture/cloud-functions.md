# Cloud Functions

Dart functions compiled to Node.js via `build_node_compilers` (dart2js), plus a few native JS functions for recording and SSR. All share the `data_models` package for type definitions.

## On-Call Functions (Client-Callable)

### Community

| Function                              | Purpose                                    |
| ------------------------------------- | ------------------------------------------ |
| CreateCommunity                       | Creates community doc + initial setup      |
| UpdateCommunity                       | Updates community settings/profile         |
| UpdateMembership                      | Changes user membership status             |
| ResolveJoinRequest                    | Approves/denies join request               |
| GetCommunityCapabilities              | Returns plan-based feature limits          |
| GetMembersData                        | Returns member list for admin              |
| GetUserAdminDetails                   | Returns detailed user info for admin       |
| UnsubscribeFromCommunityNotifications | Removes email notification subscription    |
| GetCommunityDonationsEnabled          | Checks if Stripe donations are configured  |
| GetCommunityPrePostEnabled            | Checks if pre/post event cards are enabled |
| GetCommunityCalendarLink              | Returns calendar subscription URL          |

### Events

| Function         | Purpose                                        |
| ---------------- | ---------------------------------------------- |
| CreateEvent      | Creates event under template                   |
| JoinEvent        | Registers participant, creates participant doc |
| EventEnded       | Marks event as ended (called on leave)         |
| SendEventMessage | Sends notification to event participants       |

### Live Meeting

| Function                                 | Purpose                                       |
| ---------------------------------------- | --------------------------------------------- |
| GetMeetingJoinInfo                       | Returns Agora token + channel for main room   |
| GetBreakoutRoomJoinInfo                  | Returns Agora token + channel for breakout    |
| GetBreakoutRoomAssignment                | Returns assigned room for late-joining user   |
| InitiateBreakouts                        | Starts breakout session (sets status=pending) |
| CheckAssignToBreakouts                   | Idempotent: assigns participants if ready     |
| CheckHostlessGoToBreakouts               | Idempotent: transitions hostless waiting room |
| CheckAdvanceMeetingGuide                 | Idempotent: advances agenda item if all ready |
| ReassignBreakoutRoom                     | Moves user to different breakout              |
| UpdateBreakoutRoomFlagStatus             | Flags room as needing help                    |
| KickParticipant                          | Removes participant (admin)                   |
| VoteToKick                               | Democratic kick vote                          |
| ResetParticipantAgendaItems              | Clears user-submitted items                   |
| GetUserIdFromAgoraId                     | Resolves numeric Agora UID to user ID         |
| CreateLiveStream                         | Sets up livestream config                     |
| GetMeetingChatSuggestionData             | Returns suggestion/poll data                  |
| GetMeetingPollData                       | Returns poll results                          |
| ToggleLikeDislikeOnMeetingUserSuggestion | Votes on user suggestion                      |

### Payments (Stripe)

| Function                          | Purpose                              |
| --------------------------------- | ------------------------------------ |
| CreateStripeConnectedAccount      | Sets up Stripe Connect for community |
| GetStripeConnectedAccountLink     | Returns Stripe dashboard link        |
| CreateDonationCheckoutSession     | Creates one-time donation checkout   |
| CreateSubscriptionCheckoutSession | Creates subscription checkout        |
| GetStripeBillingPortalLink        | Returns billing portal URL           |
| GetStripeSubscriptionPlanInfo     | Returns current plan details         |
| UpdateStripeSubscriptionPlan      | Changes subscription tier            |
| CancelStripeSubscriptionPlan      | Cancels subscription                 |

### Utility

| Function                             | Purpose                        |
| ------------------------------------ | ------------------------------ |
| GetServerTimestamp / ServerTimestamp | Clock synchronization          |
| CreateAnnouncement                   | Creates community announcement |

## Firestore Triggers

| Trigger                    | Path                               | Action                                                       |
| -------------------------- | ---------------------------------- | ------------------------------------------------------------ |
| EventOnCreate/Update       | `.../events/{eId}`                 | Schedules email reminders via Cloud Tasks                    |
| EventParticipantOnWrite    | `.../event-participants/{pId}`     | Updates participant count estimates                          |
| OnDiscussionThread/Comment | Discussion thread paths            | Sends notifications                                          |
| CommunityOnCreate          | `community/{cId}`                  | Initial community setup                                      |
| OnCommunityMembership      | Membership paths                   | Membership side effects                                      |
| OnPartnerAgreements        | Partner paths                      | Partner configuration                                        |
| OnTemplate                 | Template paths                     | Template setup                                               |
| produceSessions (JS)       | `recording-sessions/{id}` onUpdate | Downloads and processes recording when status=stopped        |
| UpdatePresenceStatus       | RTDB `status/{uid}`                | Writes Firestore offline status when RTDB detects disconnect |

## Scheduled Functions

| Function                         | Schedule     | Purpose                                       |
| -------------------------------- | ------------ | --------------------------------------------- |
| TriggerEmailDigests              | Weekly       | Sends upcoming-events email digest to members |
| UpdateLiveStreamParticipantCount | Every minute | Polls Agora for livestream viewer count       |

## HTTP/Webhooks

| Function                          | Source               | Purpose                                |
| --------------------------------- | -------------------- | -------------------------------------- |
| CalendarFeedIcs / CalendarFeedRss | Client request       | Serves .ics/.rss calendar feeds        |
| ShareLink                         | Client request       | Generates share link preview pages     |
| ServeIndex (JS)                   | All unmatched routes | SSR index.html for SPA                 |
| StripeWebhooks                    | Stripe               | Payment event processing               |
| StripeConnectedAccountWebhooks    | Stripe Connect       | Connected account events               |
| MuxWebhooks                       | Mux                  | Video streaming status events          |
| agoraRecordingWebhook (JS)        | Agora                | Cloud recording status callbacks       |
| ExtendCloudTaskScheduler          | Cloud Tasks          | Re-schedules tasks beyond 28-day limit |
| EmailEventReminder                | Cloud Tasks          | Sends reminder at scheduled time       |

## The "Check" Pattern

Three functions use an idempotent convergent pattern for hostless meetings where no single client is the authority:

- `CheckAssignToBreakouts`
- `CheckHostlessGoToBreakouts`
- `CheckAdvanceMeetingGuide`

**How it works:** Multiple clients call simultaneously (via `HostlessActionFallbackController` with probabilistic timer). Server inspects current state -- if already done, returns success (no-op). If not, performs action atomically. `processingId` prevents duplicate breakout assignment processing.\n\nSafe to call redundantly. Client doesn't need to know if it "won".
