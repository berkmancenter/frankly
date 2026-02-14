import 'dart:io';

import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:combiner_functions/functions.dart';

@CloudFunction()
Future<Response> function(Request request) async {
  final router = Router();
  final combineHandler = CombineHandler();

  // Health check endpoint
  router.get('/health', (Request request) {
    return Response.ok('OK');
  });

  // Main combine endpoint
  router.post('/combine', combineHandler.handle);

  // Handle the request
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  return await handler(request);
}

void main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final router = Router();
  final combineHandler = CombineHandler();

  router.get('/health', (Request request) {
    return Response.ok('OK');
  });

  router.post('/combine', combineHandler.handle);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Server running on http://${server.address.host}:${server.port}');
}

Future<HttpServer> serve(
  Handler handler,
  InternetAddress address,
  int port,
) async {
  final server = await HttpServer.bind(address, port);

  server.listen((HttpRequest request) async {
    final shelfRequest = Request(
      request.method,
      request.requestedUri,
      body: request,
      headers: _extractHeaders(request),
    );

    final response = await handler(shelfRequest);
    await _writeResponse(response, request.response);
  });

  return server;
}

Map<String, String> _extractHeaders(HttpRequest request) {
  final headers = <String, String>{};
  request.headers.forEach((name, values) {
    headers[name] = values.join(', ');
  });
  return headers;
}

Future<void> _writeResponse(Response response, HttpResponse httpResponse) async {
  httpResponse.statusCode = response.statusCode;

  response.headers.forEach((key, value) {
    httpResponse.headers.set(key, value);
  });

  final body = await response.read().toList();
  for (final chunk in body) {
    httpResponse.add(chunk);
  }

  await httpResponse.close();
}
