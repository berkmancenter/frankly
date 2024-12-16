// ignore_for_file: invalid_use_of_visible_for_testing_member

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';

class DriverBinding extends BindingBase
    with
        SchedulerBinding,
        ServicesBinding,
        GestureBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding {
  DriverBinding();

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();
    final FlutterDriverExtension extension =
        FlutterDriverExtension(null, false, true, finders: [], commands: []);
    registerServiceExtension(
      name: 'driver',
      callback: extension.call,
    );

    js.context[r'$driver'] = (js.JsObject params) {
      final js.JsArray keys = js.context['Object'].callMethod('keys', [params]);
      final map = {for (var k in keys) k.toString(): params[k].toString()};
      final future = extension.call(map);
      final promiseConst = js.context['Promise'] as js.JsFunction;
      final result = js.JsObject(promiseConst, [
        (js.JsFunction resolve, js.JsFunction reject) {
          future.then(
            (v) {
              resolve.apply([js.JsObject.jsify(v)]);
            },
            onError: (e) => reject.apply([e.toString()]),
          );
        }
      ]);
      return result;
    };
  }
}
