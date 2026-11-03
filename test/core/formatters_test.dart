import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/formatters.dart';

void main() {
  test('formatTemperature rounds and uses the right unit', () {
    expect(formatTemperature(21.6, useFahrenheit: false), '22°C');
    expect(formatTemperature(0, useFahrenheit: true), '32°F');
  });

  test('humidity and wind include units', () {
    expect(formatHumidity(71), '71%');
    expect(formatWindSpeed(14.8), '15 km/h');
  });

  test('formatForecastDate labels the first row as Today', () {
    expect(formatForecastDate(DateTime(2026, 11, 3), isToday: true), 'Today');
    // 4 November 2026 is a Wednesday.
    expect(
      formatForecastDate(DateTime(2026, 11, 4), isToday: false),
      'Wed, 4 Nov',
    );
  });

  test('formatTimestamp pads minutes and hours', () {
    expect(formatTimestamp(DateTime(2026, 11, 3, 9, 5)), '3 Nov, 09:05');
  });
}
