import 'package:flutter/material.dart';

import '../../core/app_exception.dart';
import '../../core/constants.dart';
import '../../data/models/city.dart';
import 'recent_cities.dart';

/// Shown before the first search (and when nothing is cached).
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.recentCities,
    required this.onSelectRecent,
  });

  final List<City> recentCities;
  final ValueChanged<City> onSelectRecent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _CenteredScroll(
      children: [
        const Text('🌍', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(
          AppStrings.emptyTitle,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.emptyHint,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        RecentCities(cities: recentCities, onSelect: onSelectRecent),
      ],
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(AppStrings.loading),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    required this.recentCities,
    required this.onSelectRecent,
  });

  final AppException error;
  final VoidCallback onRetry;
  final List<City> recentCities;
  final ValueChanged<City> onSelectRecent;

  IconData get _icon => switch (error.type) {
        FailureType.noInternet => Icons.wifi_off,
        FailureType.timeout => Icons.hourglass_empty,
        FailureType.cityNotFound => Icons.location_off,
        FailureType.invalidQuery => Icons.edit_off,
        _ => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _CenteredScroll(
      children: [
        Icon(_icon, size: 56, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          error.message,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (error.canRetry) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.retry),
          ),
        ],
        RecentCities(cities: recentCities, onSelect: onSelectRecent),
      ],
    );
  }
}

/// Centers content but still scrolls, so nothing overflows in landscape or
/// with large font sizes.
class _CenteredScroll extends StatelessWidget {
  const _CenteredScroll({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
