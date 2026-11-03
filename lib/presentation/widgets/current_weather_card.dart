import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/weather_code.dart';
import '../../data/models/weather_report.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.report,
    required this.useFahrenheit,
  });

  final WeatherReport report;
  final bool useFahrenheit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final current = report.current;
    final condition = conditionForCode(current.weatherCode);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, colors.tertiaryContainer],
          ),
        ),
        child: Column(
          children: [
            Text(
              report.city.displayName,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(condition.icon, style: const TextStyle(fontSize: 80)),
            Text(
              formatTemperature(
                current.temperatureC,
                useFahrenheit: useFahrenheit,
              ),
              style: theme.textTheme.displayLarge
                  ?.copyWith(fontWeight: FontWeight.w300),
            ),
            Text(condition.description, style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Metric(
                  icon: Icons.water_drop_outlined,
                  label: AppStrings.humidity,
                  value: formatHumidity(current.humidity),
                ),
                _Metric(
                  icon: Icons.air,
                  label: AppStrings.wind,
                  value: formatWindSpeed(current.windSpeedKmh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.lastUpdated(formatTimestamp(report.fetchedAt)),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}