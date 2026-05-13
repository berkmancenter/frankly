import * as functions from 'firebase-functions'
import { Community, Template, Event } from '../types'

const calendarLink = require('calendar-link') as {
    google: (event: CalendarEvent) => string
    outlook: (event: CalendarEvent) => string
    office365: (event: CalendarEvent) => string
    ics: (event: CalendarEvent) => string
}

interface CalendarEvent {
    title: string
    description: string
    start: string
    end: string
    organizer?: string
}

function buildCalendarEvent(opts: {
    community: Community
    template: Template
    event: Event
    organizerEmail?: string
}): CalendarEvent {
    const { community, template, event } = opts
    const domain = functions.config().app?.domain as string
    const eventTitle = event.title ?? template.title ?? ''
    const time = (event.scheduledTime ?? new Date()).toISOString()
    const durationMs = (event.durationInMinutes ?? 60) * 60 * 1000
    const end = new Date(new Date(time).getTime() + durationMs).toISOString()
    const description = `https://${domain}/space/${event.communityId}/discuss/${event.templateId}/${event.id}`

    return {
        title: `${eventTitle} - ${community.name}`,
        description,
        start: time,
        end,
        organizer: opts.organizerEmail ? `mailto:${opts.organizerEmail}` : undefined,
    }
}

export const calendarLinkUtil = {
    getGoogleLink(opts: { community: Community; template: Template; event: Event }): string {
        return calendarLink.google(buildCalendarEvent(opts))
    },

    getOffice365Link(opts: { community: Community; template: Template; event: Event }): string {
        return calendarLink.office365(buildCalendarEvent(opts))
    },

    getOutlookLink(opts: { community: Community; template: Template; event: Event }): string {
        const ev = buildCalendarEvent(opts)
        const details: Record<string, string> = {
            path: '/calendar/action/compose',
            rru: 'addevent',
            startdt: ev.start,
            enddt: ev.end,
            subject: ev.title,
            body: ev.description,
            location: ev.description,
            allday: 'false',
        }
        const qs = Object.entries(details)
            .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
            .join('&')
        return `https://outlook.live.com/calendar/0/action/compose?${qs}`
    },

    getICS(opts: {
        community: Community
        template: Template
        event: Event
        organizerEmail?: string
    }): string {
        const raw = calendarLink.ics(
            buildCalendarEvent({ ...opts, organizerEmail: opts.organizerEmail })
        )
        const parts = raw.split('charset=utf8,')
        return parts.length > 1 ? decodeURIComponent(parts[1]) : decodeURIComponent(raw)
    },
}
