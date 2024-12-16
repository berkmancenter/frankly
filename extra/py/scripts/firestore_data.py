"""
Reference: firebase.google.com/docs/firestore/manage-data/add-data#python

To set up gcloud quota (PROJECT_ID=juntochat):
gcloud init
gcloud auth application-default set-quota-project $PROJECT_ID
"""
from argparse import ArgumentParser
import firebase_admin
import google.cloud
from gsheets import Sheets
from google.cloud import storage
import html2text
import re
import enum
import math
import string
from string import Template
import pprint
import os.path
from firebase_admin import credentials, firestore


PROD_CRED = credentials.Certificate("../creds/ServiceAccountKey_prod.json")
DEV_CRED = credentials.Certificate("../creds/ServiceAccountKey_dev.json")
# FIREBASE_PROD_ID = "juntochat"
# FIREBASE_DEV_ID = "juntochat-dev"

# Sheets API
sheets = Sheets.from_files()

# From LRC Topics Export Spreadsheet
TOPIC_SHEET_ID = '1OmPPtZ4UdGQHfBJqyVdqcJARUiMxIBOdb-mm896fb10'  # Junto Spreadsheet
TOPIC_SHEET_TITLE = 'Topics'

# Consts
NONALPHANUM = re.compile(r'[\W_]+')
SEP = '_'
BUCKET = 'juntochat.appspot.com'

# HTML Converter
HTML2TXT = html2text.HTML2Text()
HTML2TXT.ignore_links = True
HTML2TXT.body_width = 0

TEST_JUNTO_ID_MAP = {
    '53FXvTKVnJlUPInVgDzd': 'living-room-convos-dev'
}


class AgendaItem:
    def __init__(self, item_id, title, content):
        self.id = str(item_id)
        self.title = title
        self.content = content.replace('\\n', '\n').replace(' *', '\n*')

    def asdict(self):
        d = {'id': self.id,
             'title': self.title,
             'content': self.content}
        return d


class Topic:
    def __init__(self, junto_id, title, url, image, creator_id, creator_display_name, docid, category, agenda_items):
        assert title.strip() != ""
        assert url.strip() != ""
        self.junto_id = junto_id
        self.creator_id = creator_id
        self.creator_display_name = creator_display_name
        self.docid = self.parse_docid(docid)
        self.title = title
        self.url = url
        self.image = image
        self.category = category
        self.agenda_items = agenda_items

    def parse_docid(self, docid):
        """Avoid reading ints as floats due to Sheets."""
        if type(docid) == float:
            if math.isnan(docid):
                return None
            assert docid.is_integer()
            docid = int(docid)
        docid = str(docid).strip()
        if docid:  # Check if empty
            return docid

    @property
    def reading_id(self):
        return create_id(os.path.splitext(self.filename)[0])

    def asdict(self):
        d = {'title': self.title,
             'url': self.url,
             'image': self.image,
             'creatorId': self.creator_id,
             'creatorDisplayName': self.creator_display_name,
             'category': self.category,
             'agendaItems': self.agenda_items}
        return d


class LrcGuide():
    INTRODUCTIONS = '''
_Each participant has 1 minute to introduce themselves._

Share your name, where you live, what drew you here, and if this is your first conversation.'''
    CONVERSATION_AGREEMENTS = '''
_These will set the tone of our conversation; participants may volunteer to take turns reading them aloud._
-   Be curious and listen to understand.
-   Show respect and suspend judgment.
-   Note any common ground as well as any differences.
-   Be authentic and welcome that from others.
-   Be purposeful and to the point.
-   Own and guide the conversation.
'''
    GETTING_TO_KNOW_EACH_OTHER = '''
_Each participant can take 1-2 minutes to answer one of the following:_
-   What are your hopes and concerns for your family, community and/or the country?
-   What would your best friend say about who you are?
-   What sense of purpose / mission / duty guides you in your life?
 '''
    EXPLORING_THE_TOPIC = Template('''
_One volunteer can read this paragraph:_
$intro
_Take ~2 minutes each to answer a question below without interruption or crosstalk. After, the group may take a few minutes for clarifying or follow up questions/responses. Continue exploring additional questions as time allows._
$questions
''')
    EXPLORING_THE_TOPIC_NO_INTRO = Template('''
_Take ~2 minutes each to answer a question below without interruption or crosstalk. After, the group may take a few minutes for clarifying or follow up questions/responses. Continue exploring additional questions as time allows._
$questions
''')
    REFLECTING_ON_CONVERSATION = '''
_Take 2 minutes to answer one of the following:_
-   What was most meaningful / valuable to you in this Living Room Conversation?
-   What learning, new understanding or common ground was found on the topic?
-   How has this conversation changed your perception of anyone in this group?
-   Is there a next step you would like to take based upon the conversation?'''

    def __init__(self, topic_intro, topic_questions):
        assert topic_questions.strip() != ""
        self.topic_questions = topic_questions
        self.topic_intro = None
        if non_empty_string(topic_intro):
            self.topic_intro = topic_intro

    def agenda_items(self):
        if self.topic_intro:
            topic_round = self.EXPLORING_THE_TOPIC.substitute(
                intro=self.topic_intro, questions=self.topic_questions)
        else:  # In case there is no topic intro
            topic_round = self.EXPLORING_THE_TOPIC_NO_INTRO.substitute(
                questions=self.topic_questions)
        return [
            AgendaItem(0, 'Introductions', self.INTRODUCTIONS).asdict(),
            AgendaItem(1, 'Conversation Agreements',
                       self.CONVERSATION_AGREEMENTS).asdict(),
            AgendaItem(2, 'Getting to Know Each Other',
                       self.GETTING_TO_KNOW_EACH_OTHER).asdict(),
            AgendaItem(3, 'Exploring the Topic', topic_round).asdict(),
            AgendaItem(4, 'Reflecting on the Conversation',
                       self.REFLECTING_ON_CONVERSATION).asdict(),
        ]


