import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/weather_code.dart';
import '../../data/models/daily_forecast.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({
    super.key,
    required this.days,
    required this.useFahrenheit,
  });

  final List<DailyForecast> days;
  final bool useFahrenheit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < days.length; i++)
            _ForecastRow(
              day: days[i],
              isToday: i == 0,
              useFahrenheit: useFahrenheit,
            ),
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({
    required this.day,
    required this.isToday,
    required this.useFahrenheit,
  });

  final DailyForecast day;
  final bool isToday;
  final bool useFahrenheit;

  @override
  Widget build(BuildContext context) {
    final condition = conditionForCode(day.weatherCode);
    final low = formatTemperature(
      day.minTemperatureC,
      useFahrenheit: useFahrenheit,
    );
    final high = formatTemperature(
      day.maxTemperatureC,
      useFahrenheit: useFahrenheit,
    );

    return ListTile(
      leading: Text(condition.icon, style: const TextStyle(fontSize: 28)),
      title: Text(formatForecastDate(day.date, isToday: isToday)),
      subtitle: Text(condition.description),
            trailing: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$low  ',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
            TextSpan(
              text: high,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
