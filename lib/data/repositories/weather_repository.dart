import '../../core/app_exception.dart';
import '../../core/constants.dart';
import '../../core/input_validator.dart';
import '../local/weather_local_data_source.dart';
import '../models/city.dart';
import '../models/weather_report.dart';
import '../services/weather_api_service.dart';

/// Single entry point for weather data. The view model only talks to this
/// class and never to the network or storage directly.
class WeatherRepository {
  WeatherRepository({
    required WeatherApiService apiService,
    required WeatherLocalDataSource localDataSource,
  })  : _api = apiService,
        _local = localDataSource;

  final WeatherApiService _api;
  final WeatherLocalDataSource _local;

  /// Throws [AppException] with [FailureType.invalidQuery] *before* any
  /// network call if the query is blank or has no letters.
  Future<List<City>> searchCities(String query) async {
    if (!isValidCityQuery(query)) {
      throw const AppException(FailureType.invalidQuery);
    }
    return _api.searchCities(normalizeCityQuery(query));
  }

  /// Downloads fresh weather and saves it as the offline copy.
  Future<WeatherReport> getWeather(City city) async {
    final report = await _api.fetchWeather(city);
    try {
      await _local.saveReport(report);
    } catch (_) {
      // Failing to cache must not hide data that was fetched successfully.
    }
    return report;
  }

  Future<WeatherReport?> loadCachedReport() => _local.loadReport();

  Future<List<City>> loadRecentCities() => _local.loadRecentCities();

  /// Puts [city] first in the history (no duplicates) and returns the list.
  Future<List<City>> addRecentCity(City city) async {
    final current = await _local.loadRecentCities();
    final updated = [
      city,
      ...current.where((c) => c != city),
    ].take(LimitConstants.recentCitiesLimit).toList();
    await _local.saveRecentCities(updated);
    return updated;
  }

  Future<bool> loadUseFahrenheit() => _local.loadUseFahrenheit();

  Future<void> saveUseFahrenheit(bool value) =>
      _local.saveUseFahrenheit(value);
}
