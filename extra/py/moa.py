from threading import active_count
from numpy.lib.function_base import median
import streamlit as st
import numpy as np
import pandas as pd
import utils

USE_PROD = True
DU = None
JUNTO = 'meetingofamerica'
QUESTIONS = ['Race', 'Gender', 'Age', 'Geography',
             'Ideology', 'Party']


def query_participant_data(events):
    participants = []
    for event in events:
        participants.extend(event.participant_dict_list(questions_list=QUESTIONS))
    df = pd.DataFrame(participants)
    df = DU.DU.add_publicuser_cols(df, 'pid')
    return df


def rsvps(topic_id=None, event_id=None):
    events = DU.get_events(topic_id, event_id)
    df = query_participant_data(events)
    if df.empty:
        return st.error('No data.')
    active_rsvps = df.status.value_counts()['active']
    st.subheader(f'{active_rsvps} Active RSVPs')
    st.write(df)
    st.markdown(utils.get_table_download_link(
        df), unsafe_allow_html=True)

    st.subheader(f'Question Responses (%s)')
    qs = df[[c for c in df if c.startswith('q:')]]
    st.write((100*qs.apply(pd.Series.value_counts, normalize=True)))

    st.subheader(f'RSVPs per Partner')
    st.bar_chart(df['referral'].value_counts().sort_values())
    if len(events) == 1:  # Event-level report
        event = events[0]
        show_breakouts(event)
        show_chats(event)
    else:  # Topic-level report
        show_suggestions(events)
        show_wordcloud(topic_id)


def show_breakouts(event):
    if not event.has_breakouts():
        return
    st.subheader(f'Breakouts')
    rooms = DU.twilio_breakouts_dataframe(event)
    st.subheader(
        f"{len(rooms)} rooms, {rooms['num_participants'].median()} median participants, {rooms['duration'].median():.1f} median duration.")
    st.write(rooms.round(2))
    st.markdown(utils.get_table_download_link(
        rooms.round(2), index=False, columns='name duration num_participants'.split()), unsafe_allow_html=True)


def show_chats(event):
    st.subheader(f'Chats')
    df = event.get_chats_by_room()
    st.write(df)
    st.markdown(utils.get_table_download_link(df), unsafe_allow_html=True)


def show_suggestions(events):
    st.subheader(f'Suggestions')
    results = []

    agenda_item_id = DU.DU.first_agenda_item_of_type(
        DU.DU.topic_ref(JUNTO, topic_id), 'userSuggestions')
    for event in events:
        results.extend(event.get_suggestions_by_room(agenda_item_id, DU.DU))
    df = pd.DataFrame(results, columns=['content', 'votes', 'createdDate', 'creatorId', 'room'])
    st.write(df.sort_values(['votes'], ascending=False))
    st.markdown(utils.get_table_download_link(df), unsafe_allow_html=True)


def show_wordcloud(topic_id):
    agenda_items = DU.DU.agenda_items_of_type(
        DU.DU.topic_ref(JUNTO, topic_id), itemtype='wordCloud')
    if not agenda_items:
        st.write("No wordcloud in this topic's agenda.")
        return
    st.subheader(f'WordCloud')
    for agenda_item_id in agenda_items:
        st.code(f'Agenda Item ID: {agenda_item_id}')
        words_to_uids = DU.DU.word_cloud_details(agenda_item_id)
        words_to_count = {k: len(v) for k, v in words_to_uids.items()}
        df = pd.DataFrame(words_to_count.items(), columns=[
            'word', 'count']).sort_values('count', ascending=False)
        st.write(df)
        st.markdown(utils.get_table_download_link(
            df.round(2), index=False, columns='word count'.split()), unsafe_allow_html=True)


if __name__ == '__main__':
    # TODO: Replace st.secrets with client authentication
    DU = utils.JuntoDataUtil(JUNTO, secrets=st.secrets, use_prod=USE_PROD)
    topic_id = st.sidebar.text_input('topic_id', 'mjfIEQbtNrqtqWHyvzgL')
    event_id = st.sidebar.text_input('event_id', '431UiAzdywmrldjFk5gj')
    event_id_url = st.sidebar.text_input('OR paste an event URL', '')
    if event_id_url:
        _, topic_id, event_id = utils.get_params_from_urls(
            event_id_url, USE_PROD)
    if st.sidebar.button('Generate'):
        rsvps(topic_id, event_id)
