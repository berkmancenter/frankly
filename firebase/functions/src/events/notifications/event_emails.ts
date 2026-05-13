import * as functions from 'firebase-functions'
import { auth } from 'firebase-admin'
import {
    Community,
    Event,
    EventStatus,
    Template,
    Participant,
    ParticipantStatus,
    EventEmailLog,
    EventEmailType,
    SendGridEmailMessage,
    EmailAttachment,
} from '../../types'
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils'
import { firebaseAuthUtils } from '../../utils/infra/firebase_auth_utils'
import { sendEmailClient } from '../../utils/send_email_client'
import { calendarLinkUtil } from '../../utils/calendar_link_util'
import { subscriptionPlanUtil } from '../../utils/subscription_plan_util'
import { generateEmailEventInfo } from '../../utils/email_templates'

const EMAIL_REMINDER_OFFSET_MS: Record<string, number> = {
    [EventEmailType.oneDayReminder]: 24 * 60 * 60 * 1000,
    [EventEmailType.oneHourReminder]: 60 * 60 * 1000,
}

export class EventEmails {
    async enqueueReminders(event: Event): Promise<void> {
        const timeUntilEvent = event.scheduledTime
            ? event.scheduledTime.getTime() - Date.now()
            : null

        console.log('time until event ms:', timeUntilEvent)
        if (timeUntilEvent === null) {
            console.log('No event time scheduled')
            return
        }

        // Lazy import to avoid circular dependency with email_event_reminder
        const { EmailEventReminder } = await import('./email_event_reminder')

        for (const [emailType, offsetMs] of Object.entries(EMAIL_REMINDER_OFFSET_MS)) {
            const doubleOffset = offsetMs * 2
            if (timeUntilEvent > doubleOffset) {
                console.log('Scheduling', emailType)
                const scheduledTime = new Date(event.scheduledTime!.getTime() - offsetMs)
                await new EmailEventReminder().schedule(
                    {
                        communityId: event.communityId!,
                        templateId: event.templateId!,
                        eventId: event.id!,
                        eventEmailType: emailType as EventEmailType,
                    },
                    scheduledTime
                )
            }
        }
    }

    async sendEmailsToUsers({
        eventPath,
        emailType,
        event,
        userIds,
        sendId,
    }: {
        eventPath: string
        emailType: EventEmailType
        event?: Event
        userIds?: string[]
        sendId?: string
    }): Promise<void> {
        await firestore.runTransaction(async (transaction) => {
            await this._sendEmailsToUsersInTransaction({
                transaction,
                event,
                eventPath,
                userIds,
                emailType,
                sendId,
            })
        })
    }

    private _getEmailSubject(emailType: EventEmailType, eventTitle: string): string {
        if (emailType === EventEmailType.updated) return `Schedule Change for ${eventTitle}`
        if (emailType === EventEmailType.initialSignUp)
            return `Registration Confirmation for ${eventTitle}`
        if (emailType === EventEmailType.oneDayReminder) return `Starting in 1 day: ${eventTitle}`
        if (emailType === EventEmailType.oneHourReminder) return `Starting in 1 hour: ${eventTitle}`
        if (emailType === EventEmailType.canceled) return `Event Cancelled: ${eventTitle}`
        return eventTitle
    }

    private async _sendEmailsToUsersInTransaction({
        transaction,
        eventPath,
        emailType,
        sendId,
        event,
        userIds,
    }: {
        transaction: FirebaseFirestore.Transaction
        eventPath: string
        emailType: EventEmailType
        sendId?: string
        event?: Event
        userIds?: string[]
    }): Promise<void> {
        sendId = sendId ?? ''
        console.log('Sending', emailType, 'with sendId:', sendId)

        const eventLocal: Event =
            event ??
            (await firestoreUtils.getFirestoreObject({
                transaction,
                path: eventPath,
                constructor: (map) => map as unknown as Event,
            }))

        const participantSnaps = await firestore.collection(`${eventPath}/event-participants`).get()
        const participants: Participant[] = participantSnaps.docs.map((doc) => ({
            ...(firestoreUtils.fromFirestoreJson(doc.data()) as unknown as Participant),
            id: doc.id,
        }))

        if (eventLocal.status === EventStatus.canceled && emailType !== EventEmailType.canceled) {
            console.log('Not sending email for canceled event.')
            return
        }

        let idsToEmail = new Set(
            participants.filter((p) => p.status === ParticipantStatus.active).map((p) => p.id!)
        )

        if (userIds && userIds.length > 0) {
            idsToEmail = new Set([...idsToEmail].filter((id) => userIds.includes(id)))
        }

        const emailLogsPath = `community/${eventLocal.communityId}/templates/${eventLocal.templateId}/events/${eventLocal.id}/email-logs`
        const emailLogsSnap = await firestore.collection(emailLogsPath).get()
        const emailLogs: EventEmailLog[] = emailLogsSnap.docs.map(
            (d) => firestoreUtils.fromFirestoreJson(d.data()) as unknown as EventEmailLog
        )

        for (const log of emailLogs.filter(
            (l) => l.eventEmailType === emailType && l.sendId === sendId
        )) {
            idsToEmail.delete(log.userId!)
        }

        const lookedUpUsers = await firebaseAuthUtils.getUsers([...idsToEmail])
        if (lookedUpUsers.length === 0) {
            console.log('No users found.')
            return
        }

        let organizer: auth.UserRecord | undefined
        const organizerLookup = await firebaseAuthUtils.getUsers([eventLocal.creatorId!])
        if (organizerLookup.length > 0) organizer = organizerLookup[0]

        const community: Community = await firestoreUtils.getFirestoreObject({
            transaction,
            path: `community/${eventLocal.communityId}`,
            constructor: (map) => map as unknown as Community,
        })
        const template: Template = await firestoreUtils.getFirestoreObject({
            transaction,
            path: `community/${eventLocal.communityId}/templates/${eventLocal.templateId}`,
            constructor: (map) => map as unknown as Template,
        })

        const capabilities = await subscriptionPlanUtil.calculateCapabilities(
            eventLocal.communityId!
        )
        const hasPrePost = capabilities.hasPrePost ?? false
        const noReplyEmailAddr = functions.config().app?.no_reply_email as string

        for (const user of lookedUpUsers) {
            console.log('Sending', emailType, 'to user:', user.uid)
            const messageContent = this._getEmailContent({
                community,
                template,
                event: eventLocal,
                participants,
                emailType,
                userRecord: user,
                allowPrePost: hasPrePost,
                eventOrganizer: organizer,
            })

            await sendEmailClient.sendEmail(
                {
                    to: [user.email!],
                    from: `${community.name} <${noReplyEmailAddr}>`,
                    message: messageContent,
                },
                { transaction }
            )

            const logRef = firestore.collection(emailLogsPath).doc()
            const logEntry = {
                userId: user.uid,
                eventEmailType: emailType,
                createdAt: new Date(),
                sendId,
            }
            transaction.set(
                logRef,
                firestoreUtils.toFirestoreJson(logEntry as unknown as Record<string, unknown>)
            )
        }
    }

