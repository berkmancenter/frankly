import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';

/// Whether this function is running in the Firebase emulator suite rather
/// than in a deployed environment. The Firebase Functions emulator sets
/// `FUNCTIONS_EMULATOR=true` in the process env before loading user code.
bool get isEmulator =>
    getProperty(getProperty(process, 'env'), 'FUNCTIONS_EMULATOR') == 'true';

/// The project id the emulator suite was started with (from `--project`). The
/// Firebase Functions emulator exposes it as `GCLOUD_PROJECT`. Returns null
/// when unset (e.g. in a deployed environment or unit tests).
String? get emulatorProjectId {
  final value =
      getProperty(getProperty(process, 'env'), 'GCLOUD_PROJECT') as String?;
  return (value == null || value.isEmpty) ? null : value;
}
