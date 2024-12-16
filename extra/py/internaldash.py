import streamlit as st
import numpy as np
import pandas as pd
import utils


USE_PROD = True
FAKE_SUGGESTIONS = {
    'Have candidates discuss UBI': 5,
    'Debate war on drugs policy': 17,
    'Allow candidates to demonstrate understanding of business': 11,
    'Require clear statements on environmental protection policies': 4,
}


def all_roles():
    if st.button('Generate'):
        df = DU.get_memberships()
        df = DU.add_publicuser_cols(df, 'userId')
        st.write(df)
        st.markdown(utils.get_table_download_link(
            df, index=False), unsafe_allow_html=True)


def all_users_with_emails():
    # Using discussions
    if st.button('Generate'):
        publicusers = DU.get_publicusers()
        for k in list(publicusers.keys()):
            if not publicusers[k].email:
                del publicusers[k]
            elif publicusers[k].email.startswith('email.loadero'):
                del publicusers[k]
        df = pd.DataFrame({
            'name': [v.display_name for _, v in publicusers.items()],
            'email': [v.email for _, v in publicusers.items()]
        })
        st.write(df)
        st.markdown(utils.get_table_download_link(
            df, index=False), unsafe_allow_html=True)


def all_juntos():
    if st.button('Generate'):
        df = DU.get_juntos()
        st.write(df.sort_values('createdDate'))
        st.markdown(utils.get_table_download_link(
            df, index=False), unsafe_allow_html=True)


def upcoming_events():
    if st.button('Generate'):
        df = DU.upcoming_events()
        st.write(f'{len(df)} Upcoming Events')
        st.write(df.sort_values('scheduledTime'))
        st.markdown(utils.get_table_download_link(
            df, index=False), unsafe_allow_html=True)
        st.write(df['pcount'].value_counts())


# def events_per_junto():
# TODO: Revive this
#     # Using discussions
#     # TODO: Replace junto-id with display-ids
#     if st.button('Generate'):
#         df = pd.DataFrame(DU.events_per_junto())
#         filtered = df[df['juntoId'] != 'america-talks'][df['pcount'] > 1].groupby(
#             'juntoId').size().sort_values(ascending=False)
#         st.write(filtered)
#         st.bar_chart(filtered)


def suggestions():
    # suggestion_collection = get_suggestions(junto, topic, discussion)
    # suggestions = [s.to_dict()['content'] for s in suggestion_collection]
    data_items = suggestions.items()
    data_list = list(data_items)
    sdf = pd.DataFrame(data_list, columns=['Suggestions', 'Votes'])
    st.write('User suggestions and upvotes:')
    st.write(pd.DataFrame(sdf).sort_values('Votes', ascending=False))


def generate_onboard_link():
    allow_payments = st.checkbox('Link Stripe during onboarding?', value=True)
    juntoId = st.text_input('juntoId (optional)')
    takeRate = st.number_input(
        'Platform fee %', min_value=0, max_value=100) / 100.
    if st.button('Generate'):
        if 0 < takeRate < 1:
            st.write(DU.generate_onboarding_link(
                allow_payments, juntoId, takeRate, use_prod=USE_PROD))
        else:
            st.error('Invalid parameters')
    if st.button('List recent links'):
        show_recent_onboard_links()


def show_recent_onboard_links():
    st.write(DU.list_onboard_links())


if __name__ == '__main__':
    fb_key = st.secrets['fb_prod_key'] if USE_PROD else st.secrets['fb_dev_key']
    DU = utils.DataUtil(secrets=st.secrets, use_prod=USE_PROD)
    st.sidebar.title('Internal Junto Dashboard')
    st.sidebar.write(f'Project: {DU.store.project}')
    # Select App
    app_functions = {
        'Onboard Links': generate_onboard_link,
        'Upcoming Events': upcoming_events,
        # 'Events per Junto': events_per_junto,
        'All Users': all_users_with_emails,
        'All Roles': all_roles,
        'All Juntos': all_juntos,
        # Junto: Monthly conversations per month per Junto (toggle users, ratings, hours)
        # Testing: Breakouts, Chat
        # 'User Map': user_map,
        # 'Suggestions': suggestions, # TODO
    }

    selected_fn = st.sidebar.selectbox(
        'Which app?', app_functions.keys())
    app_functions[selected_fn]()
