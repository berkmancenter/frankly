import streamlit as st
import numpy as np
import pandas as pd
import utils

# Members: # convos attended, # hosted, list convos, attendance rate,
USE_PROD = True  # Hot reload will not work if switch projects
DU = None

def all_events(start_date='2021-03-01'):
    df = DU.query_events()
    if start_date:
        df = df[(df['scheduledTime'] > start_date)]
    df = df.sort_values('scheduledTime').reset_index(drop=True)
    st.write(df.round(1))
    st.markdown(utils.get_table_download_link(df.round(1)), unsafe_allow_html=True)


def query_participant_data(events):
    participants = []
    for event in events:
        participants.extend(event.participant_dict_list())
    df = pd.DataFrame(participants)
    df = DU.add_publicuser_cols(df, 'pid')
    return df

def show_breakouts(event):
    if not event.has_breakouts():
        return
    st.subheader(f'Breakouts')
    rooms = DU.twilio_breakouts_dataframe(event)
    st.subheader(f"{len(rooms)} rooms, {rooms['num_participants'].median()} median participants, {rooms['duration'].median():.1f} median duration.")
    st.write(rooms.round(2))
    st.markdown(utils.get_table_download_link(
        rooms.round(2), index=False, columns='name duration num_participants'.split()), unsafe_allow_html=True)

def event_details():
    with st.form("Event Report"):
        st.subheader('Paste the event URL')
        url = st.text_input(
            'Event URL', 'https://kazm.com/home/junto/allsides-talks/discuss/kGZFGLnLL9AsGSdPAnWX/N3dPFNV5HUmpPMYsNOcp')
        submitted = st.form_submit_button("Submit")
    if submitted:
        _, topic_id, event_id = utils.get_params_from_urls(url, USE_PROD)
        events = DU.get_events(topic_id, event_id)
        df = query_participant_data(events)
        if df.empty:
            return st.error('No data.')
        active_rsvps = df.status.value_counts()['active']
        st.subheader(f'{active_rsvps} Active RSVPs')
        st.write(df)
        st.markdown(utils.get_table_download_link(
            df), unsafe_allow_html=True)
        if len(events) == 1:  # Rooms Report
            show_breakouts(events[0])


def donations_report(take_rate=None):
    with st.form("Donation Report"):
        submitted = st.form_submit_button("Generate Report")
        if submitted:
            donations = DU.stripe_report()
            total_donations = donations['amount_donated'].sum()
            s = [f'Total Donations: {total_donations}']
            if take_rate:
                s.append(f'Total Payout: {total_donations * (1-take_rate)}')
            st.write('\n'.join(s))
            st.write(donations.round(2))
            st.markdown(utils.get_table_download_link(
                donations.round(2), index=False), unsafe_allow_html=True)


if __name__ == '__main__':
    junto = st.sidebar.text_input('JuntoId', 'allsides-talks')
    # TODO: Replace st.secrets with client authentication
    DU = utils.JuntoDataUtil(junto, secrets=st.secrets, use_prod=USE_PROD)
    app_functions = {
        'Event Details': event_details,
        'All Events': all_events,
        'Donations Report': donations_report,
    }
    selected_fn = st.sidebar.selectbox(
        'Choose a report:',
        app_functions.keys())
    app_functions[selected_fn]()
