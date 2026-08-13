import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';

/// Whether this function is running in the Firebase emulator suite rather
/// than in a deployed environment. The Firebase Functions emulator sets
/// `FUNCTIONS_EMULATOR=true` in the process env before loading user code.
bool get isEmulator => getProperty(getProperty(process, 'env'), 'FUNCTIONS_EMULATOR') == 'true';
