# Architecture Notes

## Timing and Flow

### Event Timing Locations

Generally this has been cleaned up and clarified. Event timing is organized as follows:

| Datum            | How it's stored / accessed                                      |
| ---------------- | --------------------------------------------------------------- |
| Scheduled start  | Event.scheduledTime                                             |
| Planned duration | Event.durationInMinutes                                         |
| Scheduled end    | Computed: scheduledTime + durationInMinutes                     |
| Actual end       | LiveMeeting.events.last.timestamp where .event == finishMeeting |
