import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/partner_agreement.dart';

class FirestoreAgreementsService {
  static const String agreements = 'partner-agreements';

  DocumentReference _agreementsReference({required String agreementId}) =>
      firestoreDatabase.firestore.doc('$agreements/$agreementId');

  /// Only works for user who initiated onboarding or for administrators of the space (if one has
  /// been created), by way of Firestore permissions
  BehaviorSubjectWrapper<PartnerAgreement?> getAgreementStream(String agreementId) {
    final docRef = _agreementsReference(agreementId: agreementId);
    return wrapInBehaviorSubject(
        docRef.snapshots().asyncMap((snapshot) => _convertAgreement(snapshot.data())));
  }

  /// Only works for administrators of the space, by way of Firestore permissions
  Stream<PartnerAgreement?> getAgreementForJuntoStream(String juntoId) {
    final docRef =
        firestoreDatabase.firestore.collection(agreements).where('juntoId', isEqualTo: juntoId);
    return docRef.snapshots().asyncMap(
        (snapshot) => snapshot.size > 0 ? _convertAgreement(snapshot.docs[0].data()) : null);
  }

  static PartnerAgreement? _convertAgreement(Object? data) {
    if (data == null) return null;

    return PartnerAgreement.fromJson(fromFirestoreJson(data as Map<String, dynamic>));
  }
}
