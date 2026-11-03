import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/input_validator.dart';

void main() {
  group('isValidCityQuery', () {
    test('rejects empty and whitespace-only input', () {
      expect(isValidCityQuery(''), isFalse);
      expect(isValidCityQuery('    '), isFalse);
    });

    test('rejects input without any letter', () {
      expect(isValidCityQuery('!!!'), isFalse);
      expect(isValidCityQuery('123'), isFalse);
      expect(isValidCityQuery(' @#\$ '), isFalse);
    });

    test('accepts normal and non-latin names', () {
      expect(isValidCityQuery('Berlin'), isTrue);
      expect(isValidCityQuery('São Paulo'), isTrue);
      expect(isValidCityQuery('東京'), isTrue);
    });

    test('rejects very long input', () {
      expect(isValidCityQuery('a' * 101), isFalse);
    });
  });

  test('normalizeCityQuery trims and collapses spaces', () {
    expect(normalizeCityQuery('  New    York '), 'New York');
  });
}
