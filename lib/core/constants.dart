/// Central place for URLs, keys, limits and user-facing text so that no
/// "magic" values are scattered through the code base.
class ApiConstants {
  const ApiConstants._();

  static const String geocodingHost = 'geocoding-api.open-meteo.com';
  static const String geocodingPath = '/v1/search';
  static const String forecastHost = 'api.open-meteo.com';
  static const String forecastPath = '/v1/forecast';

  static const int geocodingResultCount = 5;
  static const int forecastDays = 5;
  static const String timezone = 'auto';

  static const String currentFields =
      'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m';
  static const String dailyFields =
      'weather_code,temperature_2m_max,temperature_2m_min';

  /// Requests slower than this are treated as failed.
  static const Duration requestTimeout = Duration(seconds: 10);
}

class StorageKeys {
  const StorageKeys._();

  static const String cachedReport = 'cached_weather_report';
  static const String recentCities = 'recent_cities';
  static const String useFahrenheit = 'use_fahrenheit';
}

class LimitConstants {
  const LimitConstants._();

  static const int recentCitiesLimit = 5;
  static const int maxQueryLength = 100;
}

class AppStrings {
  const AppStrings._();

  static const String appTitle = 'Weather';
  static const String searchHint = 'Search for a city';
  static const String searchTooltip = 'Search';

  static const String emptyTitle = 'Search for a city to see its weather';
  static const String emptyHint = 'Try "Berlin" or "Tokyo".';
  static const String loading = 'Loading weather…';
  static const String retry = 'Try again';
  static const String chooseCity = 'Several cities match. Choose one:';
  static const String recentSearches = 'Recent searches';

  static const String forecastTitle = '5-day forecast';
  static const String humidity = 'Humidity';
  static const String wind = 'Wind';
  static const String today = 'Today';
  static const String unknownCondition = 'Unknown';

  static const String celsius = '°C';
  static const String fahrenheit = '°F';
  static const String percent = '%';
  static const String kmh = 'km/h';
  static const String showFahrenheit = 'Show °F';
  static const String showCelsius = 'Show °C';

  // Error messages (kept friendly and free of technical detail).
  static const String errorInvalidQuery =
      'Please enter a valid city name (it must contain letters).';
  static const String errorCityNotFound =
      "We couldn't find that city. Check the spelling and try again.";
  static const String errorNoInternet =
      'No internet connection. Check your connection and try again.';
  static const String errorTimeout =
      'The request took too long. Please try again.';
  static const String errorServer =
      'The weather service is having problems. Please try again later.';
  static const String errorParsing =
      'We received unexpected data from the weather service.';
  static const String errorUnknown = 'Something went wrong. Please try again.';

  static String lastUpdated(String when) => 'Last updated: $when';

  static String savedDataNotice(String city, String updated) =>
      'Showing saved weather for $city (updated $updated). '
      'It may be outdated.';
}
