/// Forecast for a single day.
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemperatureC,
    required this.minTemperatureC,
  });

  final DateTime date;
  final int weatherCode;
  final double maxTemperatureC;
  final double minTemperatureC;

  /// Open-Meteo returns parallel arrays (one list per field). This turns
  /// them into a list of [DailyForecast] objects.
  static List<DailyForecast> listFromApi(Map<String, dynamic> daily) {
    final dates = (daily['time'] as List).cast<String>();
    final codes = daily['weather_code'] as List;
    final maxTemps = daily['temperature_2m_max'] as List;
    final minTemps = daily['temperature_2m_min'] as List;

    return List.generate(
      dates.length,
      (i) => DailyForecast(
        date: DateTime.parse(dates[i]),
        weatherCode: (codes[i] as num).toInt(),
        maxTemperatureC: (maxTemps[i] as num).toDouble(),
        minTemperatureC: (minTemps[i] as num).toDouble(),
      ),
    );
  }

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: DateTime.parse(json['date'] as String),
        weatherCode: (json['weather_code'] as num).toInt(),
        maxTemperatureC: (json['temperature_2m_max'] as num).toDouble(),
        minTemperatureC: (json['temperature_2m_min'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weather_code': weatherCode,
        'temperature_2m_max': maxTemperatureC,
        'temperature_2m_min': minTemperatureC,
      };
}
