import 'dart:math';
import 'dart:ui';

import 'package:client/core/utils/extensions.dart';
import 'package:quiver/core.dart';

part 'layout_parameters.dart';

part 'layout_values.dart';

/// This class represents a particular layout of videos and is used to calculate the 'cost function'
/// of a particular arrangement in terms of dead space, and iterate on possible combinations of
/// layout parameters in order to minimize that dead space
class BradyBunchLayout {
  final BradyBunchLayoutValues layoutValues;
  final BradyBunchLayoutParameters layoutParameters;
  static const rectAspect = 16 / 9;

  int get rows => layoutParameters.rows;

  int get columns => layoutParameters.columns;

  BradyBunchLayoutValues get v => layoutValues;

  BradyBunchLayoutParameters get p => layoutParameters;

  double get totalSpace => v.totalHeight * v.totalWidth;

  // Determines whether the layout is limited by the total width or the total height of the viewport
  bool get isWidthLimited =>
      v.totalWidth * p.rows < v.totalHeight * (p.columns * (p.aspectRatio));

  Size get imageSize {
    //Calculate image size based on the limited dimension and the aspect ratio:
    double imageWidth, imageHeight;
    if (isWidthLimited) {
      imageWidth = v.totalWidth / p.columns;
      imageHeight = imageWidth / (p.aspectRatio);
    } else {
      imageHeight = v.totalHeight / p.rows;
      imageWidth = imageHeight * (p.aspectRatio);
    }
    return Size(imageWidth, imageHeight);
  }

  double get deadSpace {
    final size = imageSize;
    final imageArea = size.width * size.height;
    final bradySpace = imageArea * v.numBradys;
    final totalSpace = v.totalWidth * v.totalHeight;

    int bradysOnLastRow = v.numBradys % p.rows;
    bool switchAspectOnLastRow = (p.aspectRatio > 1) && (bradysOnLastRow != 0);

    return totalSpace -
        bradySpace -
        (switchAspectOnLastRow
            ? imageArea * (getAdjustedAspectRatio - 1) * bradysOnLastRow
            : 0);
  }

  double get getAdjustedAspectRatio {
    final bradysOnLastRow = v.numBradys % (p.columns);
    if (bradysOnLastRow == 0) return p.aspectRatio;
    double fullAspect = p.columns * p.aspectRatio / bradysOnLastRow;
    return min(fullAspect, rectAspect);
  }

  BradyBunchLayout({
    required this.layoutParameters,
    required this.layoutValues,
  })  : assert(
          layoutValues.numBradys <=
              layoutParameters.rows * layoutParameters.columns,
          'Too many Bradys',
        ),
        assert(
          layoutValues.numBradys >
              layoutParameters.columns * (layoutParameters.rows - 1),
          'Not enough Bradys',
        );

  factory BradyBunchLayout.calculateOptimalLayout({
    required double width,
    required double height,
    required int participantCount,
  }) {
    // start with W as a single participant window
    final vals = BradyBunchLayoutValues(
      totalWidth: width,
      totalHeight: height,
      numBradys: 1,
    );

    BradyBunchLayout layoutToTest = BradyBunchLayout(
      layoutParameters: BradyBunchLayoutParameters(
        columns: 1,
        rows: 1,
        aspectRatio: 1,
      ),
      layoutValues: vals,
    );

    // First manipulate number of rows and columns until optimum of those values are reached
    BradyBunchLayout? previousLayout;
    do {
      previousLayout = layoutToTest;
      layoutToTest =
          layoutToTest.exploreRowAndColumnVariations(participantCount);
    } while (layoutToTest.layoutValues.numBradys < participantCount ||
        previousLayout != layoutToTest);

    // Next, if layout is not width limited, increase aspect ratio to take up as much space as possible:
    if (!layoutToTest.isWidthLimited) {
      layoutToTest = layoutToTest.expandHorizontally();

      // Move items onto last row if there is room and compare
      final normalizedColumns =
          (layoutToTest.layoutValues.numBradys / layoutToTest.rows).ceil();
      if (normalizedColumns != layoutToTest.columns) {
        final normalizedLayout = layoutToTest
            .setParams(columns: normalizedColumns)
            .expandHorizontally();

        if (normalizedLayout.deadSpace < layoutToTest.deadSpace) {
          return normalizedLayout;
        } else {
          return layoutToTest;
        }
      } else {
        return layoutToTest;
      }
    }

    // Otherwise try removing column or adding row and increasing aspect ratio:
    if (layoutToTest.columns > 1) {
      if (layoutToTest.rows >= layoutToTest.columns) {
        // Rows greater than or equal to columns, try removing single column
        final adjustedRows =
            (layoutToTest.layoutValues.numBradys / (layoutToTest.columns - 1))
                .ceil();

        final removeColumnLayout = layoutToTest
            .setParams(rows: adjustedRows, columns: layoutToTest.columns - 1)
            .expandHorizontally();

        if (removeColumnLayout.deadSpace < layoutToTest.deadSpace) {
          return removeColumnLayout;
        }
      } else {
        // Columns greater than rows, try adding single row
        final adjustedColumns =
            (layoutToTest.layoutValues.numBradys / (layoutToTest.rows + 1))
                .ceil();

        final addRowLayout = layoutToTest
            .setParams(rows: layoutToTest.rows + 1, columns: adjustedColumns)
            .expandHorizontally();

        if (addRowLayout.deadSpace < layoutToTest.deadSpace) {
          return addRowLayout;
        }
      }
    }

    return layoutToTest;
  }

