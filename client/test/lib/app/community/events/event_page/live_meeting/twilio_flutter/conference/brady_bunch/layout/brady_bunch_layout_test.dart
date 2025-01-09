import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/video/utils/brady_bunch_layout.dart';

main() {
  double getMaxDeadspace(int participantCount) {
    const resolution = 10;
    const minSize = Size(500, 200);
    const maxSize = Size(2000, 2000);
    double maxDeadspacePct = 0.0;

    for (int i = minSize.width ~/ resolution;
        i < maxSize.width ~/ resolution;
        i++) {
      for (int j = minSize.height ~/ resolution;
          j < maxSize.height ~/ resolution;
          j++) {
        final width = (resolution * i).toDouble();
        final height = (resolution * j).toDouble();
        final layout = BradyBunchLayout.calculateOptimalLayout(
          width: width,
          height: height,
          participantCount: participantCount,
        );
        final deadspace = layout.deadSpace;
        final deadspacePct = deadspace / (width * height);
        if (deadspacePct > maxDeadspacePct) {
          maxDeadspacePct = deadspacePct;
        }
      }
    }
    return maxDeadspacePct;
  }

  group(
    'bradyBunchLayoutMaxDeadspace',
    () {
      test('2 participants max deadspace less than 65%', () {
        var maxDeadspacePct = getMaxDeadspace(2);
        expect(maxDeadspacePct < .65, isTrue);
      });

      test('3 participants max deadspace less than 47%', () {
        var maxDeadspacePct = getMaxDeadspace(3);
        expect(maxDeadspacePct < .47, isTrue);
      });
      test('4 participants or more deadspace less than 34%', () {
        var max = 0.0;
        for (int i = 4; i <= 10; i++) {
          final maxDeadspaceForUserCount = getMaxDeadspace(i);
          if (maxDeadspaceForUserCount > max) {
            max = maxDeadspaceForUserCount;
          }
        }
        expect(max < .34, isTrue);
      });
    },
  );

  group(
    'bradyBunchLayoutParticipantCount',
    () {
      test('allParticipantsLaidOut', () {
        const resolution = 50;
        const minSize = Size(500, 200);
        const maxSize = Size(2000, 2000);
        bool allParticipantsLaidOut = true;
        BradyBunchLayout? violatingLayout;
        int? expectedParticipants;
        for (int p = 2; p <= 10; p++) {
          for (int i = minSize.width ~/ resolution;
              i < maxSize.width ~/ resolution;
              i++) {
            for (int j = minSize.height ~/ resolution;
                j < maxSize.height ~/ resolution;
                j++) {
              final width = (resolution * i).toDouble();
              final height = (resolution * j).toDouble();
              final layout = BradyBunchLayout.calculateOptimalLayout(
                width: width,
                height: height,
                participantCount: p,
              );
              if (layout.layoutValues.numBradys != p) {
                allParticipantsLaidOut = false;
                violatingLayout = layout;
                expectedParticipants = p;
                break;
              }
            }
          }
        }

        expect(
          allParticipantsLaidOut,
          isTrue,
          reason:
              'ExpectedParticipants: $expectedParticipants, Violating layout: $violatingLayout',
        );
      });
    },
  );

  group(
    'bradyBunchLayoutImageBounds',
    () {
      test('imageSizeConsistentWithConstraints', () {
        const resolution = 50;
        const minSize = Size(500, 200);
        const maxSize = Size(2000, 2000);
        bool imageSizesConsistent = true;
        BradyBunchLayout? violatingLayout;
        Size? sizeToAccomodate;
        String? problem;
        Size? violatingImageSize;
        for (int p = 2; p <= 10; p++) {
          for (int i = minSize.width ~/ resolution;
              i < maxSize.width ~/ resolution;
              i++) {
            for (int j = minSize.height ~/ resolution;
                j < maxSize.height ~/ resolution;
                j++) {
              final width = (resolution * i).toDouble();
              final height = (resolution * j).toDouble();
              final layout = BradyBunchLayout.calculateOptimalLayout(
                width: width,
                height: height,
                participantCount: p,
              );
              final imageSize = layout.imageSize;
              final layoutTooWide =
                  layout.layoutParameters.columns * imageSize.width >
                      (i * resolution).toDouble() + .01;
              final layoutTooTall =
                  layout.layoutParameters.rows * imageSize.height >
                      j * resolution + .01;
              final layoutTooSmall = (layout.layoutParameters.rows *
                              imageSize.height) -
                          (j * resolution) >
                      .01 &&
                  (layout.layoutParameters.columns) - (i * resolution) > .01;

              if (layoutTooWide || layoutTooTall || layoutTooSmall) {
                imageSizesConsistent = false;
                violatingLayout = layout;
                sizeToAccomodate = Size(
                  (i * resolution).toDouble(),
                  (j * resolution).toDouble(),
                );
                violatingImageSize = imageSize;
                problem = layoutTooWide
                    ? 'TOO WIDE'
                    : layoutTooTall
                        ? 'TOO TALL'
                        : 'TOO SMALL';
                break;
              }
            }
          }
        }

        expect(
          imageSizesConsistent,
          isTrue,
          reason:
              'Size to accomodate: $sizeToAccomodate, Problem: $problem, \nViolating layout: $violatingLayout\nImage size: $violatingImageSize',
        );
      });
    },
  );
}
