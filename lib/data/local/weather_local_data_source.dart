import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/city.dart';
import '../models/weather_report.dart';

/// Persists the last successful report, recent searches and unit preference
/// with SharedPreferences. Reads never throw: corrupted data is ignored so a
/// bad cache can never crash the app.
class WeatherLocalDataSource {
  Future<void> saveReport(WeatherReport report) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.cachedReport,
      jsonEncode(report.toJson()),
    );
  }

  Future<WeatherReport?> loadReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(StorageKeys.cachedReport);
      if (raw == null) return null;
      return WeatherReport.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRecentCities(List<City> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.recentCities,
      jsonEncode(cities.map((c) => c.toJson()).toList()),
    );
  }

  Future<List<City>> loadRecentCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(StorageKeys.recentCities);
      if (raw == null) return const [];
      return (jsonDecode(raw) as List)
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveUseFahrenheit(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.useFahrenheit, value);
  }

  Future<bool> loadUseFahrenheit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(StorageKeys.useFahrenheit) ?? false;
    } catch (_) {
      return false;
    }
  }
}