def initialize_firestore(use_prod=False):
    if use_prod:
        app = firebase_admin.initialize_app(PROD_CRED)
    else:
        app = firebase_admin.initialize_app(DEV_CRED)
    return firestore.client()


def create_id(*input_strings):
    s = SEP.join(input_strings)
    return NONALPHANUM.sub(SEP, s).strip(SEP).lower()


def non_empty_string(x):
    """Returns true if non-empty string."""
    if type(x) == str and x.strip() != "":
        return True
    return False


def upload_storage_content(localpath, bucketpath, firebase_project_id):
    """Upload document to Cloud Storage."""
    assert localpath.strip() != ""
    client = storage.Client(project=firebase_project_id)
    bucket = client.get_bucket(BUCKET)
    blob = bucket.blob(bucketpath)
    blob.upload_from_filename(filename=localpath)


def get_sheet(sheet_id, worksheet_title):
    data = sheets[sheet_id].find(worksheet_title).to_frame().astype(str)
    return data


def get_docs(collection, limit=None):
    doc_ref = collection.limit(limit)
    try:
        return doc_ref.get()
    except google.cloud.exceptions.NotFound:
        print(u'Missing data')


def lrcStructure(row):
    structure = LrcGuide(HTML2TXT.handle(row.topic_intro.strip()),
                         HTML2TXT.handle(row.topic_round2_copy.strip()))
    return structure.agenda_items()


def add_docs(store, collection_id, doc_id, doc):
    store.collection(collection_id).document(doc_id).set(doc)


def batch_data(iterable, n=1):
    l = len(iterable)
    for ndx in range(0, l, n):
        yield iterable[ndx:min(ndx + n, l)]


def batch_upload_docs(store, data, collection_id):
    for batched_data in batch_data(data, 499):
        batch = store.batch()
        for doc in batched_data:
            doc_ref = store.collection(collection_id).document(doc["id"])
            batch.set(doc_ref, doc)
        batch.commit()


def batch_upload_junto_topics(store, topics):
    for batched_data in batch_data(topics, 499):
        batch = store.batch()
        for doc in batched_data:
            topic_collection = store.collection('junto').document(
                doc.junto_id).collection("topics")
            if doc.docid:
                doc_ref = topic_collection.document(str(doc.docid))
            else:  # Auto-generate new id
                doc_ref = topic_collection.document()
            batch.set(doc_ref, doc.asdict())
        batch.commit()


def get_print_topics(store, collection_id, limit=None):
    collection = store.collection('junto').document(
        collection_id).collection("topics")
    topics = get_docs(collection)
    for doc in topics:
        pprint.pprint(doc.to_dict(), compact=True)


def main(args):
    """ Main entry point of the app """
    # Set this
    if args.use_prod:
        print("Updating PROD")

    store = initialize_firestore(use_prod=args.use_prod)

    # Get content data from sheets
    topic_rows = get_sheet(TOPIC_SHEET_ID, TOPIC_SHEET_TITLE)
    topics = [Topic(r.JuntoId, r.Title, r.Permalink, r.Image,
                    r.CreatorId, r.CreatorDisplayName, r.DocId, r.Category, lrcStructure(r))
              for r in topic_rows.itertuples()]

    if not args.use_prod:
        # Converts to dev ids if these are different
        for topic in topics:
            if topic.junto_id in TEST_JUNTO_ID_MAP:
                topic.junto_id = TEST_JUNTO_ID_MAP[topic.junto_id]

    # Drop in specific collection
    batch_upload_junto_topics(store, topics)

    # # Print from specific junto
    # junto_id = 'living-room-convos-dev'
    # get_print_topics(store, junto_id)


if __name__ == "__main__":
    """ This is executed when run from the command line """
    parser = ArgumentParser()
    parser.add_argument('--use_prod', action='store_true',
                        default=False, help='Whether to use Prod.')
    args = parser.parse_args()
    main(args)
