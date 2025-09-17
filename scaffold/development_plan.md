# Event Data Export Optimization Project

## 1. Related Code Locations

### Main File Locations:
- **Event Export Main File**: `client/lib/features/events/features/event_page/data/providers/event_provider.dart`
  - `generateRegistrationDataCsvFile()` method (lines 368-443) - handles registration data export
  - `generateChatAndSugguestionsDataCsv()` method (lines 445-518) - handles chat and suggestions export

- **UI Trigger Points**: `client/lib/features/events/features/event_page/presentation/widgets/event_info.dart`
  - `_downloadRegistrationData()` method (lines 240-269) - triggers registration data download
  - `_downloadChatsAndSuggestions()` method (lines 271-289) - triggers chat and suggestions download

- **Menu Option Definitions**: `client/lib/features/events/features/event_page/presentation/widgets/event_pop_up_menu_button.dart`
  - `EventPopUpMenuSelection` enum (lines 11-18) - defines download options
  - `_getText()` method (lines 129-144) - defines menu text
  - `_getIconAsset()` method (lines 146-163) - defines menu icons

## 2. CSV Format Difference Analysis

### Registration Data Comparison:

**Current Format (registration-data-current.csv):**
- Frankly ID → needs to be changed to User ID
- Member status → needs to be changed to Member Status (case consistency)
- Missing Join Time field
- Missing Room Assigned field  
- Answer 1, Answer 2 → needs to be changed to actual question text or add Question fields

**New Format (registration-data-new.csv):**
- User ID (corrected)
- Member Status (corrected)
- Added Join Time field
- Added Room Assigned field
- Added Question 1, Question 2 fields to display question text

### Chats & Suggestions Comparison:

**Current Format (chats-suggestions-data-current.csv):**
- Chat and suggestions mixed in the same file
- Uses Name, Email fields
- RoomId shows actual IDs
- Contains Type, #, Upvotes, Downvotes, AgendaItemId fields

**New Format Separation:**

**Chat Data (chat-data-new.csv):**
- Contains only chat data
- Uses User ID instead of Name, Email
- Room shows room names (Main room, Waiting room, 1, 2, 3, etc.)
- Removes Type, #, Upvotes, Downvotes, AgendaItemId fields

**Polls & Suggestions (polls-suggestions-data-new.csv):**
- Contains poll and suggestion data
- Uses User ID instead of Name, Email
- Added Prompt field to display agenda item prompt text
- Room shows room names
- Retains Upvotes, Downvotes fields

## 3. Development Phase Planning

### Phase 1: Registration Data Optimization (Simplest)
**Goal**: Directly modify `generateRegistrationDataCsvFile()` method
**Changes**:
- [x] Change "Frankly ID" to "User ID"
- [x] Change "Member status" to "Member Status" 
- [x] Add "Join Time" field (need to get first join time from participant data)
- [x] Add "Room Assigned" field (need to get from breakout room data)
- [x] Change "Answer 1", "Answer 2" to "Question 1", "Answer 1", "Question 2", "Answer 2" format
- [x] Change filename to `registration-data-{$EventId}.csv`

### Phase 2: Separate Chats & Suggestions Export Functions
**Goal**: Directly refactor `generateChatAndSugguestionsDataCsv()` into two independent methods
**Changes**:
- [ ] Refactor to `generateChatDataCsv()` method - handles only chat data
- [ ] Refactor to `generatePollsSuggestionsDataCsv()` method - handles poll and suggestion data
- [ ] Remove the original mixed method

### Phase 3: Chat Data Format Optimization
**Goal**: Implement new chat data export format
**Changes**:
- [ ] Remove Type, #, Name, Email, Upvotes, Downvotes, AgendaItemId fields
- [ ] Change "Created" to "Time"
- [ ] Add "User ID" field
- [ ] Change "RoomId" to "Room" and display room names
- [ ] Change filename to `chat-data-{$EventId}.csv`

