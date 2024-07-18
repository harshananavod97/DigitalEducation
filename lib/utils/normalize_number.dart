class NormalizeNumber {
  //
  /// using min max normalization
  //
  static double inRange({
    required double currentValue,
    required double minValue,
    required double maxValue,
    required double newMaxValue,
    required double newMinValue,
  }) {
    // double convertedValue = 0.0;
    final convertedValue = (currentValue - minValue) /
            (maxValue - minValue) *
            (newMaxValue - newMinValue) +
        newMinValue;
    return convertedValue;
  }
}
