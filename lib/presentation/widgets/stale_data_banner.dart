import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../data/models/weather_report.dart';

/// Tells the user why the data could not be refreshed and that the weather
/// shown comes from the local cache.
class StaleDataBanner extends StatelessWidget {
  const StaleDataBanner({
    super.key,
    required this.reason,
    required this.report,
  });

  final String reason;
  final WeatherReport report;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$reason\n'
                '${AppStrings.savedDataNotice(report.city.name, formatTimestamp(report.fetchedAt))}',
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
