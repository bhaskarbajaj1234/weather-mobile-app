import 'city.dart';
import 'current_weather.dart';
import 'daily_forecast.dart';

/// Everything shown on the weather screen for one city. This is also the
/// object that is saved to the local cache.
class WeatherReport {
  const WeatherReport({
    required this.city,
    required this.current,
    required this.daily,
    required this.fetchedAt,
  });

  final City city;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  /// When the data was downloaded (used for the "last updated" text).
  final DateTime fetchedAt;

  /// Builds a report from the raw forecast API response.
  factory WeatherReport.fromApiJson({
    required City city,
    required Map<String, dynamic> json,
    required DateTime fetchedAt,
  }) =>
      WeatherReport(
        city: city,
        current:
            CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
        daily: DailyForecast.listFromApi(json['daily'] as Map<String, dynamic>),
        fetchedAt: fetchedAt,
      );

  /// Builds a report from the locally cached representation.
  factory WeatherReport.fromJson(Map<String, dynamic> json) => WeatherReport(
        city: City.fromJson(json['city'] as Map<String, dynamic>),
        current:
            CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
        daily: (json['daily'] as List)
            .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
        fetchedAt: DateTime.parse(json['fetched_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'city': city.toJson(),
        'current': current.toJson(),
        'daily': daily.map((d) => d.toJson()).toList(),
        'fetched_at': fetchedAt.toIso8601String(),
      };
}
