import pandas as pd
from datetime import datetime
from pandas.core.frame import DataFrame
import stripe
import numpy as np
import firebase_admin
from firebase_admin import auth
from firebase_admin import credentials, firestore
from collections import defaultdict
import base64
from twilio.rest import Client as TwilioClient
from google.cloud import exceptions

SUPERADMIN = [
    'dantheman252@gmail.com',
    'bturtel@gmail.com',
    'ben@myjunto.app',
    'danny@myjunto.app',
    'natalie@myjunto.app',
    'zeniarkim@gmail.com'
]


def initialize_firestore(fb_key, use_prod=False):
    # TODO: Switch if use_prod changes
    if not firebase_admin._apps:
        if use_prod:
            firebase_admin.initialize_app(credentials.Certificate(fb_key))
        else:
            firebase_admin.initialize_app(credentials.Certificate(fb_key))


def get_table_download_link(df, name=None, columns=None, index=True):
    """Generates a link allowing the data in a given panda dataframe to be downloaded
    in:  dataframe
    out: href string
    """
    if name is None:
        name = "kazm-data.csv"
    csv = df.to_csv(columns=columns, index=index)
    # some strings <-> bytes conversions necessary here
    b64 = base64.b64encode(csv.encode()).decode()
    href = f'<a href="data:file/csv;base64,{b64}" download="{name}">Download csv file</a>'
    return href


def get_params_from_urls(url, use_prod=True):
    '''Given a URL, returns (junto_id, topic_id, discussion_id)'''
    parts = url.split('.')[-1].split('/')
    return parts[2], parts[4], parts[5]  # After migration


def nestedField(somedict, keylist):
    d = somedict
    for k in keylist:
        if d and k in d:
            d = d[k]
        else:
            return None
    return d


class Twilio:
    def __init__(self, account_sid, account_secret):
        self.client = TwilioClient(account_sid, account_secret)

    def get_twilio_room(self, unique_name):
        # TODO: Remove date filter
        # print(unique_name)
        trs = self.client.video.rooms.list(
            limit=10, unique_name=unique_name, status='completed')
        # Participants > 1 first, then by duration
        return sorted(trs, key=lambda r: (len(r.participants.list()) > 1, r.duration), reverse=True)[0]


class Stripe:
    # TODO: User-based credentialing
    def __init__(self, api_key):
        stripe.api_key = api_key
        stripe.api_version = "2020-08-27"

    def stripe_get_data(self, resource, start_date=None, end_date=None, **kwargs):
        if start_date:
            # convert to unix timestamp
            start_date = int(start_date.timestamp())
        if end_date:
            end_date = int(end_date.timestamp())  # convert to unix timestamp
        resource_list = getattr(stripe, resource).list(
            limit=100, created={"gte": start_date, "lt": end_date}, **kwargs)
        lst = []
        for i in resource_list.auto_paging_iter():
            lst.extend([i])
        df = pd.DataFrame(lst)
        if len(df) > 0:
            df['created'] = pd.to_datetime(df['created'], unit='s')
        return df

    def contact_name(self, charges_field):
        billing_details = charges_field['data'][0].get('billing_details')
        return billing_details.name

    def contact_email(self, charges_field):
        billing_details = charges_field['data'][0].get('billing_details')
        return billing_details.email

    def generate_donation_report(self, junto_id, take_rate=None):
        # TODO: Use Stripe Authentication here
        df = self.stripe_get_data('PaymentIntent')
        df = df.join(pd.json_normalize(df.metadata).add_prefix(
            'meta_'))  # Flatten metadata fields
        donations = df[(df['meta_type'] == 'one_time_donation')
                       & (df['status'] == 'succeeded')]
        donations['amount_donated'] = donations['amount_received'].div(
            100).round(2)
        donations['name'] = donations.apply(
            lambda row: self.contact_name(row['charges']), axis=1)
        donations['email'] = donations.apply(
            lambda row: self.contact_email(row['charges']), axis=1)
        # Total per Junto
        # TODO: Make this more secure?
        filtered_df = donations[df['meta_juntoId'] == junto_id].filter(
            ['amount_donated', 'created', 'name', 'email'])
        return filtered_df


