import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUtils {
  /// Updates test screen size.
  ///
  /// By default screen size is 800x600.
  static void updateScreenSize(
    WidgetTester tester,
    double width,
    double height,
  ) {
    // Resets screen size after each test.
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    final renderView = WidgetsBinding.instance?.renderView;

    if (renderView != null) {
      renderView.configuration =
          TestViewConfiguration(size: Size(width, height));
    }
  }
}
