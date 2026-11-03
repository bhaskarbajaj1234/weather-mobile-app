import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'data/repositories/weather_repository.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/viewmodels/weather_view_model.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key, required this.repository});

  final WeatherRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // The view model lives above the screen, so rotation never loses state.
      create: (_) => WeatherViewModel(repository)..initialize(),
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        ),
      );
}
