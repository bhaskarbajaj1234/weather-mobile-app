import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/app_exception.dart';
import '../../core/constants.dart';
import '../models/city.dart';
import '../models/weather_report.dart';

/// Talks to the Open-Meteo geocoding and forecast endpoints.
/// All failures are thrown as [AppException].
class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Step 1: city name -> list of matching cities (empty if none match).
  Future<List<City>> searchCities(String name) async {
    final uri = Uri.https(
      ApiConstants.geocodingHost,
      ApiConstants.geocodingPath,
      {
        'name': name,
        'count': ApiConstants.geocodingResultCount.toString(),
        'language': 'en',
        'format': 'json',
      },
    );
    final json = await _getJson(uri);

    // When nothing matches, Open-Meteo omits the "results" field entirely.
    final results = json['results'];
    if (results == null) return const [];

    return _parse(
      () => (results as List)
          .map((item) => City.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Step 2: coordinates -> current weather and daily forecast.
  Future<WeatherReport> fetchWeather(City city) async {
    final uri = Uri.https(
      ApiConstants.forecastHost,
      ApiConstants.forecastPath,
      {
        'latitude': city.latitude.toString(),
        'longitude': city.longitude.toString(),
        'current': ApiConstants.currentFields,
        'daily': ApiConstants.dailyFields,
        'forecast_days': ApiConstants.forecastDays.toString(),
        'timezone': ApiConstants.timezone,
      },
    );
    final json = await _getJson(uri);

    return _parse(
      () => WeatherReport.fromApiJson(
        city: city,
        json: json,
        fetchedAt: DateTime.now(),
      ),
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response =
          await _client.get(uri).timeout(ApiConstants.requestTimeout);
      if (response.statusCode != 200) {
        throw const AppException(FailureType.serverError);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const AppException(FailureType.parsing);
      }
      return decoded;
    } on TimeoutException {
      throw const AppException(FailureType.timeout);
    } on SocketException {
      throw const AppException(FailureType.noInternet);
    } on http.ClientException {
      throw const AppException(FailureType.noInternet);
    } on FormatException {
      throw const AppException(FailureType.parsing);
    }
  }

  /// Runs [parser] and converts any parsing problem (missing field, wrong
  /// type, bad date) into a parsing [AppException].
  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } catch (_) {
      throw const AppException(FailureType.parsing);
    }
  }
}