class Event:
    def __init__(self, event_ref):
        self.event_ref = event_ref
        self.event_id = event_ref.id

    # def num_attended(self, event_doc):
    #     # TODO: Do this, consider using twilioParticipants collection
    #     # where participantIdentity == our User IDs, dedup on participantIdentity
    #     participants = self.event_participants_from_ref(self, event_doc, active_only=True)
    #     return len(participants)

    def participants_collection(self):
        return self.event_ref.collection('discussion-participants')

    def participants(self, active_only=False):
        participant_collection = self.participants_collection()
        if active_only:
            return [p.id for p in participant_collection.stream() if p.to_dict()['status'] == 'active']
        else:
            return [p.id for p in participant_collection.stream()]

    def breakout_session_collection(self):
        return self.event_ref.collection('live-meetings').document(self.event_id).collection('breakout-room-sessions')

    def breakout_room_collection(self, session_idx=0):
        breakout_sessions = self.breakout_session_collection()
        breakout_session_id = breakout_sessions.get()[session_idx].id
        return breakout_sessions.document(breakout_session_id).collection('breakout-rooms')

    def get_breakouts(self):
        # if self.has_breakouts():
        breakout_room_docs = self.breakout_room_collection().get()
        breakout_rooms = sorted(
            [r.to_dict() for r in breakout_room_docs], key=lambda r: r['orderingPriority'])
        return breakout_rooms

    def get_breakout_dicts(self):
        assigned_breakout = {}
        final_breakout = {}
        ORIGINAL_PIDS = 'originalParticipantIdsAssignment'
        ROOM_NAME = 'roomName'
        d = {}
        if self.has_breakouts():
            breakouts = self.get_breakouts()
            for b in breakouts:
                if b[ORIGINAL_PIDS]:
                    for p in b[ORIGINAL_PIDS]:
                        assigned_breakout[p] = b[ROOM_NAME]
                for p in b['participantIds']:
                    final_breakout[p] = b[ROOM_NAME]
        return assigned_breakout, final_breakout

    def get_join_params(self, paramkeys):
        print("PARAMKEYS")
        print(paramkeys)
        participant_collection = self.event_ref.collection(
            'discussion-participants')
        params = defaultdict(list)
        for p in participant_collection.stream():
            params['junto_pid'].append(p.id)
            pdict = p.to_dict()
            joinparams = {}
            if 'joinParameters' in pdict and pdict['joinParameters']:
                joinparams = pdict['joinParameters']
            for k in paramkeys:
                if k in joinparams:
                    params[k].append(joinparams[k])
                else:
                    params[k].append(None)
        return params

    def has_breakouts(self):
        sessions_collection = self.event_ref.collection(
            'live-meetings').document(self.event_ref.id).collection('breakout-room-sessions').limit(1).get()
        return len(sessions_collection) > 0

    def get_suggestions_by_room(self, agenda_item_id, DU):
        def legacy_suggestion_dict(suggestion, roomname):
            suggestion['room'] = roomname
            upvotes = len(suggestion.get('upvotedUserIds', []))
            downvotes = len(suggestion.get('downvotedUserIds', []))
            suggestion['votes'] = upvotes - downvotes
            return suggestion

        def suggestion_dict(suggestion, roomname, creatorId):
            suggestion['room'] = roomname
            suggestion['creatorId'] = creatorId
            upvotes = len(suggestion.get('likedByIds', []))
            downvotes = len(suggestion.get('dislikedByIds', []))
            suggestion['votes'] = upvotes - downvotes
            suggestion['content'] = suggestion['suggestion']
            return suggestion
        results = []
        main_collection = self.suggestion_collection(self.event_ref)
        for c in main_collection.get():
            results.append(legacy_suggestion_dict(c.to_dict(), 'main'))
        if self.has_breakouts():
            breakout_collection = self.breakout_room_collection()
            for b in breakout_collection.get():
                room_name = b.to_dict()['roomName']
                room_doc = breakout_collection.document(
                    b.id).collection('live-meetings').document(b.id)
                roomcollection = self.suggestion_collection(room_doc)
                for c in roomcollection.get():
                    results.append(legacy_suggestion_dict(
                        c.to_dict(), room_name))

        event_ids = self.event_id

        if agenda_item_id:

            event_ids = [self.event_id]
            if self.has_breakouts():
                breakout_collection = self.breakout_room_collection()
                for b in breakout_collection.get():
                    event_ids.append(b.id)

            for id in event_ids:
                participant_details = DU.user_suggestion_details(
                    agenda_item_id, id)
                for response in filter(lambda response: 'suggestions' in response, participant_details):
                    results.extend([suggestion_dict(c, response['meetingId'], response['creatorId'])
                                    for c in response['suggestions']])
        return results

    def maybe_show_wordcloud(self):
        results = []
        if self.has_breakouts():
            breakout_collection = self.breakout_room_collection()
            for b in breakout_collection.get():
                room_name = b.to_dict()['roomName']
                room_doc = breakout_collection.document(
                    b.id).collection('live-meetings').document(b.id)
                roomcollection = self.suggestion_collection(room_doc)
                for c in roomcollection.get():
                    d = c.to_dict()
                    d['room'] = room_name
                    d['votes'] = len(d['upvotedUserIds']) - \
                        len(d['downvotedUserIds'])
                    results.append(d)
        return pd.DataFrame(results, columns=['content', 'createdDate', 'creatorId', 'room', 'votes'])

    def chat_collection(self, room_doc):
        return room_doc.collection('chats').document(
            'junto_chat').collection('messages')

    def suggestion_collection(self, room_doc):
        return room_doc.collection('user-suggestions')

    def get_chats_by_room(self):
        chats = []
        main_collection = self.chat_collection(self.event_ref)
        for c in main_collection.get():
            chat = c.to_dict()
            chat['room'] = 'main'
            chats.append(chat)

        if self.has_breakouts():
            breakout_collection = self.breakout_room_collection()
            for b in breakout_collection.get():
                room_name = b.to_dict()['roomName']
                room_doc = breakout_collection.document(
                    b.id).collection('live-meetings').document(b.id)
                roomcollection = self.chat_collection(room_doc)
                for c in roomcollection.get():
                    chat = c.to_dict()
                    chat['room'] = room_name
                    chats.append(chat)
        return pd.DataFrame(chats, columns=['message', 'createdDate', 'creatorId', 'room'])

    def participant_dict_list(self, questions_list=None):
        participants = []
        event_dict = self.event_ref.get().to_dict()
        topic_id = event_dict['topicId']
        participants_collection = self.participants_collection()
        rooms, final_room_assignments = self.get_breakout_dicts()
        for doc in participants_collection.stream():
            dd = doc.to_dict()
            if 'status' not in dd:
                continue
            p = {}
            p['topic'] = topic_id
            p['event'] = self.event_id
            p['pid'] = doc.id
            p['status'] = dd['status']
            p['referral'] = nestedField(dd, ['joinParameters', 'moa-partner'])
            p['gup'] = nestedField(dd, ['joinParameters', 'gup'])
            p['source'] = nestedField(dd, ['joinParameters', 'source'])
            p['entered_breakouts'] = bool(p['pid'] in rooms) or bool(
                p['pid'] in final_room_assignments)
            p['breakout_room'] = rooms.get(p['pid'], None)
            if questions_list is not None:
                sq = nestedField(dd, ['breakoutRoomSurveyQuestions'])
                if sq:
                    for i, q in enumerate(sq):
                        if i >= len(questions_list):
                            continue
                        question_key = f'q:{questions_list[i]}'
                        p[question_key] = int(
                            q['answerIndex']) if 'answerIndex' in q else self.get_survey_question_answer_index(q)
            participants.append(p)
        return participants

    # Sample Question obj format
    # {
    #   "answers":[
    #      {
    #         "options":[
    #            {
    #               "id":"58628bef-a42e-47d5-8c66-184604eeaf15",
    #               "title":"<10"
    #            }
    #         ],
    #         "id":"b3bdaee4-27b7-4615-8cd7-23481e2a7658"
    #      },
    #      {
    #         "id":"6a7f544b-0bce-4784-9861-ba3bea36926c",
    #         "options":[
    #            {
    #               "title":"10+",
    #               "id":"4bbc94a6-3d7f-48e0-ba26-12b6ee764cab"
    #            }
    #         ]
    #      }
    #   ],
    #   "id":"3966f0d7-476b-4724-bb2e-53729e69b906",
    #   "answerOptionId":"58628bef-a42e-47d5-8c66-184604eeaf15",
    #   "title":"How many magic shows have you been to? "
    # }
    def get_survey_question_answer_index(self, question_obj):
        print(question_obj)

        selected_answer = question_obj['answerOptionId']
        answersOptions = [option for answer in question_obj['answers']
                          for option in answer['options']]
        answerIndex = 0
        for answerOption in answersOptions:
            if (answerOption['id'] == selected_answer):
                return answerIndex
            answerIndex = answerIndex + 1

        return -1


