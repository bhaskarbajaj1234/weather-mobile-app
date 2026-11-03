/// Weather right now. Temperature is always stored in Celsius and wind in
/// km/h; conversion for display happens in the presentation layer.
class CurrentWeather {
  const CurrentWeather({
    required this.temperatureC,
    required this.humidity,
    required this.windSpeedKmh,
    required this.weatherCode,
  });

  final double temperatureC;
  final int humidity;
  final double windSpeedKmh;
  final int weatherCode;

  // The same keys are used for the API response and for the local cache.
  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        temperatureC: (json['temperature_2m'] as num).toDouble(),
        humidity: (json['relative_humidity_2m'] as num).round(),
        windSpeedKmh: (json['wind_speed_10m'] as num).toDouble(),
        weatherCode: (json['weather_code'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'temperature_2m': temperatureC,
        'relative_humidity_2m': humidity,
        'wind_speed_10m': windSpeedKmh,
        'weather_code': weatherCode,
      };
}
