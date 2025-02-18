import 'package:flutter_test/flutter_test.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/community/community.dart';

void main() {
  group('DateTimeExtension', () {
    group('getFormattedTime', () {
      test('default', () {
        final DateTime dateTime = DateTime(2020, 1, 2, 3, 4, 5, 6, 7);

        final result = dateTime.getFormattedTime();

        expect(result, '3:04 AM');
      });

      test('custom format', () {
        final DateTime dateTime = DateTime(2020, 1, 2, 3, 4, 5, 6, 7);

        final result =
            dateTime.getFormattedTime(format: 'dd-MMMM-yyyy hh:mm:ss a');

        expect(result, '02-January-2020 03:04:05 AM');
      });
    });
  });

  group('DurationExtension', () {
    group('getFormattedTime', () {
      final duration = Duration(
        days: 1,
        hours: 2,
        minutes: 3,
        seconds: 4,
        milliseconds: 5,
        microseconds: 6,
      );

      test('default', () {
        final result = duration.getFormattedTime();

        expect(result, '26:03:04');
      });

      test('only hours', () {
        final result = duration.getFormattedTime(
          showHours: true,
          showMinutes: false,
          showSeconds: false,
        );

        expect(result, '26');
      });

      test('only minutes', () {
        final result = duration.getFormattedTime(
          showHours: false,
          showMinutes: true,
          showSeconds: false,
        );

        expect(result, '03');
      });

      test('only seconds', () {
        final result = duration.getFormattedTime(
          showHours: false,
          showMinutes: false,
          showSeconds: true,
        );

        expect(result, '04');
      });

      test('hours and minutes', () {
        final result = duration.getFormattedTime(
          showHours: true,
          showMinutes: true,
          showSeconds: false,
        );

        expect(result, '26:03');
      });

      test('minutes and seconds', () {
        final result = duration.getFormattedTime(
          showHours: false,
          showMinutes: true,
          showSeconds: true,
        );

        expect(result, '03:04');
      });

      test('hours and minutes and seconds', () {
        final result = duration.getFormattedTime(
          showHours: true,
          showMinutes: true,
          showSeconds: true,
        );

        expect(result, '26:03:04');
      });

      test('hours and minutes and seconds', () {
        expect(
          () => duration.getFormattedTime(
            showHours: false,
            showMinutes: false,
            showSeconds: false,
          ),
          throwsAssertionError,
        );
      });
    });
  });

  group('AgendaItemTypeUIExtension', () {
    group('svgIconPath', () {
      void executeTest(AgendaItemType agendaItemType) {
        test('$agendaItemType', () {
          final result = agendaItemType.svgIconPath;
          final AppAsset expectedResult;

          switch (agendaItemType) {
            case AgendaItemType.text:
              expectedResult = AppAsset.kTextSvg;
              break;
            case AgendaItemType.video:
              expectedResult = AppAsset.video(true);
              break;
            case AgendaItemType.image:
              expectedResult = AppAsset.kImageSvg;
              break;
            case AgendaItemType.poll:
              expectedResult = AppAsset.kSurveySvg;
              break;
            case AgendaItemType.wordCloud:
              expectedResult = AppAsset.kWordCloudSvg;
              break;
            case AgendaItemType.userSuggestions:
              expectedResult = AppAsset.kThumbSvg;
              break;
          }

          expect(result.path, expectedResult.path);
        });
      }

      for (var agendaItemType in AgendaItemType.values) {
        executeTest(agendaItemType);
      }
    });

    group('pngIconPath', () {
      void executeTest(AgendaItemType agendaItemType) {
        test('$agendaItemType', () {
          final result = agendaItemType.pngIconPath;
          final AppAsset expectedResult;

          switch (agendaItemType) {
            case AgendaItemType.text:
              expectedResult = AppAsset.kTextPng;
              break;
            case AgendaItemType.video:
              expectedResult = AppAsset.video();
              break;
            case AgendaItemType.image:
              expectedResult = AppAsset.kImagePng;
              break;
            case AgendaItemType.poll:
              expectedResult = AppAsset.kSurveyPng;
              break;
            case AgendaItemType.wordCloud:
              expectedResult = AppAsset.kWordCloudPng;
              break;
            case AgendaItemType.userSuggestions:
              expectedResult = AppAsset.kThumbPng;
              break;
          }

          expect(result.path, expectedResult.path);
        });
      }

      for (var agendaItemType in AgendaItemType.values) {
        executeTest(agendaItemType);
      }
    });
  });

  group('EmotionTypeExtension', () {
    group('imageAssetPath', () {
      void executeTest(EmotionType emotionType) {
        test('$emotionType', () {
          final result = emotionType.imageAssetPath;
          final AppAsset expectedResult;

          switch (emotionType) {
            case EmotionType.thumbsUp:
              expectedResult = AppAsset('media/emoji-thumbs-up.png');
              break;
            case EmotionType.heart:
              expectedResult = AppAsset('media/emoji-heart.png');
              break;
            case EmotionType.hundred:
              expectedResult = AppAsset('media/emoji-hundred.png');
              break;
            case EmotionType.exclamation:
              expectedResult = AppAsset('media/emoji-exclamation.png');
              break;
            case EmotionType.plusOne:
              expectedResult = AppAsset('media/emoji-plus-one.png');
              break;
            case EmotionType.laughWithTears:
              expectedResult = AppAsset('media/emoji-laugh-tears.png');
              break;
            case EmotionType.heartEyes:
              expectedResult = AppAsset('media/emoji-heart-eyes.png');
              break;
          }

          expect(result.path, expectedResult.path);
        });
      }

      for (var emotionType in EmotionType.values) {
        executeTest(emotionType);
      }
    });

    group('stringEmoji', () {
      void executeTest(EmotionType emotionType) {
        test('$emotionType', () {
          final result = emotionType.stringEmoji;
          final String expectedResult;

          switch (emotionType) {
            case EmotionType.thumbsUp:
              expectedResult = '👍';
              break;
            case EmotionType.heart:
              expectedResult = '❤️';
              break;
            case EmotionType.hundred:
              expectedResult = '💯';
              break;
            case EmotionType.exclamation:
              expectedResult = '‼️';
              break;
            case EmotionType.plusOne:
              expectedResult = '➕';
              break;
            case EmotionType.laughWithTears:
              expectedResult = '😂';
              break;
            case EmotionType.heartEyes:
              expectedResult = '😍';
              break;
          }

          expect(result, expectedResult);
        });
      }

      for (var emotionType in EmotionType.values) {
        executeTest(emotionType);
      }
    });
  });

  group('OnboardingStepExtension', () {
    group('value', () {
      void executeTest(OnboardingStep onboardingStep) {
        test('$onboardingStep', () {
          final result = onboardingStep.value;
          final String expectedResult;

          switch (onboardingStep) {
            case OnboardingStep.brandSpace:
              expectedResult = 'brandSpace';
              break;
            case OnboardingStep.createGuide:
              expectedResult = 'createGuide';
              break;
            case OnboardingStep.hostEvent:
              expectedResult = 'hostEvent';
              break;
            case OnboardingStep.inviteSomeone:
              expectedResult = 'inviteSomeone';
              break;
            case OnboardingStep.createStripeAccount:
              expectedResult = 'createStripeAccount';
              break;
          }

          expect(result, expectedResult);
        });
      }

      for (var onboardingStep in OnboardingStep.values) {
        executeTest(onboardingStep);
      }
    });

    group('positionInOnboarding', () {
      void executeTest(OnboardingStep onboardingStep) {
        test('$onboardingStep', () {
          final result = onboardingStep.positionInOnboarding;
          final int expectedResult;

          switch (onboardingStep) {
            case OnboardingStep.brandSpace:
              expectedResult = 1;
              break;
            case OnboardingStep.createGuide:
              expectedResult = 2;
              break;
            case OnboardingStep.hostEvent:
              expectedResult = 3;
              break;
            case OnboardingStep.inviteSomeone:
              expectedResult = 4;
              break;
            case OnboardingStep.createStripeAccount:
              expectedResult = 5;
              break;
          }

          expect(result, expectedResult);
        });
      }

      for (var onboardingStep in OnboardingStep.values) {
        executeTest(onboardingStep);
      }
    });

    group('titleIconPath', () {
      void executeTest(OnboardingStep onboardingStep) {
        test('$onboardingStep', () {
          final result = onboardingStep.titleIconPath;
          final AppAsset expectedResult;

          switch (onboardingStep) {
            case OnboardingStep.brandSpace:
              expectedResult = AppAsset.kEmojiSparklePng;
              break;
            case OnboardingStep.createGuide:
              expectedResult = AppAsset.kEmojiNotepadPng;
              break;
            case OnboardingStep.hostEvent:
              expectedResult = AppAsset.kEmojiMegaphonePng;
              break;
            case OnboardingStep.inviteSomeone:
              expectedResult = AppAsset.kEmojiCalendarPng;
              break;
            case OnboardingStep.createStripeAccount:
              expectedResult = AppAsset.kEmojiYellowHeartPng;
              break;
          }

          expect(result, expectedResult);
        });
      }

      for (var onboardingStep in OnboardingStep.values) {
        executeTest(onboardingStep);
      }
    });

    group('title', () {
      void executeTest(OnboardingStep onboardingStep) {
        test('$onboardingStep', () {
          final result = onboardingStep.title;
          final String expectedResult;

          switch (onboardingStep) {
            case OnboardingStep.brandSpace:
              expectedResult = 'Looking good';
              break;
            case OnboardingStep.createGuide:
              expectedResult = 'Looking good';
              break;
            case OnboardingStep.hostEvent:
              expectedResult = 'Get people talking';
              break;
            case OnboardingStep.inviteSomeone:
              expectedResult = 'Get it on the books';
              break;
            case OnboardingStep.createStripeAccount:
              expectedResult = 'Start processing payments';
              break;
          }

          expect(result, expectedResult);
        });
      }

      for (var onboardingStep in OnboardingStep.values) {
        executeTest(onboardingStep);
      }
    });

    group('sectionTitle', () {
      void executeTest(OnboardingStep onboardingStep) {
        test('$onboardingStep', () {
          final result = onboardingStep.sectionTitle;

          final String expectedResult;
          switch (onboardingStep) {
            case OnboardingStep.brandSpace:
              expectedResult = 'Brand your space';
              break;
            case OnboardingStep.createGuide:
              expectedResult = 'Create a template';
              break;
            case OnboardingStep.hostEvent:
              expectedResult = 'Schedule an event';
              break;
            case OnboardingStep.inviteSomeone:
              expectedResult = 'Invite your people';
              break;
            case OnboardingStep.createStripeAccount:
              expectedResult = 'Link your Stripe account';
              break;
          }

          expect(result, expectedResult);
        });
      }

      for (var onboardingStep in OnboardingStep.values) {
        executeTest(onboardingStep);
      }
    });
  });
}
