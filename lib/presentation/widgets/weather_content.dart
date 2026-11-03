import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../data/models/weather_report.dart';
import 'current_weather_card.dart';
import 'forecast_list.dart';
import 'stale_data_banner.dart';

/// Current weather + 5-day forecast, with pull-to-refresh.
class WeatherContent extends StatelessWidget {
  const WeatherContent({
    super.key,
    required this.report,
    required this.useFahrenheit,
    required this.isLoading,
    required this.staleReason,
    required this.onRefresh,
  });

  final WeatherReport report;
  final bool useFahrenheit;
  final bool isLoading;
  final String? staleReason;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final reason = staleReason;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (reason != null) StaleDataBanner(reason: reason, report: report),
          if (isLoading) const LinearProgressIndicator(),
          CurrentWeatherCard(report: report, useFahrenheit: useFahrenheit),
          const SizedBox(height: 16),
          Text(
            AppStrings.forecastTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ForecastList(days: report.daily, useFahrenheit: useFahrenheit),
        ],
      ),
    );
  }
}
