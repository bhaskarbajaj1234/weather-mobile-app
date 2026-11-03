import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/app.dart';
import 'package:weather_app/core/constants.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('shows the empty state on first launch', (tester) async {
    await tester.pumpWidget(WeatherApp(repository: FakeWeatherRepository()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.emptyTitle), findsOneWidget);
  });

  testWidgets('blank search shows a message and makes no API call',
      (tester) async {
    final repository = FakeWeatherRepository();
    await tester.pumpWidget(WeatherApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(find.text(AppStrings.errorInvalidQuery), findsOneWidget);
    expect(repository.searchCalls, 0);
  });

  testWidgets('shows current weather and the 5-day forecast', (tester) async {
    final repository = FakeWeatherRepository()..cities = [berlinGermany];
    await tester.pumpWidget(WeatherApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Berlin');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Berlin, Germany'), findsOneWidget);
    expect(find.text('12°C'), findsOneWidget);
    expect(find.text(AppStrings.forecastTitle), findsOneWidget);
    expect(find.text(AppStrings.today), findsOneWidget);
  });
}
