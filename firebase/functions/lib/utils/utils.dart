import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:data_models/cloud_functions/requests.dart';

class JsonMap extends SerializeableRequest {
  final Map<String, dynamic> json;

  JsonMap(this.json);

  @override
  String toString() => json.toString();
}

bool isNullOrEmpty(String? value) => value == null || value.trim() == '';

void orElseUnauthorized(bool condition, {String? logMessage}) {
  if (!condition) {
    if (logMessage == null) {
      print('Throwing unauthorized exception');
    } else {
      print('Throwing unauthorized exception: $logMessage');
    }
    throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
  }
}

void orElseNotFound(bool condition, {String? logMessage}) {
  if (!condition) {
    if (logMessage == null) {
      print('Throwing not found exception');
    } else {
      print('Throwing not found exception: $logMessage');
    }
    throw HttpsError(HttpsError.notFound, 'not found', null);
  }
}

void orElseInvalidArgument(bool condition) {
  if (!condition) {
    print('Throwing invalid argument exception');
    throw HttpsError(HttpsError.invalidArgument, 'invalid argument', null);
  }
}

extension CommunityIterableExtension<T> on Iterable<T?> {
  Iterable<T> get withoutNulls {
    return <T>[
      for (final element in this)
        if (element != null) element,
    ];
  }

  Iterable<T> whereNotNull(dynamic Function(T?) valueMap) {
    return <T>[
      for (final element in map((element) => valueMap(element)))
        if (element != null) element,
    ];
  }
}
