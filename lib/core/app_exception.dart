import 'constants.dart';

enum FailureType {
  invalidQuery,
  cityNotFound,
  noInternet,
  timeout,
  serverError,
  parsing,
  unknown,
}

/// The only exception type the UI layer has to know about. Every network,
/// parsing or storage problem is converted into one of these.
class AppException implements Exception {
  const AppException(this.type);

  final FailureType type;

  /// A short, user-friendly message.
  String get message => switch (type) {
        FailureType.invalidQuery => AppStrings.errorInvalidQuery,
        FailureType.cityNotFound => AppStrings.errorCityNotFound,
        FailureType.noInternet => AppStrings.errorNoInternet,
        FailureType.timeout => AppStrings.errorTimeout,
        FailureType.serverError => AppStrings.errorServer,
        FailureType.parsing => AppStrings.errorParsing,
        FailureType.unknown => AppStrings.errorUnknown,
      };

  /// If true, previously saved data may still be shown (with a notice)
  /// instead of replacing the screen with an error. Bad input and unknown
  /// cities are the user's problem, so they always show an error.
  bool get canFallBackToCache =>
      type != FailureType.invalidQuery && type != FailureType.cityNotFound;

  /// Retrying the same request makes no sense for bad input.
  bool get canRetry =>
      type != FailureType.invalidQuery && type != FailureType.cityNotFound;

  @override
  String toString() => 'AppException($type)';
}
