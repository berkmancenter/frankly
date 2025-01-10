import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockMediaQueryData mockMediaQueryData = MockMediaQueryData();
  final MockBuildContext mockBuildContext = MockBuildContext();

  ResponsiveLayoutService responsiveLayoutService =
      ResponsiveLayoutService(mediaQueryData: mockMediaQueryData);

  setUp(() {
    responsiveLayoutService =
        ResponsiveLayoutService(mediaQueryData: mockMediaQueryData);
  });

  tearDown(() {
    reset(mockMediaQueryData);
    reset(mockBuildContext);
  });

  test('isMobile', () {
    when(mockMediaQueryData.size).thenReturn(Size(998, 0));
    expect(responsiveLayoutService.isMobile(mockBuildContext), isTrue);

    //

    when(mockMediaQueryData.size).thenReturn(Size(999, 0));
    expect(responsiveLayoutService.isMobile(mockBuildContext), isTrue);

    //

    when(mockMediaQueryData.size).thenReturn(Size(1000, 0));
    expect(responsiveLayoutService.isMobile(mockBuildContext), isFalse);

    //

    when(mockMediaQueryData.size).thenReturn(Size(1001, 0));
    expect(responsiveLayoutService.isMobile(mockBuildContext), isFalse);
  });

  test('isMaxSupportedMobileSize', () {
    when(mockMediaQueryData.size).thenReturn(Size(349, 0));
    expect(
      responsiveLayoutService.isMaxSupportedMobileSize(mockBuildContext),
      isTrue,
    );

    //

    when(mockMediaQueryData.size).thenReturn(Size(350, 0));
    expect(
      responsiveLayoutService.isMaxSupportedMobileSize(mockBuildContext),
      isTrue,
    );

    //

    when(mockMediaQueryData.size).thenReturn(Size(351, 0));
    expect(
      responsiveLayoutService.isMaxSupportedMobileSize(mockBuildContext),
      isFalse,
    );

    //

    when(mockMediaQueryData.size).thenReturn(Size(352, 0));
    expect(
      responsiveLayoutService.isMaxSupportedMobileSize(mockBuildContext),
      isFalse,
    );
  });

  group('getDynamicSize', () {
    test('isMobile', () {
      when(mockMediaQueryData.size).thenReturn(Size(999, 0));

      expect(responsiveLayoutService.getDynamicSize(mockBuildContext, 30), 20);
      expect(
        responsiveLayoutService.getDynamicSize(
          mockBuildContext,
          30,
          scale: 4 / 3,
        ),
        40,
      );
    });

    test('!isMobile', () {
      when(mockMediaQueryData.size).thenReturn(Size(1000, 0));

      expect(responsiveLayoutService.getDynamicSize(mockBuildContext, 30), 30);
      expect(
        responsiveLayoutService.getDynamicSize(
          mockBuildContext,
          30,
          scale: 4 / 3,
        ),
        30,
      );
    });
  });
}
