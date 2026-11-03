import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../data/models/city.dart';

/// Chips for recently viewed cities. Renders nothing when there are none.
class RecentCities extends StatelessWidget {
  const RecentCities({
    super.key,
    required this.cities,
    required this.onSelect,
  });

  final List<City> cities;
  final ValueChanged<City> onSelect;

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          AppStrings.recentSearches,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final city in cities)
              ActionChip(
                label: Text(city.displayName),
                onPressed: () => onSelect(city),
              ),
          ],
        ),
      ],
    );
  }
}