  BradyBunchLayout exploreRowAndColumnVariations(int participantCount) {
    final BradyBunchLayoutValues vals = layoutValues;

    int atMost(int count) => min(count, participantCount);

    // Potential layouts to try:
    BradyBunchLayout? manipulateRowLayout;
    BradyBunchLayout? manipulateColumnLayout;
    BradyBunchLayout? manipulateRowAndColumnLayout;

    // Those layouts deadspace:
    double? manipulateRowDeadspace;
    double? manipulateColumnDeadspace;
    double? manipulateRowAndColumnDeadspace;
    double? thisDeadspace;

    // Set deadspace values for valid potential layouts:
    if (vals.numBradys == participantCount) {
      thisDeadspace = deadSpace;
    } else {
      // If there are enough participants, try adding column
      if (participantCount > rows * columns) {
        manipulateRowLayout = BradyBunchLayout(
          layoutValues: vals.withBradyCount(atMost(vals.numBradys + columns)),
          layoutParameters: layoutParameters.manipulate(incrementRows: true),
        );
        manipulateRowDeadspace = manipulateRowLayout.deadSpace;
      }

      // If there are enough participants, try adding row
      if (participantCount > (rows - 1) * (columns + 1)) {
        manipulateColumnLayout = BradyBunchLayout(
          layoutValues: vals.withBradyCount(atMost(vals.numBradys + rows)),
          layoutParameters: layoutParameters.manipulate(incrementColumns: true),
        );
        manipulateColumnDeadspace = manipulateColumnLayout.deadSpace;
      }

      // If there are enough participants, try adding row + column
      if (participantCount > rows * (columns + 1)) {
        manipulateRowAndColumnLayout = BradyBunchLayout(
          layoutParameters: layoutParameters.manipulate(
            incrementRows: true,
            incrementColumns: true,
          ),
          layoutValues:
              vals.withBradyCount(atMost(vals.numBradys + rows + columns + 1)),
        );
        manipulateRowAndColumnDeadspace =
            manipulateRowAndColumnLayout.deadSpace;
      }
    }

    final validDeadspaces = <double?>[
      thisDeadspace,
      manipulateRowDeadspace,
      manipulateColumnDeadspace,
      manipulateRowAndColumnDeadspace,
    ].withoutNulls.toList();

    final minDeadspace =
        (validDeadspaces..sort((a, b) => a.compareTo(b))).first;

    if (minDeadspace == thisDeadspace) {
      return this;
    } else if (minDeadspace == manipulateRowDeadspace) {
      return manipulateRowLayout!;
    } else if (minDeadspace == manipulateRowAndColumnDeadspace) {
      return manipulateRowAndColumnLayout!;
    } else if (minDeadspace == manipulateColumnDeadspace) {
      return manipulateColumnLayout!;
    } else {
      throw UnimplementedError('No valid layout');
    }
  }

  BradyBunchLayout expandHorizontally() {
    final maxUnboundedAspectRatio =
        layoutValues.totalWidth / (imageSize.height * columns);
    final aspectRatio = min(maxUnboundedAspectRatio, 16 / 9);

    return setParams(aspectRatio: aspectRatio);
  }

  BradyBunchLayout setParams({
    final int? rows,
    final int? columns,
    final double? aspectRatio,
  }) =>
      BradyBunchLayout(
        layoutValues: layoutValues,
        layoutParameters: BradyBunchLayoutParameters(
          rows: rows ?? this.rows,
          columns: columns ?? this.columns,
          aspectRatio: aspectRatio ?? layoutParameters.aspectRatio,
        ),
      );

  @override
  bool operator ==(other) =>
      other is BradyBunchLayout &&
      other.layoutParameters == layoutParameters &&
      other.layoutValues == layoutValues;

  @override
  int get hashCode => hash2(layoutParameters.hashCode, layoutValues.hashCode);

  @override
  String toString() =>
      'BradyBunchLayout: \n\t$layoutParameters\n\t$layoutValues\n\tDeadspace: ${deadSpace ~/ 1000}k pixels';
}
