@JS()
library google_cloud.tasks;

import 'package:js/js.dart';
import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';

TasksModule? get tasks =>
    _tasks ??= require('@google-cloud/tasks') as TasksModule;
TasksModule? _tasks;

@JS()
@anonymous
abstract class TasksModule {
  //ignore: non_constant_identifier_names
  dynamic get CloudTasksClient;
}

CloudTasksClient createCloudTasksClient() {
  return callConstructor(tasks!.CloudTasksClient, []) as CloudTasksClient;
}

@JS()
@anonymous
abstract class CloudTasksClient {
  /// Construct an instance of CloudTasksClient.
  /// parameters for more details.
  /// using a .pem or .p12 keyFilename.
  /// .p12 key downloaded from the Google Developers Console. If you provide
  /// a path to a JSON file, the projectId option below is not necessary.
  /// NOTE: .pem and .p12 require you to specify options.email as well.
  /// the remote host.
  /// Developer's Console, e.g. 'grape-spaceship-123'. We will also check
  /// the environment variable GCLOUD_PROJECT for your project ID. If your
  /// app is running in an environment which supports
  /// [https://developers.google.com/identity/protocols/application-default-credentials Application Default Credentials],
  /// your project ID will be detected automatically.
  /// API remote host.
  external factory CloudTasksClient();

  external String get servicePath;

  external dynamic getProjectId();

  /// Return a fully-qualified queue resource name string.
  external String queuePath(String project, String location, String queue);

  external dynamic createTask(
      CreateTaskRequest request); //[CallOptions callOptions]);
}

@JS()
@anonymous
abstract class Task {
  external String get name;

  external HttpRequest get httpRequest;

  external Timestamp get scheduleTime;

  external factory Task(
      {String name, HttpRequest httpRequest, Timestamp scheduleTime});
}

@JS()
@anonymous
abstract class Headers {
  @JS('Content-Type')
  external String get contentType;

  external factory Headers({
    String contentType,
  });
}

@JS()
@anonymous
abstract class HttpRequest {
  external String get url;

  external String get httpMethod;

  external String get body;

  external dynamic get headers;

  external factory HttpRequest({
    String url,
    String httpMethod,
    String body,
    dynamic headers,
  });

  //external Uint8List get body;
/*
  url	string | null	<optional>
HttpRequest url

httpMethod	google.cloud.tasks.v2.HttpMethod | null	<optional>
HttpRequest httpMethod

headers	Object.<string, string> | null	<optional>
HttpRequest headers

body	Uint8Array | null	<optional>
HttpRequest body

oauthToken	google.cloud.tasks.v2.IOAuthToken | null	<optional>
HttpRequest oauthToken

oidcToken	google.cloud.tasks.v2.IOidcToken | null	<optional>
HttpRequest oidcToken
*/
}

@JS()
@anonymous
abstract class Timestamp {
  external String get seconds;

  external factory Timestamp({String seconds});
}

@JS()
@anonymous
abstract class CreateTaskRequest {
  external String get parent;

  external Task get task;

  external factory CreateTaskRequest({String parent, Task task});
}
