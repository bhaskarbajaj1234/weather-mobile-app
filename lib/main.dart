import 'package:flutter/material.dart';

import 'app.dart';
import 'data/local/weather_local_data_source.dart';
import 'data/repositories/weather_repository.dart';
import 'data/services/weather_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = WeatherRepository(
    apiService: WeatherApiService(),
    localDataSource: WeatherLocalDataSource(),
  );

  runApp(WeatherApp(repository: repository));
}
