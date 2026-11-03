import 'constants.dart';

const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

double celsiusToFahrenheit(double celsius) => celsius * 9 / 5 + 32;

String formatTemperature(double celsius, {required bool useFahrenheit}) {
  final value = useFahrenheit ? celsiusToFahrenheit(celsius) : celsius;
  final unit = useFahrenheit ? AppStrings.fahrenheit : AppStrings.celsius;
  return '${value.round()}$unit';
}

String formatHumidity(int percent) => '$percent${AppStrings.percent}';

String formatWindSpeed(double kmh) => '${kmh.round()} ${AppStrings.kmh}';

/// The first forecast row is "today" in the city's own timezone (the API is
/// called with timezone=auto), so it is labelled by position, not by comparing
/// with the device clock.
String formatForecastDate(DateTime date, {required bool isToday}) {
  if (isToday) return AppStrings.today;
  return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';
}

String formatTimestamp(DateTime time) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${time.day} ${_months[time.month - 1]}, '
      '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
}
