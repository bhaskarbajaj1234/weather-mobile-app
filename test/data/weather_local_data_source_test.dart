import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/constants.dart';
import 'package:weather_app/data/local/weather_local_data_source.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('returns null when nothing is cached', () async {
    expect(await WeatherLocalDataSource().loadReport(), isNull);
  });

  test('saves and restores the last report', () async {
    final local = WeatherLocalDataSource();
    await local.saveReport(buildReport(berlinGermany));

    final restored = await local.loadReport();
    expect(restored, isNotNull);
    expect(restored!.city, berlinGermany);
    expect(restored.daily, hasLength(5));
  });

  test('corrupted cache is ignored instead of crashing', () async {
    SharedPreferences.setMockInitialValues(
      {StorageKeys.cachedReport: 'not valid json'},
    );
    expect(await WeatherLocalDataSource().loadReport(), isNull);
  });

  test('saves and restores recent cities and unit preference', () async {
    final local = WeatherLocalDataSource();
    await local.saveRecentCities([paris, berlinGermany]);
    await local.saveUseFahrenheit(true);

    expect(await local.loadRecentCities(), [paris, berlinGermany]);
    expect(await local.loadUseFahrenheit(), isTrue);
  });
}
