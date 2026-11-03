import 'constants.dart';

final RegExp _letterPattern = RegExp(r'\p{L}', unicode: true);
final RegExp _whitespacePattern = RegExp(r'\s+');

/// A valid query is non-empty after trimming, not absurdly long, and contains
/// at least one letter (so "   " and "!!!" never reach the API).
bool isValidCityQuery(String raw) {
  final query = raw.trim();
  return query.isNotEmpty &&
      query.length <= LimitConstants.maxQueryLength &&
      _letterPattern.hasMatch(query);
}

/// Trims and collapses repeated whitespace.
String normalizeCityQuery(String raw) =>
    raw.trim().replaceAll(_whitespacePattern, ' ');
