part of 'brady_bunch_layout.dart';

/// Non-manipulable values given to the video layout
class BradyBunchLayoutValues {
  final double totalWidth;
  final double totalHeight;
  final int numBradys;

  const BradyBunchLayoutValues({
    required this.totalWidth,
    required this.totalHeight,
    required this.numBradys,
  });

  BradyBunchLayoutValues withBradyCount(int numBradys) =>
      BradyBunchLayoutValues(
        totalHeight: totalHeight,
        totalWidth: totalWidth,
        numBradys: numBradys,
      );

  @override
  bool operator ==(other) =>
      other is BradyBunchLayoutValues &&
      other.totalWidth == totalWidth &&
      other.totalHeight == totalHeight &&
      other.numBradys == numBradys;

  @override
  int get hashCode => hash3(totalWidth, totalHeight, numBradys);

  @override
  String toString() =>
      '(Values) width: $totalWidth, height: $totalHeight, bradys: $numBradys';
}
