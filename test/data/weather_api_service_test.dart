import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_app/core/app_exception.dart';
import 'package:weather_app/data/services/weather_api_service.dart';

import '../helpers/fakes.dart';

WeatherApiService _serviceReturning(String body, {int status = 200}) =>
    WeatherApiService(
      client: MockClient((_) async => http.Response(body, status)),
    );

Matcher _failsWith(FailureType type) => throwsA(
      isA<AppException>().having((e) => e.type, 'type', type),
    );

void main() {
  group('searchCities', () {
    test('returns an empty list when "results" is missing', () async {
      final service = _serviceReturning('{"generationtime_ms": 0.5}');
      expect(await service.searchCities('Nowhereville'), isEmpty);
    });

    test('parses several cities with the same name', () async {
      final service = _serviceReturning('''
      {"results": [
        {"id": 1, "name": "Berlin", "latitude": 52.52, "longitude": 13.41,
         "country": "Germany", "admin1": "Berlin"},
        {"id": 2, "name": "Berlin", "latitude": 44.47, "longitude": -71.19,
         "country": "United States", "admin1": "New Hampshire"}
      ]}''');

      final cities = await service.searchCities('Berlin');
      expect(cities, hasLength(2));
      expect(cities[1].country, 'United States');
    });

    test('sends the city name and result count', () async {
      late Uri requested;
      final service = WeatherApiService(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response('{}', 200);
        }),
      );

      await service.searchCities('Berlin');
      expect(requested.host, 'geocoding-api.open-meteo.com');
      expect(requested.queryParameters['name'], 'Berlin');
      expect(requested.queryParameters['count'], '5');
    });

    test('malformed items become a parsing error', () {
      final service = _serviceReturning('{"results": [{"name": "X"}]}');
      expect(service.searchCities('X'), _failsWith(FailureType.parsing));
    });

    test('non-JSON body becomes a parsing error', () {
      final service = _serviceReturning('<html>oops</html>');
      expect(service.searchCities('X'), _failsWith(FailureType.parsing));
    });
  });

  group('fetchWeather', () {
    test('sends coordinates and requests 5 days', () async {
      late Uri requested;
      final service = WeatherApiService(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response('{}', 200);
        }),
      );

      // The empty body fails to parse, but we only inspect the request.
      try {
        await service.fetchWeather(berlinGermany);
      } on AppException {
        // Expected: the body is not a valid forecast.
      }
      expect(requested.host, 'api.open-meteo.com');
      expect(requested.queryParameters['latitude'], '52.52');
      expect(requested.queryParameters['longitude'], '13.41');
      expect(requested.queryParameters['forecast_days'], '5');
      expect(requested.queryParameters['timezone'], 'auto');
    });

    test('server errors are reported as serverError', () {
      final service = _serviceReturning('boom', status: 500);
      expect(
        service.fetchWeather(berlinGermany),
        _failsWith(FailureType.serverError),
      );
    });

    test('socket errors are reported as noInternet', () {
      final service = WeatherApiService(
        client: MockClient((_) async => throw const SocketException('offline')),
      );
      expect(
        service.fetchWeather(berlinGermany),
        _failsWith(FailureType.noInternet),
      );
    });
  });
}
