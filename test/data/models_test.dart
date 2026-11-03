import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/data/models/city.dart';
import 'package:weather_app/data/models/weather_report.dart';

import '../helpers/fakes.dart';

const _forecastJson = '''
{
  "current": {
    "time": "2026-11-03T10:00",
    "interval": 900,
    "temperature_2m": 12.3,
    "relative_humidity_2m": 71,
    "weather_code": 3,
    "wind_speed_10m": 14.8
  },
  "daily": {
    "time": ["2026-11-03", "2026-11-04"],
    "weather_code": [3, 61],
    "temperature_2m_max": [13.1, 11.0],
    "temperature_2m_min": [6.2, 5.5]
  }
}
''';

void main() {
  group('City', () {
    test('parses with optional fields missing', () {
      final city = City.fromJson({
        'name': 'Atlantis',
        'latitude': 1,
        'longitude': 2,
      });
      expect(city.country, isNull);
      expect(city.displayName, 'Atlantis');
    });

    test('displayName avoids repeating region equal to name', () {
      expect(berlinGermany.displayName, 'Berlin, Germany');
      expect(berlinUsa.displayName, 'Berlin, New Hampshire, United States');
    });

    test('cities are equal when coordinates match', () {
      expect(
        const City(name: 'A', latitude: 1, longitude: 2),
        const City(name: 'B', latitude: 1, longitude: 2),
      );
    });
  });

  group('WeatherReport', () {
    test('parses the Open-Meteo forecast response', () {
      final report = WeatherReport.fromApiJson(
        city: berlinGermany,
        json: jsonDecode(_forecastJson) as Map<String, dynamic>,
        fetchedAt: DateTime(2026, 11, 3, 10),
      );

      expect(report.current.temperatureC, 12.3);
      expect(report.current.humidity, 71);
      expect(report.current.windSpeedKmh, 14.8);
      expect(report.current.weatherCode, 3);
      expect(report.daily, hasLength(2));
      expect(report.daily[1].weatherCode, 61);
      expect(report.daily[1].date.day, 4);
      expect(report.daily[1].maxTemperatureC, 11.0);
      expect(report.daily[1].minTemperatureC, 5.5);
    });

    test('survives a JSON round trip (used by the cache)', () {
      final original = buildReport(berlinGermany);
      final restored = WeatherReport.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );

      expect(restored.city, original.city);
      expect(restored.current.temperatureC, original.current.temperatureC);
      expect(restored.daily.length, original.daily.length);
      expect(restored.daily.first.date, original.daily.first.date);
      expect(restored.fetchedAt, original.fetchedAt);
    });
  });
}
