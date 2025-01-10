part of 'brady_bunch_layout.dart';

/// Values the page can manipulate to optimize the video layout
class BradyBunchLayoutParameters {
  final int rows;
  final int columns;
  final double aspectRatio;

  const BradyBunchLayoutParameters({
    required this.rows,
    required this.columns,
    required this.aspectRatio,
  });

  BradyBunchLayoutParameters manipulate({
    bool incrementRows = false,
    bool incrementColumns = false,
  }) =>
      BradyBunchLayoutParameters(
        rows: incrementRows ? rows + 1 : rows,
        columns: incrementColumns ? columns + 1 : columns,
        aspectRatio: aspectRatio,
      );

  BradyBunchLayoutParameters withAspectRatio(double ratio) =>
      BradyBunchLayoutParameters(
        rows: rows,
        columns: columns,
        aspectRatio: ratio.clamp(1.0, 16 / 9),
      );

  @override
  bool operator ==(other) =>
      other is BradyBunchLayoutParameters &&
      other.rows == rows &&
      other.columns == columns &&
      other.aspectRatio == aspectRatio;

  @override
  int get hashCode => hash3(rows, columns, aspectRatio);

  @override
  String toString() =>
      '(Parameters) rows: $rows, columns: $columns, rect: $aspectRatio';
}