class DataUtil:
    def __init__(self, secrets, use_prod=False):
        self.secrets = secrets
        fb_key = self.secrets['fb_prod_key'] if use_prod else self.secrets['fb_dev_key']
        initialize_firestore(fb_key, use_prod=use_prod)
        self.store = firestore.client()
        self.twilio = None
        self.stripe = None

    def init_twilio(self):
        if not self.twilio:
            self.twilio = Twilio(
                self.secrets["twilio_sid"], self.secrets["twilio_secret"])

    def init_stripe(self, stripe_key):
        if not self.stripe:
            self.stripe = Stripe(stripe_key)

    def get_docs(self, collection, limit=None):
        doc_ref = collection.limit(limit)
        try:
            return doc_ref.get()
        except exceptions.NotFound:
            print(u'Missing data')

    def get_junto_collection(self):
        return self.store.collection('junto')

    def get_juntos(self):
        collection = self.get_junto_collection()
        pd.DataFrame([d.to_dict() for d in collection.stream()])
        juntos = []
        for doc in collection.stream():
            j = doc.to_dict()
            juntos.append([j['id'], j['name'], j['createdDate']])
        return pd.DataFrame(juntos, columns=['juntoId', 'name', 'createdDate'])

    def junto_ref(self, junto):
        return self.get_junto_collection().document(junto)

    def topic_ref(self, junto, topic):
        return self.junto_ref(junto).collection('topics').document(topic)

    def event_ref(self, junto, topic, discussion):
        return self.topic_ref(junto, topic).collection('discussions').document(discussion)

    def list_onboard_links(self):
        collection = self.store.collection('partner-agreements')
        # collection.orderBy("date", descending: true).limit(1) # new entries first, date is one the entries btw
        return pd.DataFrame([d.to_dict() for d in collection.stream()])

    def generate_onboarding_link(self, allow_payments=True, juntoId=None, takeRate=.25, use_prod=False):
        doc = self.store.collection('partner-agreements').document()
        data = {
            'allowPayments': allow_payments,
            'takeRate': takeRate,
            'id': doc.id
        }
        if juntoId:
            data['juntoId'] = juntoId
        doc.set(data)
        if use_prod:
            link = f'https://kazm.com/home/onboard/{doc.id}'
        else:
            link = f'https://juntochat-dev.web.app/home/onboard/{doc.id}'
        return link

    def display_id_to_junto(self, display_id):
        return self.store.collection('junto').where(
            u'displayIds', u'array_contains', display_id
        ).limit(1).get()[0].to_dict()

    def agenda_items_of_type(self, docref, itemtype='wordCloud'):
        agenda_items = docref.get().to_dict()['agendaItems']
        result = []
        for ai in agenda_items:
            if ai['type'] == itemtype:
                result.append(ai['id'])
        return result

    def first_agenda_item_of_type(self, docref, itemtype='wordCloud'):
        items = self.agenda_items_of_type(docref, itemtype='wordCloud')
        return items[0]

    def get_memberships(self):
        '''Return dataframe of user_id, junto, role.'''
        collection = self.store.collection_group('junto-membership')
        members = []
        for doc in collection.stream():
            m = doc.to_dict()
            members.append([m['userId'], m['juntoId'], m['status']])
        return pd.DataFrame(members, columns=['userId', 'juntoId', 'status'])

    def get_publicusers(self, user_ids=None):
        '''Return dict of user_id --> PublicUser.'''
        collection = self.store.collection('publicUser').get()
        if user_ids is None:
            user_id_set = [u.id for u in collection]
        else:
            user_id_set = set(user_ids)
        publicusers = [u for u in collection if u.id in user_id_set]
        batch_size = 100
        result = {}
        uid_identifiers = [auth.UidIdentifier(m) for m in user_id_set]
        for i in range(0, len(uid_identifiers), batch_size):
            # print("%d--> %d" % (i,i+batch_size))
            batch_result = {u.uid: u for u in auth.get_users(
                uid_identifiers[i:i+batch_size]).users}
            result.update(batch_result)

        return result

    def get_publicusers_dict(self, user_ids=None):
        '''Return dict of user_id --> PublicUser.'''
        collection = self.store.collection('publicUser').get()
        if user_ids is None:
            user_id_set = [u.id for u in collection]
        else:
            user_id_set = set(user_ids)
        return {u.id: u for u in collection if u.id in user_id_set}

    def twilio_breakouts_dataframe(self, event):
        # def breakout_dataframe(self):
        breakouts = event.get_breakouts()[1:]
        rooms = pd.DataFrame({'name': [b['roomName'] for b in breakouts],
                              'roomId': [b['roomId'] for b in breakouts]})
        self.init_twilio()
        twilio_rooms = [self.twilio.get_twilio_room(sid)
                        for sid in rooms['roomId']]  # This takes time
        rooms['duration'] = [r.duration/60 for r in twilio_rooms]
        rooms['sid'] = [r.sid for r in twilio_rooms]
        rooms['num_participants'] = [len(set([p.identity for p in r.participants.list()]))
                                     for r in twilio_rooms]
        return rooms

    def get_subscribed_set(self, junto, participants):
        participantset = set(participants)
        subscribed = set()
        for m in self.store.collection_group('junto-membership').stream():
            member = m.to_dict()
            if member['juntoId'] == junto and member['userId'] in participantset:
                subscribed.add(member['userId'])
        return subscribed

    def collection_group(self, collection_id, **kwargs):
        cg = self.store.collection_group(collection_id)
        for k, v in kwargs.items():
            cg = cg.where(k, '==', v)
        return cg

    def event_collection_group(self, junto=None, topic=None, event=None, start_date=None, status=u'active'):
        cg = self.store.collection_group('discussions')
        if junto:
            cg = cg.where(u'juntoId', '==', junto)
        if topic:
            cg = cg.where(u'topicId', '==', topic)
        if event:
            cg = cg.where(u'id', '==', event)
        if status:
            cg = cg.where(u'status', '==', status)
        if start_date:
            cg = cg.where(u'scheduledTime', '>', start_date)
        return cg

    def word_cloud_details(self, agenda_item_id, meeting_id=None):
        # breakout-room-sessions/<sessionId>/breakout-rooms/<breakoutRoomId>/live-meetings/<breakoutRoomId>/
        # participant-agenda-item-details/{agendaItemId}/participant-details/{userId}
        cg = self.store.collection_group(
            'participant-details').where('agendaItemId', '==', agenda_item_id)
        if meeting_id:
            cg = cg.where(u'meetingId', '==', meeting_id)
        # Look here: /junto/meetingofamerica/topics/mjfIEQbtNrqtqWHyvzgL/discussions/cZ4bzX2uXtLnxJQRyYMR/live-meetings/cZ4bzX2uXtLnxJQRyYMR/breakout-room-sessions/cZ4bzX2uXtLnxJQRyYMR/breakout-rooms/7IzVGNzpc3b0owoyb3wW/live-meetings/7IzVGNzpc3b0owoyb3wW/participant-agenda-item-details/1632838049136/participant-details/7FkA59qKHhdxraLQRqfAJsJ7M9F3
        results = []
        words = defaultdict(list)
        for doc in cg.stream():
            d = doc.to_dict()
            # keys = ['userId', 'agendaItemId', 'meetingId']  # other details
            if 'wordCloudResponses' in d:
                for w in d['wordCloudResponses']:
                    words[w.lower().strip()].append(d['userId'])
        return words

    def user_suggestion_details(self, agenda_item_id, meeting_id=None):
        # breakout-room-sessions/<sessionId>/breakout-rooms/<breakoutRoomId>/live-meetings/<breakoutRoomId>/
        # participant-agenda-item-details/{agendaItemId}/participant-details/{userId}
        cg = self.store.collection_group(
            'participant-details').where('agendaItemId', '==', agenda_item_id)
        if meeting_id:
            cg = cg.where(u'meetingId', '==', meeting_id)
        # Look here: /junto/meetingofamerica/topics/mjfIEQbtNrqtqWHyvzgL/discussions/cZ4bzX2uXtLnxJQRyYMR/live-meetings/cZ4bzX2uXtLnxJQRyYMR/breakout-room-sessions/cZ4bzX2uXtLnxJQRyYMR/breakout-rooms/7IzVGNzpc3b0owoyb3wW/live-meetings/7IzVGNzpc3b0owoyb3wW/participant-agenda-item-details/1632838049136/participant-details/7FkA59qKHhdxraLQRqfAJsJ7M9F3
        results = []
        for doc in cg.stream():
            d = doc.to_dict()
            d['creatorId'] = doc.id
            results.append(d)
        return results

    def add_publicuser_cols(self, df, id_col, remove_superadmin=True):
        publicusers = self.get_publicusers(df[id_col])
        publicusersdict = self.get_publicusers_dict(df[id_col])
        df['name'] = df[id_col].map(
            lambda x: publicusers[x].display_name if x in publicusers and publicusers[x].display_name != None else publicusersdict[x].to_dict()['displayName'])
        df['email'] = df[id_col].map(
            lambda x: publicusers[x].email if x in publicusers else None)
        if remove_superadmin:
            df = df[~df['email'].isin(SUPERADMIN)]
        return df

    def junto_events_list(self, junto):
        events = []
        for e in self.store.collection_group('discussions').where(u'juntoId', '==', junto).stream():
            events.append(e.to_dict())
        df = pd.DataFrame({
            k: [e[k] if k in e else None for e in events] for k in ['id', 'topicId', 'title', 'creatorId', 'isPublic',
                                                                    'participantCountEstimate', 'scheduledTime']})
        df['scheduledTime'] = df['scheduledTime'].astype('datetime64[ns]')
        df = self.add_publicuser_cols(df, 'creatorId')
        return df

    def events_per_junto(self):
        COLLECTION_GROUP_PATHS = ['live-meetings',
                                  'breakout-room-live-meeting', 'instant-live-meeting']
        meetings = []
        for cg in COLLECTION_GROUP_PATHS:
            for m in self.store.collection_group(cg).stream():
                md = m.to_dict()
                md['meetingId'] = m.id
                md['juntoId'] = m.reference.path.split('/')[1]
                md['pcount'] = len(Event(m.reference).participants())
                meetings.append(md)
        return meetings

    def upcoming_events(self, junto=None):
        return self.query_events(junto=junto, start_date=datetime.now())

    def query_events(self, junto=None, topic=None, event=None, start_date=None, status=u'active'):
        cg = self.event_collection_group(
            junto=junto, topic=topic, event=event, start_date=start_date, status=status)
        events = []
        for e in cg.stream():
            ed = e.to_dict()
            ed['discussionId'] = e.id
            ed['juntoId'] = e.reference.path.split('/')[1]
            ed['pcount'] = self.num_active_rsvps(e)
            events.append(ed)
        keys = ['scheduledTime', 'title', 'isPublic', 'pcount',
                'juntoId', 'discussionId', 'topicId', 'creatorId']
        df = pd.DataFrame({
            k: [e[k] if k in e else None for e in events] for k in keys})
        df['scheduledTime'] = df['scheduledTime'].astype('datetime64[ns]')
        df = self.add_publicuser_cols(df, 'creatorId')
        return df

    def num_active_rsvps(self, event_doc):  # TODO: Move to Event
        ed = event_doc.to_dict()
        count_key = 'participantCountEstimate'
        if count_key in ed and ed[count_key] and ed[count_key] > 0:
            return ed[count_key]
        else:
            return len(Event(event_doc.reference).participants(active_only=True))

    def stripe_report(self, junto, stripe_key):
        self.init_stripe(stripe_key)
        return self.stripe.generate_donation_report(junto)

    def query_participants(self, junto=None, topic=None, event=None):  # TODO: Move to Event
        cg = self.store.collection_group('discussion-participants')
        if junto:
            cg = cg.where(u'juntoId', '==', junto)
        if topic:
            cg = cg.where(u'topicId', '==', topic)
        collection = cg.get()
        keys = ['juntoId', 'topicId']
        df = pd.DataFrame(
            {k: [p[k] if k in p else None for p in collection] for k in keys})
        df['pid'] = [p.id for p in collection]
        return df

    # TODO: Remove or unify dataframe generation
    # def event_dataframe(self, event, extraparams=None):
    #     if extraparams is None:
    #         extraparams = []  # ie ['participant_id','match_id', 'am']
    #     event_ref = self.event_ref()
    #     event = Event(event_ref)
    #     params = event.get_join_params(extraparams)
    #     subscribed = self.get_subscribed_set(junto, params['junto_pid'])
    #     df = pd.DataFrame(params)
    #     df = self.add_publicuser_cols(df, 'junto_pid')
    #     df['subscribed'] = df['junto_pid'].isin(subscribed)
    #     df['domain'] = df['email'].map(lambda x: x.split('@')[1] if x else '')
    #     if event.has_breakouts():
    #         assigned_breakout, final_breakout = event.get_breakout_dicts()
    #         df['assigned_breakout'] = df['junto_pid'].map(assigned_breakout)
    #         df['final_breakout'] = df['junto_pid'].map(final_breakout)
    #     return df


