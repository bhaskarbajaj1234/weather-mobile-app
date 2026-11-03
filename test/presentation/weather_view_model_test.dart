import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/app_exception.dart';
import 'package:weather_app/core/constants.dart';
import 'package:weather_app/data/models/city.dart';
import 'package:weather_app/presentation/viewmodels/weather_view_model.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeWeatherRepository repository;
  late WeatherViewModel viewModel;

  setUp(() {
    repository = FakeWeatherRepository();
    viewModel = WeatherViewModel(repository);
  });

  tearDown(() => viewModel.dispose());

  test('starts empty when nothing is cached', () async {
    await viewModel.initialize();

    expect(viewModel.report, isNull);
    expect(viewModel.error, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('blank search shows an error without calling the API', () async {
    await viewModel.search('   ');

    expect(repository.searchCalls, 0);
    expect(viewModel.error?.type, FailureType.invalidQuery);
  });

  test('unknown city shows a not-found error', () async {
    repository.cities = [];
    await viewModel.search('Nowhereville');

    expect(viewModel.error?.type, FailureType.cityNotFound);
    expect(viewModel.error?.canRetry, isFalse);
    expect(viewModel.isLoading, isFalse);
  });

  test('a single match loads the weather and saves it to history', () async {
    repository.cities = [berlinGermany];
    await viewModel.search('Berlin');

    expect(viewModel.report?.city, berlinGermany);
    expect(viewModel.error, isNull);
    expect(viewModel.staleReason, isNull);
    expect(viewModel.recentCities, [berlinGermany]);
  });

  test('several matches ask the user to choose', () async {
    repository.cities = [berlinGermany, berlinUsa];
    await viewModel.search('Berlin');

    expect(viewModel.cityOptions, hasLength(2));
    expect(viewModel.report, isNull);

    await viewModel.selectCity(berlinUsa);

    expect(viewModel.cityOptions, isEmpty);
    expect(viewModel.report?.city, berlinUsa);
  });

  test('offline with no cache shows a no-internet error', () async {
    repository.cities = [berlinGermany];
    repository.weatherError = const AppException(FailureType.noInternet);
    await viewModel.search('Berlin');

    expect(viewModel.error?.type, FailureType.noInternet);
    expect(viewModel.report, isNull);
  });

  test('offline with cache keeps showing saved data with a notice', () async {
    repository.cachedReport = buildReport(berlinGermany);
    repository.weatherError = const AppException(FailureType.noInternet);

    await viewModel.initialize();

    expect(viewModel.report?.city, berlinGermany);
    expect(viewModel.error, isNull);
    expect(viewModel.staleReason, AppStrings.errorNoInternet);
    expect(viewModel.isLoading, isFalse);
  });

  test('online restart refreshes the cached report', () async {
    repository.cachedReport = buildReport(berlinGermany);

    await viewModel.initialize();

    expect(repository.weatherCalls, 1);
    expect(viewModel.staleReason, isNull);
  });

  test('refresh failure keeps the old data and flags it as stale', () async {
    repository.cities = [berlinGermany];
    await viewModel.search('Berlin');

    repository.weatherError = const AppException(FailureType.timeout);
    await viewModel.refresh();

    expect(viewModel.report?.city, berlinGermany);
    expect(viewModel.staleReason, AppStrings.errorTimeout);
  });

  test('retry repeats the failed request', () async {
    repository.cities = [berlinGermany];
    repository.weatherError = const AppException(FailureType.serverError);
    await viewModel.search('Berlin');
    expect(viewModel.error?.type, FailureType.serverError);

    repository.weatherError = null;
    await viewModel.retry();

    expect(viewModel.error, isNull);
    expect(viewModel.report?.city, berlinGermany);
  });

  test('an older slow search cannot overwrite a newer one', () async {
    final slowResult = Completer<List<City>>();
    repository.onSearch = (query) =>
        query == 'slow' ? slowResult.future : Future.value([berlinGermany]);

    final slowSearch = viewModel.search('slow');
    await viewModel.search('fast');
    expect(viewModel.report?.city, berlinGermany);

    slowResult.complete([paris]);
    await slowSearch;

    expect(viewModel.report?.city, berlinGermany);
    expect(viewModel.cityOptions, isEmpty);
    expect(viewModel.isLoading, isFalse);
  });

  test('toggleUnit flips and persists the preference', () async {
    await viewModel.toggleUnit();

    expect(viewModel.useFahrenheit, isTrue);
    expect(repository.useFahrenheit, isTrue);
  });
}
