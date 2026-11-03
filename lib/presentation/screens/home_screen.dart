import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../viewmodels/weather_view_model.dart';
import '../widgets/city_picker.dart';
import '../widgets/search_field.dart';
import '../widgets/state_views.dart';
import '../widgets/weather_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          TextButton(
            onPressed: vm.toggleUnit,
            child: Text(
              vm.useFahrenheit
                  ? AppStrings.showCelsius
                  : AppStrings.showFahrenheit,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchField(onSearch: vm.search),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(WeatherViewModel vm) {
    final error = vm.error;
    if (error != null) {
      return ErrorView(
        error: error,
        onRetry: vm.retry,
        recentCities: vm.recentCities,
        onSelectRecent: vm.selectCity,
      );
    }
    if (vm.cityOptions.isNotEmpty) {
      return CityPicker(cities: vm.cityOptions, onSelect: vm.selectCity);
    }
    final report = vm.report;
    if (report != null) {
      return WeatherContent(
        report: report,
        useFahrenheit: vm.useFahrenheit,
        isLoading: vm.isLoading,
        staleReason: vm.staleReason,
        onRefresh: vm.refresh,
      );
    }
    if (vm.isLoading) return const LoadingView();
    return EmptyView(
      recentCities: vm.recentCities,
      onSelectRecent: vm.selectCity,
    );
  }
}
