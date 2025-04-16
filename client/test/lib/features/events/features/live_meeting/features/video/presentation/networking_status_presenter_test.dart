import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/models/networking_status_model.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/networking_status_presenter.dart';
import 'package:client/core/data/services/clock_service.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockView = MockNetworkingStatusView();
  final mockConferenceRoom = MockConferenceRoom();
  final mockEventProvider = MockEventProvider();
  final mockLiveMeetingProvider = MockLiveMeetingProvider();
  final mockRoom = MockAgoraRoom();
  final mockLocalParticipant = MockAgoraParticipant();

  final mockClockService = MockClockService();
  when(mockClockService.now()).thenReturn(DateTime.now());
  GetIt.instance.registerSingleton<ClockService>(mockClockService);

  late NetworkingStatusModel model;
  late NetworkingStatusPresenter presenter;

  setUp(() {
    model = NetworkingStatusModel();
    presenter = NetworkingStatusPresenter(
      mockBuildContext,
      mockView,
      model,
      conferenceRoom: mockConferenceRoom,
    );

    when(mockRoom.channelName).thenReturn('test-channel');
    when(mockRoom.token).thenReturn('token');
    when(mockRoom.liveMeetingProvider).thenReturn(mockLiveMeetingProvider);
    when(mockRoom.eventProvider).thenReturn(mockEventProvider);
    when(mockRoom.conferenceRoom).thenReturn(mockConferenceRoom);
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockConferenceRoom);
    reset(mockRoom);
    reset(mockLocalParticipant);
  });

  group('updateNetworkQuality', () {
    group(
        '_model.networkQualityLevel == QualityType.qualityBad && isVideoEnabled',
        () {
      test('network quality stays bad after 5s', () async {
        model.isLowNetworkQuality = false;
        expect(model.timer, isNull);

        when(mockConferenceRoom.room).thenReturn(mockRoom);
        when(mockRoom.localParticipant).thenReturn(mockLocalParticipant);
        when(mockLocalParticipant.networkQualityLevel)
            .thenReturn(QualityType.qualityBad);
        when(mockConferenceRoom.videoEnabled).thenReturn(true);

        presenter.updateNetworkQuality();

        await Future.delayed(Duration(seconds: 5));

        expect(model.isLowNetworkQuality, isTrue);
        verify(mockView.updateView()).called(1);
        expect(model.timer!.isActive, isTrue);
      });

      test('network quality changes within 5s', () async {
        model.isLowNetworkQuality = false;
        expect(model.timer, isNull);

        when(mockConferenceRoom.room).thenReturn(mockRoom);
        when(mockRoom.localParticipant).thenReturn(mockLocalParticipant);
        when(mockLocalParticipant.networkQualityLevel)
            .thenReturn(QualityType.qualityBad);
        when(mockConferenceRoom.videoEnabled).thenReturn(true);

        presenter.updateNetworkQuality();

        model.networkQualityLevel = QualityType.qualityGood;
        await Future.delayed(Duration(seconds: 5));

        expect(model.isLowNetworkQuality, isFalse);
        verify(mockView.updateView()).called(2);
        expect(model.timer!.isActive, isFalse);
      });
    });
    group(
      '_model.networkQualityLevel != QualityType.qualityBad && isVideoEnabled',
      () {
        test('_model.isLowNetworkQuality', () {
          model.isLowNetworkQuality = true;
          model.timer = Timer.periodic(Duration(seconds: 1), (_) {});
          expect(model.timer!.isActive, isTrue);

          when(mockConferenceRoom.room).thenReturn(mockRoom);
          when(mockRoom.localParticipant).thenReturn(mockLocalParticipant);
          when(mockLocalParticipant.networkQualityLevel)
              .thenReturn(QualityType.qualityGood);
          when(mockConferenceRoom.videoEnabled).thenReturn(true);

          presenter.updateNetworkQuality();

          expect(model.isLowNetworkQuality, isFalse);
          verify(mockView.updateView()).called(1);
          expect(model.timer!.isActive, isFalse);
        });
        test('!_model.isLowNetworkQuality', () {
          model.isLowNetworkQuality = false;
          model.timer = Timer.periodic(Duration(seconds: 1), (_) {});
          expect(model.timer!.isActive, isTrue);

          when(mockConferenceRoom.room).thenReturn(mockRoom);
          when(mockRoom.localParticipant).thenReturn(mockLocalParticipant);
          when(mockLocalParticipant.networkQualityLevel)
              .thenReturn(QualityType.qualityGood);
          when(mockConferenceRoom.videoEnabled).thenReturn(true);

          presenter.updateNetworkQuality();

          expect(model.isLowNetworkQuality, isFalse);
          verifyNever(mockView.updateView());
          expect(model.timer!.isActive, isFalse);
        });
      },
    );
    group(
        '_model.networkQualityLevel == QualityType.qualityBad && !isVideoEnabled',
        () {
      test('_model.isLowNetworkQuality', () {
        model.isLowNetworkQuality = true;
        model.timer = Timer.periodic(Duration(seconds: 1), (_) {});
        expect(model.timer!.isActive, isTrue);

        when(mockConferenceRoom.room).thenReturn(mockRoom);
        when(mockRoom.localParticipant).thenReturn(mockLocalParticipant);
        when(mockLocalParticipant.networkQualityLevel)
            .thenReturn(QualityType.qualityBad);
        when(mockConferenceRoom.videoEnabled).thenReturn(false);

        presenter.updateNetworkQuality();

        expect(model.isLowNetworkQuality, isFalse);
        verify(mockView.updateView()).called(1);
        expect(model.timer!.isActive, isFalse);
      });
      test('!_model.isLowNetworkQuality', () {
        model.isLowNetworkQuality = false;
        model.timer = Timer.periodic(Duration(seconds: 1), (_) {});
        expect(model.timer!.isActive, isTrue);

        when(mockConferenceRoom.room).thenReturn(mockRoom);
        when(mockRoom.localParticipant).thenReturn(mockLocalParticipant);
        when(mockLocalParticipant.networkQualityLevel)
            .thenReturn(QualityType.qualityBad);
        when(mockConferenceRoom.videoEnabled).thenReturn(false);

        presenter.updateNetworkQuality();

        expect(model.isLowNetworkQuality, isFalse);
        verifyNever(mockView.updateView());
        expect(model.timer!.isActive, isFalse);
      });
    });
    group(
        '_model.networkQualityLevel != QualityType.qualityBad && !isVideoEnabled',
        () {
      test('_model.isLowNetworkQuality', () {
        model.isLowNetworkQuality = true;
        model.timer = Timer.periodic(Duration(seconds: 1), (_) {});
        expect(model.timer!.isActive, isTrue);

        when(mockConferenceRoom.room).thenReturn(mockRoom);
        when(mockRoom.localParticipant).thenReturn(mockLocalParticipant);
        when(mockLocalParticipant.networkQualityLevel)
            .thenReturn(QualityType.qualityPoor);
        when(mockConferenceRoom.videoEnabled).thenReturn(false);

        presenter.updateNetworkQuality();

        expect(model.isLowNetworkQuality, isFalse);
        verify(mockView.updateView()).called(1);
        expect(model.timer!.isActive, isFalse);
      });
      test('!_model.isLowNetworkQuality', () {
        model.isLowNetworkQuality = false;
        model.timer = Timer.periodic(Duration(seconds: 1), (_) {});
        expect(model.timer!.isActive, isTrue);

        when(mockConferenceRoom.room).thenReturn(mockRoom);
        when(mockRoom.localParticipant).thenReturn(mockLocalParticipant);
        when(mockLocalParticipant.networkQualityLevel)
            .thenReturn(QualityType.qualityPoor);
        when(mockConferenceRoom.videoEnabled).thenReturn(false);

        presenter.updateNetworkQuality();

        expect(model.isLowNetworkQuality, isFalse);
        verifyNever(mockView.updateView());
        expect(model.timer!.isActive, isFalse);
      });
    });
  });

  group('dismissLowNetworkQualityMessage', () {
    test('is dismissed already', () {
      model.isLowNetworkQualityMessageDismissed = true;
      presenter.dismissLowNetworkQualityMessage();
      expect(model.isLowNetworkQualityMessageDismissed, isTrue);
    });

    test('was not dismissed', () {
      model.isLowNetworkQualityMessageDismissed = false;
      presenter.dismissLowNetworkQualityMessage();
      expect(model.isLowNetworkQualityMessageDismissed, isTrue);
    });
  });

  test('dispose', () {
    model.timer = Timer.periodic(Duration(seconds: 1), (_) {});
    expect(model.timer!.isActive, isTrue);

    presenter.dispose();

    expect(model.timer!.isActive, isFalse);
  });

  group('getCorrectWidget', () {
    final nothing = SizedBox.shrink();
    final networkStatusAlert = SizedBox.shrink();

    test(
        'device time is before required threshold time and low network quality message is dismissed',
        () {
      model.isLowNetworkQualityMessageDismissed = true;
      final DateTime timeBefore =
          model.messageShowTimeThreshold.subtract(Duration(seconds: 1));

      when(mockClockService.now()).thenReturn(timeBefore);
      final result = presenter.getCorrectWidget(
        nothing: nothing,
        networkStatusAlert: networkStatusAlert,
      );
      expect(result, nothing);
    });

    test(
        'device time is before required threshold time and low network quality message is not dismissed',
        () {
      model.isLowNetworkQualityMessageDismissed = false;
      final DateTime timeBefore =
          model.messageShowTimeThreshold.subtract(Duration(seconds: 1));

      when(mockClockService.now()).thenReturn(timeBefore);
      final result = presenter.getCorrectWidget(
        nothing: nothing,
        networkStatusAlert: networkStatusAlert,
      );
      expect(result, nothing);
    });

    test(
        'device time is at the same time as required threshold time and low network quality message is dismissed',
        () {
      model.isLowNetworkQualityMessageDismissed = true;
      final DateTime currentTime = model.messageShowTimeThreshold;

      when(mockClockService.now()).thenReturn(currentTime);
      final result = presenter.getCorrectWidget(
        nothing: nothing,
        networkStatusAlert: networkStatusAlert,
      );
      expect(result, nothing);
    });

    test(
        'device time is at the same time as required threshold time and low network quality message is not dismissed',
        () {
      model.isLowNetworkQualityMessageDismissed = false;
      final DateTime currentTime = model.messageShowTimeThreshold;

      when(mockClockService.now()).thenReturn(currentTime);
      final result = presenter.getCorrectWidget(
        nothing: nothing,
        networkStatusAlert: networkStatusAlert,
      );
      expect(result, nothing);
    });

    test(
        'device time is at the later time as required threshold time and low network quality message is dismissed',
        () {
      model.isLowNetworkQualityMessageDismissed = true;
      final DateTime timeAfter =
          model.messageShowTimeThreshold.add(Duration(seconds: 1));

      when(mockClockService.now()).thenReturn(timeAfter);
      final result = presenter.getCorrectWidget(
        nothing: nothing,
        networkStatusAlert: networkStatusAlert,
      );
      expect(result, nothing);
    });

    test(
        'device time is at the later time as required threshold time and low network quality message is not dismissed',
        () {
      model.isLowNetworkQualityMessageDismissed = false;
      final DateTime timeAfter =
          model.messageShowTimeThreshold.add(Duration(seconds: 1));

      when(mockClockService.now()).thenReturn(timeAfter);
      final result = presenter.getCorrectWidget(
        nothing: nothing,
        networkStatusAlert: networkStatusAlert,
      );
      expect(result, networkStatusAlert);
    });
  });
}