class JuntoDataUtil:
    """
    This is a helper class for the sole purpose of enforcing that the juntodash only access data for a single junto.
    """

    def __init__(self, display_id, secrets, use_prod=False):
        self.display_id = display_id
        self.secrets = secrets
        self.DU = DataUtil(secrets=self.secrets, use_prod=use_prod)
        self.junto = self.DU.display_id_to_junto(self.display_id)
        self.junto_id = self.junto['id']

    def query_events(self, topic=None, event=None, start_date=None, status=u'active'):
        df = self.DU.query_events(
            junto=self.junto_id, topic=topic, event=event, start_date=start_date, status=status)
        return df

    def query_participants(self, topic=None, event=None):
        df = self.DU.query_participants(
            junto=self.junto_id, topic=topic, event=event)
        return df

    def event_ref(self, topic, discussion):
        return self.DU.event_ref(self.junto_id, topic, discussion)

    def twilio_breakouts_dataframe(self, event):
        return self.DU.twilio_breakouts_dataframe(event)

    def stripe_report(self):
        return self.DU.stripe_report(self.junto_id, self.secrets["stripe_key"])

    def get_events(self, topic_id, event_id):
        events = []
        cg = self.DU.event_collection_group(
            junto=self.junto_id, topic=topic_id, event=event_id)
        for event_doc in cg.stream():
            events.append(Event(event_doc.reference))
        return events

    def add_publicuser_cols(self, df, id_col, remove_superadmin=True):
        # TODO: Securty - ensure only for correct junto
        return self.DU.add_publicuser_cols(df, id_col, remove_superadmin=remove_superadmin)
