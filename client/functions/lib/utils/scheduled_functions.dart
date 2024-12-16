import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_request/extend_cloud_task_scheduler.dart';
import 'package:junto_functions/interop/cloud_tasks_client.dart' as tasks;
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:node_interop/util.dart';

final scheduledFunctions = ScheduledFunctions();

class ScheduledFunctions {
  static const Duration _deployTaskCutoff = Duration(days: 28);

  tasks.CloudTasksClient? _client;
  tasks.CloudTasksClient get client => _client ??= tasks.createCloudTasksClient();

  String get parentPath => client.queuePath(
        isDev
            ? functions.config.get('app.dev_project_id') as String
            : functions.config.get('app.prod_project_id') as String,
        'us-east4',
        // This queue is poorly named as it is used to schedule all of our scheduled functions, not
        // just discussion notifications
        'discussion-notifications',
      );

  Future<void> enqueueCall(
      String functionName, String encodedJsonPayload, DateTime scheduledTime) async {
    final cutoffTime = DateTime.now().add(_deployTaskCutoff);
    if (scheduledTime.isAfter(cutoffTime)) {
      print('Rescheduling task since its after cutoff time');
      await ExtendCloudTaskScheduler().schedule(
          ExtendCloudTaskSchedulerRequest(
            scheduledTime: scheduledTime.toUtc(),
            functionName: functionName,
            payload: encodedJsonPayload,
          ),
          cutoffTime);
    } else {
      print('Enqueuing task to call its function');
      await _enqueueDirectly(functionName, encodedJsonPayload, scheduledTime);
    }
  }

  Future<void> _enqueueDirectly(
      String functionName, String encodedJson, DateTime scheduledTime) async {
    final urlPrefix = isDev
        ? functions.config.get('app.dev_functions_url_prefix') as String
        : functions.config.get('app.prod_functions_url_prefix') as String;
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
          'seconds': (scheduledTime.millisecondsSinceEpoch / 1000).round().toString(),
        }
      },
    });

    await promiseToFuture(client.createTask(createTaskRequest));
  }
}

T printAndReturn<T>(T value) {
  print(value);
  return value;
}
