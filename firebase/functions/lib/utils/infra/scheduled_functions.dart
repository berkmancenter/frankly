import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_http/node_http.dart' as http;
import 'extend_cloud_task_scheduler.dart';
import 'cloud_tasks_client.dart' as tasks;
import 'emulator_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:node_interop/util.dart';

final scheduledFunctions = ScheduledFunctions();

class ScheduledFunctions {
  static const Duration _deployTaskCutoff = Duration(days: 28);

  tasks.CloudTasksClient? _client;
  tasks.CloudTasksClient get client =>
      _client ??= tasks.createCloudTasksClient();

  String get _projectId {
    final projectId = functions.config.get('app.project_id') as String?;
    if (projectId == null || projectId.isEmpty) {
      throw StateError('app.project_id must be set in the functions config');
    }
    return projectId;
  }

  String _configValueOrEmpty(String key) {
    try {
      final value = functions.config.get(key);
      if (value == null) return '';
      return value.toString().trim();
    } catch (_) {
      return '';
    }
  }

  String get queueRegion {
    final configuredRegion = _configValueOrEmpty('functions.cloud_tasks_region');
    if (configuredRegion.isNotEmpty) return configuredRegion;

    final functionsRegion = _configValueOrEmpty('functions.region');
    if (functionsRegion.isNotEmpty) return functionsRegion;

    return 'us-east4';
  }

  String get parentPath => client.queuePath(
        _projectId,
        queueRegion,
        'scheduled-functions',
      );

  Future<void> enqueueCall(
    String functionName,
    String encodedJsonPayload,
    DateTime scheduledTime,
  ) async {
    final cutoffTime = DateTime.now().add(_deployTaskCutoff);
    if (scheduledTime.isAfter(cutoffTime)) {
      print('Rescheduling task since its after cutoff time');
      await ExtendCloudTaskScheduler().schedule(
        ExtendCloudTaskSchedulerRequest(
          scheduledTime: scheduledTime.toUtc(),
          functionName: functionName,
          payload: encodedJsonPayload,
        ),
        cutoffTime,
      );
    } else {
      print('Enqueuing task to call its function');
      await _enqueueDirectly(functionName, encodedJsonPayload, scheduledTime);
    }
  }

  Future<void> _enqueueDirectly(
    String functionName,
    String encodedJson,
    DateTime scheduledTime,
  ) async {
    final urlPrefix =
        functions.config.get('app.functions_url_prefix') as String;

    if (isEmulator) {
      // Cloud Tasks is a real GCP service and can't dispatch HTTP callbacks
      // back to a local 127.0.0.1 emulator URL, so the queued task would
      // just retry and fail forever. Call the function directly instead,
      // waiting until the scheduled time to preserve the delay.
      print(
        'Emulator detected: calling $functionName directly instead of via Cloud Tasks',
      );
      final delay = scheduledTime.difference(DateTime.now());
      Timer(delay.isNegative ? Duration.zero : delay, () async {
        try {
          final result = await http.post(
            Uri.parse('$urlPrefix/$functionName'),
            headers: {'Content-Type': 'application/json'},
            body: encodedJson,
          );
          print(
            'Emulator direct call to $functionName returned ${result.statusCode}',
          );
        } catch (e) {
          print('Error calling $functionName directly in emulator: $e');
        }
      });
      return;
    }

    final createTaskRequest = jsify({
      'parent': parentPath,
      'task': {
        'httpRequest': {
          'url': '$urlPrefix/$functionName',
          'httpMethod': 'POST',
          'body': base64.encode(Uint8List.fromList(encodedJson.codeUnits)),
          'headers': {'Content-Type': 'application/json'},
        },
        'scheduleTime': {
          'seconds':
              (scheduledTime.millisecondsSinceEpoch / 1000).round().toString(),
        },
      },
    });

    await promiseToFuture(client.createTask(createTaskRequest));
  }
}

T printAndReturn<T>(T value) {
  print(value);
  return value;
}