### Phase 4: Polls & Suggestions Data Format Optimization  
**Goal**: Implement new poll and suggestion data export format
**Changes**:
- [ ] Remove Name, Email fields, add User ID field
- [ ] Change "Created" to "Time"
- [ ] Add "Prompt" field (need to get prompt text from agenda items)
- [ ] Change "RoomId" to "Room" and display room names
- [ ] Retain Upvotes, Downvotes fields
- [ ] Change filename to `polls-suggestions-data-{$EventId}.csv`

### Phase 5: UI Menu Separation
**Goal**: Split download menu from one button into two
**Changes**:
- [ ] Add `downloadChatData` and `downloadPollsSuggestionsData` to `EventPopUpMenuSelection` enum
- [ ] Modify `_getMenuOptions()` method to display two separate options
- [ ] Modify `_getText()` method to add corresponding text
- [ ] Modify `_getIconAsset()` method to add corresponding icons
- [ ] Add corresponding handler methods in `event_info.dart`
- [ ] Completely remove original `downloadChatsAndSuggestions` option and related methods

### Phase 6: Multi-language Optimization
**Goal**: Add multi-language support
**Changes**:
- [ ] Add related multi-language text in `client/lib/l10n/` directory
- [ ] Update all hardcoded English text to multi-language keys
- [ ] Test multi-language display effects

## 4. Technical Considerations

### Data Source Requirements:

#### **Join Time** (First Join Time)
- **Data Source**: `Participant.mostRecentPresentTime` field
- **File Locations**: 
  - `data_models/lib/events/event.dart` (line 308) - Participant model definition
  - `client/lib/features/events/features/live_meeting/data/services/firestore_live_meeting_service.dart` (line 330) - update logic
- **Description**: This field is updated when users join meetings, recording the most recent presence time

#### **Room Assigned** (Breakout Room Assignment)
- **Data Source**: `Participant.currentBreakoutRoomId` field + `BreakoutRoom` records
- **File Locations**:
  - `data_models/lib/events/event.dart` (line 301) - Participant.currentBreakoutRoomId
  - `data_models/lib/events/live_meetings/live_meeting.dart` (lines 113-141) - BreakoutRoom model
  - `firebase/functions/lib/events/live_meetings/breakouts/assign_to_breakouts.dart` - assignment logic
- **Description**: Participant's currentBreakoutRoomId corresponds to BreakoutRoom.roomId, can get roomName

#### **Question Text** (Breakout Room Question Text)
- **Data Source**: `BreakoutRoomDefinition.breakoutQuestions` array
- **File Locations**:
  - `data_models/lib/events/event.dart` (lines 446-460) - BreakoutRoomDefinition model
  - `data_models/lib/events/event.dart` (lines 539-551) - BreakoutQuestion model
- **Description**: Each BreakoutQuestion has title and answers, can get question text and options

#### **Prompt Text** (Agenda Item Prompt Text)
- **Data Source**: `AgendaItem.content` or `AgendaItem.title` field
- **File Locations**:
  - `data_models/lib/events/event.dart` (lines 378-411) - AgendaItem model
  - `client/lib/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_presenter.dart` (lines 164-185) - content processing logic
- **Description**: Depending on AgendaItemType, content or title contains prompt text

#### **Room Names** (Room Name Mapping)
- **Data Source**: `BreakoutRoom.roomName` field + constant definitions
- **File Locations**:
  - `data_models/lib/events/live_meetings/live_meeting.dart` (line 109) - `breakoutsWaitingRoomId = 'waiting-room'`
  - `data_models/lib/events/live_meetings/live_meeting.dart` (lines 119-121) - BreakoutRoom.roomName
  - `firebase/functions/lib/events/live_meetings/breakouts/assign_to_breakouts.dart` (line 604) - 'Waiting Room' name
- **Description**: 
  - Main room: Usually no specific roomId, displays as "Main room"
  - Waiting room: roomId = 'waiting-room', displays as "Waiting room"  
  - Breakout rooms: roomName is usually numbers "1", "2", "3", etc.

### File Naming Strategy:
- Current files: `registration-data-current.csv`, `chats-suggestions-data-current.csv`
- New files: `registration-data-new.csv`, `chat-data-new.csv`, `polls-suggestions-data-new.csv`
