"""
Reference: 
https://firebase.google.com/docs/reference/admin/python/firebase_admin.auth#list_users
"""
import firebase_admin
from firebase_admin import auth
import google.cloud
from google.cloud import storage
import re
import math
import string
import pprint
import os.path
from firebase_admin import credentials, firestore

FIREBASE_PROD_ID = "juntochat"
FIREBASE_DEV_ID = "juntochat-dev"

# Key for juntochat@appspot.gserviceaccount.com (Cloud / Service Accounts)
cred = credentials.Certificate("../creds/ServiceAccountKey.json")
app = firebase_admin.initialize_app(cred)
store = firestore.client()


class PublicUserInfo:
    def __init__(self, uid, display_name, photo_url):
        assert uid.strip() != ""
        self.uid = uid
        self.display_name = display_name if display_name else 'Anonymous'
        self.photo_url = photo_url if photo_url else 'https://picsum.photos/seed/%s/80.webp' % uid

    @classmethod
    def from_auth_record(cls, u):
        return cls(u.uid, u.display_name, u.photo_url)

    def asdict(self):
        d = {'displayName': self.display_name,
             'id': self.uid,
             'imageUrl': self.photo_url}
        return d


def batch_data(iterable, n=1):
    l = len(iterable)
    for ndx in range(0, l, n):
        yield iterable[ndx:min(ndx + n, l)]

def batch_upload_public_users(public_users):
    for batched_data in batch_data(public_users, 499):
        batch = store.batch()
        for public_user in batched_data:
            topic_collection = store.collection('publicUser')
            doc_ref = topic_collection.document(str(public_user.uid))
            batch.create(doc_ref, public_user.asdict())
        batch.commit()

def main():
    # Read users from auth
    auth_users = firebase_admin.auth.list_users(
        page_token=None, max_results=1000, app=None)

    # Create PublicUserInfo for users with an email address
    public_users = [PublicUserInfo.from_auth_record(
        u) for u in auth_users.iterate_all() if u.email]

    # Load to Firestore
    batch_upload_public_users(public_users)

if __name__ == "__main__":
    """ This is executed when run from the command line """
    main()
