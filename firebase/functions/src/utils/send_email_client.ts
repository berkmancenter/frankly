import { firestore, firestoreUtils } from '../utils/infra/firestore_utils';
import { SendGridEmail } from '../types';

export class SendEmailClient {
  async sendEmail(email: SendGridEmail, opts?: { transaction?: FirebaseFirestore.Transaction }): Promise<void> {
    const newDocument = firestore.collection('sendgridmail').doc();
    const newData = firestoreUtils.toFirestoreJson(serializeSendGridEmail(email));

    if (opts?.transaction) {
      opts.transaction.set(newDocument, newData);
    } else {
      await newDocument.set(newData);
    }
  }

  async sendEmails(emails: SendGridEmail[]): Promise<void> {
    // Split into batches of 500
    const chunks: SendGridEmail[][] = [];
    for (let i = 0; i < emails.length; i += 500) {
      chunks.push(emails.slice(i, i + 500));
    }

    await Promise.all(
      chunks.map((sublist) => {
        const batch = firestore.batch();
        for (const email of sublist) {
          const doc = firestore.collection('sendgridmail').doc();
          batch.set(doc, firestoreUtils.toFirestoreJson(serializeSendGridEmail(email)));
        }
        return batch.commit();
      })
    );
  }
}

function serializeSendGridEmail(email: SendGridEmail): Record<string, unknown> {
  return {
    to: email.to,
    from: email.from,
    message: {
      subject: email.message.subject,
      html: email.message.html,
      attachments: email.message.attachments,
    },
  };
}

export function setSendEmailClient(instance: SendEmailClient): void {
  sendEmailClient = instance;
}

export let sendEmailClient = new SendEmailClient();
