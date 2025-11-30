/// Represents the days of the week with associated numeric values.
///
/// Each day has a numeric value from 1 (Monday) to 7 (Sunday).
enum DayOfWeek {

  monday(1),

  tuesday(2),

  wednesday(3),

  thursday(4),

  friday(5),

  saturday(6),

  sunday(7);

  final int value;

  const DayOfWeek(this.value);

  /// Creates a DayOfWeek from a numeric value.
  factory DayOfWeek.fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
}
