import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../data/models/city.dart';

/// Lets the user choose between cities that share the same name.
class CityPicker extends StatelessWidget {
  const CityPicker({super.key, required this.cities, required this.onSelect});

  final List<City> cities;
  final ValueChanged<City> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppStrings.chooseCity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final city in cities)
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(city.name),
              subtitle: city.subtitle.isEmpty ? null : Text(city.subtitle),
              onTap: () => onSelect(city),
            ),
          ),
      ],
    );
  }
}
