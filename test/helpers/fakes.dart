import 'package:weather_app/core/app_exception.dart';
import 'package:weather_app/data/models/city.dart';
import 'package:weather_app/data/models/current_weather.dart';
import 'package:weather_app/data/models/daily_forecast.dart';
import 'package:weather_app/data/models/weather_report.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';

const berlinGermany = City(
  name: 'Berlin',
  latitude: 52.52,
  longitude: 13.41,
  country: 'Germany',
  admin1: 'Berlin',
);

const berlinUsa = City(
  name: 'Berlin',
  latitude: 44.47,
  longitude: -71.19,
  country: 'United States',
  admin1: 'New Hampshire',
);

const paris = City(
  name: 'Paris',
  latitude: 48.85,
  longitude: 2.35,
  country: 'France',
  admin1: 'Île-de-France',
);

WeatherReport buildReport(City city, {DateTime? fetchedAt}) => WeatherReport(
      city: city,
      current: const CurrentWeather(
        temperatureC: 12.3,
        humidity: 71,
        windSpeedKmh: 14.8,
        weatherCode: 3,
      ),
      daily: List.generate(
        5,
        (i) => DailyForecast(
          date: DateTime(2026, 11, 3 + i),
          weatherCode: 61,
          maxTemperatureC: 13.0 + i,
          minTemperatureC: 5.0 + i,
        ),
      ),
      fetchedAt: fetchedAt ?? DateTime(2026, 11, 3, 10, 15),
    );

/// In-memory stand-in for [WeatherRepository] so the view model and screens
/// can be tested without network or storage.
class FakeWeatherRepository implements WeatherRepository {
  List<City> cities = [];
  Future<List<City>> Function(String query)? onSearch;
  AppException? searchError;
  AppException? weatherError;
  WeatherReport? cachedReport;
  List<City> recent = [];
  bool useFahrenheit = false;

  int searchCalls = 0;
  int weatherCalls = 0;

  @override
  Future<List<City>> searchCities(String query) async {
    searchCalls++;
    final handler = onSearch;
    if (handler != null) return handler(query);
    final error = searchError;
    if (error != null) throw error;
    return cities;
  }

  @override
  Future<WeatherReport> getWeather(City city) async {
    weatherCalls++;
    final error = weatherError;
    if (error != null) throw error;
    return buildReport(city);
  }

  @override
  Future<WeatherReport?> loadCachedReport() async => cachedReport;

  @override
  Future<List<City>> loadRecentCities() async => recent;

  @override
  Future<List<City>> addRecentCity(City city) async {
    recent = [city, ...recent.where((c) => c != city)];
    return recent;
  }

  @override
  Future<bool> loadUseFahrenheit() async => useFahrenheit;

  @override
  Future<void> saveUseFahrenheit(bool value) async {
    useFahrenheit = value;
  }
}
