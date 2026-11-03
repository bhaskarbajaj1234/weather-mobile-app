import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/weather_code.dart';

void main() {
  group('conditionForCode', () {
    test('maps well-known codes', () {
      expect(conditionForCode(0).description, 'Clear sky');
      expect(conditionForCode(3).description, 'Overcast');
      expect(conditionForCode(95).description, 'Thunderstorm');
    });

    test('handles every code listed in the assignment', () {
      const codes = [
        0, 1, 2, 3, 45, 48, 51, 53, 55, 61, 63, 65,
        71, 73, 75, 80, 81, 82, 95, 96, 99,
      ];
      for (final code in codes) {
        expect(conditionForCode(code).description, isNot('Unknown'),
            reason: 'code $code should be mapped');
        expect(conditionForCode(code).icon, isNotEmpty);
      }
    });

    test('falls back to Unknown for unhandled codes', () {
      expect(conditionForCode(1234).description, 'Unknown');
      expect(conditionForCode(-1).description, 'Unknown');
    });
  });
}