    private _getEmailContent({
        community,
        template,
        event,
        participants,
        emailType,
        userRecord,
        allowPrePost,
        eventOrganizer,
    }: {
        community: Community
        template: Template
        event: Event
        participants: Participant[]
        emailType: EventEmailType
        userRecord: auth.UserRecord
        allowPrePost: boolean
        eventOrganizer?: auth.UserRecord
    }): SendGridEmailMessage {
        const linkPrefix = functions.config().app?.full_url as string
        const link = `${linkPrefix}/space/${event.communityId}/discuss/${event.templateId}/${event.id}`
        const communityUrl = `${linkPrefix}/space/${event.communityId}`
        const tz = event.scheduledTimeZone ?? 'America/Los_Angeles'

        const scheduledDate = event.scheduledTime
            ? new Intl.DateTimeFormat('en-US', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                  timeZone: tz,
              }).format(event.scheduledTime)
            : ''
        const scheduledTime = event.scheduledTime
            ? new Intl.DateTimeFormat('en-US', {
                  hour: 'numeric',
                  minute: '2-digit',
                  timeZone: tz,
              }).format(event.scheduledTime)
            : ''
        const timeZoneAbbreviation =
            new Intl.DateTimeFormat('en-US', {
                timeZoneName: 'short',
                timeZone: tz,
            })
                .formatToParts(event.scheduledTime ?? new Date())
                .find((p) => p.type === 'timeZoneName')?.value ?? tz

        let participantsText = `are ${participants.length} participants`
        if (participants.length === 1) participantsText = 'is 1 participant'

        let imgUrl = community.profileImageUrl ?? ''
        if (imgUrl.includes('picsum')) imgUrl = imgUrl.replace('.webp', '.jpg')

        const eventTitle = event.title ?? template.title ?? ''
        const eventImage = event.image ?? template.image

        const calendarGoogleLink = calendarLinkUtil.getGoogleLink({ community, template, event })
        const calendarOffice365Link = calendarLinkUtil.getOffice365Link({
            community,
            template,
            event,
        })
        const calendarOutlookLink = calendarLinkUtil.getOutlookLink({ community, template, event })
        const calendarICS = calendarLinkUtil.getICS({
            community,
            template,
            event,
            organizerEmail: eventOrganizer?.email,
        })

        const actionTitles: Partial<Record<EventEmailType, string>> = {
            [EventEmailType.canceled]: 'Event Cancelled',
            [EventEmailType.updated]: 'Event Update',
            [EventEmailType.initialSignUp]: 'Registration',
            [EventEmailType.oneDayReminder]: 'Reminder',
            [EventEmailType.oneHourReminder]: 'Reminder',
        }
        const actionTitle = actionTitles[emailType] ?? 'Event Update'

        const headers: Partial<Record<EventEmailType, string>> = {
            [EventEmailType.canceled]: 'Your event has been CANCELLED.',
            [EventEmailType.updated]: 'Your event has been CHANGED.',
            [EventEmailType.initialSignUp]: 'You are registered for an upcoming event!',
            [EventEmailType.oneDayReminder]: 'You are registered for an upcoming event!',
            [EventEmailType.oneHourReminder]: 'Your event is beginning in one hour!',
        }
        const header = headers[emailType] ?? ''

        const content = generateEmailEventInfo({
            actionTitle,
            cancellation: emailType === EventEmailType.canceled,
            eventTitle,
            eventImage,
            eventDateDisplay: `${scheduledDate} at ${scheduledTime} ${timeZoneAbbreviation}`,
            bannerImgUrl: imgUrl,
            communityId: community.id!,
            communityName: community.name,
            cancelUrl: `${link}?cancel=true`,
            detailsUrl: `${link}?uid=${userRecord.uid}`,
            communityUrl,
            participantsText,
            header,
            calendarGoogleLink,
            calendarOffice365Link,
            calendarOutlookLink,
            event,
            userRecord,
            allowPrePost,
        })

        const attachments: EmailAttachment[] = []
        if (calendarICS) {
            attachments.push({
                filename: 'invite.ics',
                content: calendarICS,
                contentType: 'text/calendar',
            })
        }

        return {
            subject: this._getEmailSubject(emailType, eventTitle),
            html: content,
            attachments,
        }
    }
}
