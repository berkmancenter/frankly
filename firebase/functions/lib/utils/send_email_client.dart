import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'infra/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:quiver/iterables.dart';

SendEmailClient sendEmailClient = SendEmailClient();

class SendEmailClient {
  Future<void> sendEmail(
    SendGridEmail email, {
    Transaction? transaction,
  }) async {
    final newDocument = firestore.collection('sendgridmail').document();

    final newData =
        DocumentData.fromMap(firestoreUtils.toFirestoreJson(email.toJson()));
    if (transaction != null) {
      transaction.create(newDocument, newData);
    } else {
      await newDocument.setData(newData);
    }
  }

  Future<void> sendEmails(List<SendGridEmail> emails) async {
    await Future.wait(
      partition(emails, 500).map((sublist) {
        final batch = firestore.batch();
        sublist.map((email) {
          final doc = firestore.collection('sendgridmail').document();
          batch.setData(
            doc,
            DocumentData.fromMap(
              firestoreUtils.toFirestoreJson(email.toJson()),
            ),
          );
        }).toList();
        return batch.commit();
      }).toList(),
    );
  }
}
