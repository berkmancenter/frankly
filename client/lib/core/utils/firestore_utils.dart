import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:client/services.dart';
import 'package:data_models/utils/firestore_utils.dart';
import 'package:rxdart/rxdart.dart';

/// Wrap streams in a data type that keeps track of the last value that arrived
/// on the stream. This is useful in many different ways when dealing with
/// streams inside a widget.
///
/// These BehaviorSubject should be disposed when a widget is done with them
/// but more work is needed to figure out how to do that properly. Possibly a
/// memory leak as they currently stand but I haven't seen any issues from it.
BehaviorSubjectWrapper<T> wrapInBehaviorSubject<T>(Stream<T> stream) {
  return BehaviorSubjectWrapper(stream);
}

// Note: We could consider only listening to the stream when this is listened
// to rather than as soon as it is constructed.
class BehaviorSubjectWrapper<T> extends Stream<T> {
  final BehaviorSubject<T> stream;
  final StreamSubscription streamSubscription;

  factory BehaviorSubjectWrapper(Stream<T> stream) {
    final behaviorSubject = BehaviorSubject<T>();
    final subscription = stream.listen(
      (event) => behaviorSubject.add(event),
      onError: (error) => behaviorSubject.addError(error),
      onDone: () => behaviorSubject.close(),
    );
    return BehaviorSubjectWrapper._(
      stream: behaviorSubject,
      streamSubscription: subscription,
    );
  }

  BehaviorSubjectWrapper._({
    required this.stream,
    required this.streamSubscription,
  });

  T? get value => stream.valueOrNull;

  Future<void> dispose() async {
    await streamSubscription.cancel();
    await stream.close();
  }

  @override
  StreamSubscription<T> listen(
    void Function(T)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

/// This function uses async* and yield* to convert a future of a stream into a
/// stream that just first fires when the future completes and the stream fires.
///
/// The syntax is very confusing but it lets us simplify Future<Stream<T>> into
/// just Stream<T>. This is useful when we need to do async things when
/// retrieving the stream but want to handle it in the UI with just a
/// StreamBuilder.
BehaviorSubjectWrapper<T> wrapInBehaviorSubjectAsync<T>(
  Future<Stream<T>> Function() streamFunction,
) =>
    BehaviorSubjectWrapper<T>(() async* {
      yield* await streamFunction();
    }());

/// Executes [Transaction] from a given [transaction].
///
/// If [transaction] is null - then new [Transaction] will be spin-off.
class TransactionRunner {
  final Transaction? transaction;

  TransactionRunner({this.transaction});

  Future<T> run<T>(
    Future<T> Function(Transaction transaction) transactionFunction,
  ) {
    final localTransaction = transaction;

    if (localTransaction != null) {
      return transactionFunction(localTransaction);
    } else {
      return firestoreDatabase.firestore
          .runTransaction((transaction) => transactionFunction(transaction));
    }
  }
}

/// This class preserves the length of the list of documents that are retrieved in a query in order
/// to determine whether the end of a collection has been reached. Some documents may be removed from
/// the list if they fail to deserialize, so the size represents all documents retrieved from the query.
class FirestoreQueryResult<T> {
  final int size;
  final List<T> result;

  FirestoreQueryResult({required this.size, required this.result});
}

Map<String, dynamic> toFirestoreJson(Map<String, dynamic> json) {
  var formattedJson = <String, dynamic>{};

  json.forEach((key, value) {
    if (value == serverTimestampValue) {
      formattedJson[key] = FieldValue.serverTimestamp();
    }
    // Check if the value is a DateTime object
    else if (value is DateTime) {
      formattedJson[key] = Timestamp.fromDate(value);
    } else if (value is Map) {
      formattedJson[key] = fromFirestoreJson(value as Map<String, dynamic>);
    } else if (value is List) {
      formattedJson[key] = value.map((v) {
        if (v is Map) {
          return toFirestoreJson(v as Map<String, dynamic>);
        } else {
          return v;
        }
      }).toList();
    } else {
      formattedJson[key] = value;
    }
  });

  return formattedJson;
}

Map<String, dynamic> fromFirestoreJson(Map<String, dynamic> json) {
  var formattedJson = <String, dynamic>{};

  json.forEach((key, value) {
    if (value is Timestamp) {
      formattedJson[key] = value.toDate();
    } else if (value is Map) {
      formattedJson[key] = fromFirestoreJson(value as Map<String, dynamic>);
    } else if (value is List) {
      formattedJson[key] = value.map((v) {
        if (v is Map) {
          return fromFirestoreJson(v as Map<String, dynamic>);
        } else {
          return v;
        }
      }).toList();
    } else if (value == serverTimestampValue) {
      formattedJson[key] = DateTime.now();
    } else {
      formattedJson[key] = value;
    }
  });

  return formattedJson;
}
