import 'package:flutter/foundation.dart';

import '../../core/app_exception.dart';
import '../../core/input_validator.dart';
import '../../data/models/city.dart';
import '../../data/models/weather_report.dart';
import '../../data/repositories/weather_repository.dart';

/// Holds all screen state and decides what the UI should show.
///
/// The UI picks what to display from these fields, in this order:
///   error -> cityOptions -> report -> isLoading -> empty state
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._repository);

  final WeatherRepository _repository;

  WeatherReport? _report;
  AppException? _error;
  String? _staleReason;
  List<City> _cityOptions = const [];
  List<City> _recentCities = const [];
  bool _isLoading = false;
  bool _useFahrenheit = false;
  bool _disposed = false;

  /// Incremented for every new request. A response is only applied if its id
  /// still matches, so an older, slower request can never overwrite a newer one.
  int _requestId = 0;

  Future<void> Function()? _retryAction;

  WeatherReport? get report => _report;
  AppException? get error => _error;

  /// Non-null when the shown report could not be refreshed (offline, API
  /// down). The UI shows it together with the "may be outdated" notice.
  String? get staleReason => _staleReason;
  List<City> get cityOptions => _cityOptions;
  List<City> get recentCities => _recentCities;
  bool get isLoading => _isLoading;
  bool get useFahrenheit => _useFahrenheit;

  /// Loads saved settings and the cached report, then tries to refresh it.
  Future<void> initialize() async {
    try {
      _useFahrenheit = await _repository.loadUseFahrenheit();
      _recentCities = await _repository.loadRecentCities();
    } catch (_) {
      // Settings are a convenience; fall back to defaults.
    }

    final cached = await _repository.loadCachedReport();
    if (cached == null) {
      _notify();
      return;
    }
    _report = cached;
    _notify();
    await _loadWeather(cached.city, requestId: ++_requestId);
  }

  Future<void> search(String query) async {
    final requestId = ++_requestId;

    if (!isValidCityQuery(query)) {
      _isLoading = false;
      _cityOptions = const [];
      _error = const AppException(FailureType.invalidQuery);
      _notify();
      return;
    }

    _retryAction = () => search(query);
    _isLoading = true;
    _error = null;
    _cityOptions = const [];
    _notify();

    await _guard(requestId, () async {
      final cities = await _repository.searchCities(query);
      if (_isOutdated(requestId)) return;

      if (cities.isEmpty) {
        throw const AppException(FailureType.cityNotFound);
      }
      if (cities.length == 1) {
        await _loadWeather(cities.first, requestId: requestId);
        return;
      }
      // Several cities share this name: let the user choose.
      _isLoading = false;
      _cityOptions = cities;
      _notify();
    });
  }

  Future<void> selectCity(City city) =>
      _loadWeather(city, requestId: ++_requestId);

  /// Pull-to-refresh for the city currently shown.
  Future<void> refresh() async {
    final current = _report;
    if (current == null) return;
    await _loadWeather(
      current.city,
      requestId: ++_requestId,
      showProgress: false,
    );
  }

  Future<void> retry() async {
    await _retryAction?.call();
  }

  Future<void> toggleUnit() async {
    _useFahrenheit = !_useFahrenheit;
    _notify();
    try {
      await _repository.saveUseFahrenheit(_useFahrenheit);
    } catch (_) {
      // Not being able to save the preference is not worth an error.
    }
  }

  Future<void> _loadWeather(
    City city, {
    required int requestId,
    bool showProgress = true,
  }) async {
    _retryAction = () => selectCity(city);
    if (showProgress) _isLoading = true;
    _error = null;
    _cityOptions = const [];
    _notify();

    await _guard(requestId, () async {
      final report = await _repository.getWeather(city);
      if (_isOutdated(requestId)) return;

      _report = report;
      _staleReason = null;
      _isLoading = false;
      _notify();

      await _rememberCity(city);
    });
  }

  Future<void> _rememberCity(City city) async {
    try {
      _recentCities = await _repository.addRecentCity(city);
      _notify();
    } catch (_) {
      // History is optional.
    }
  }

  /// Runs [action] and turns any failure into UI state. Failures that belong
  /// to an outdated request are ignored.
  Future<void> _guard(int requestId, Future<void> Function() action) async {
    try {
      await action();
    } on AppException catch (e) {
      if (!_isOutdated(requestId)) _handleFailure(e);
    } catch (_) {
      if (!_isOutdated(requestId)) {
        _handleFailure(const AppException(FailureType.unknown));
      }
    }
  }

  void _handleFailure(AppException e) {
    _isLoading = false;
    _cityOptions = const [];
    if (_report != null && e.canFallBackToCache) {
      // Offline or API problem: keep showing the saved data with a notice.
      _staleReason = e.message;
      _error = null;
    } else {
      _staleReason = null;
      _error = e;
    }
    _notify();
  }

  bool _isOutdated(int requestId) => requestId != _requestId;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
