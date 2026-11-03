/// A place returned by the Open-Meteo geocoding endpoint.
class City {
  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? country;

  /// State or region, e.g. "New Hampshire".
  final String? admin1;

  factory City.fromJson(Map<String, dynamic> json) => City(
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        country: json['country'] as String?,
        admin1: json['admin1'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
      };

  /// Region and country, used to tell same-named cities apart.
  String get subtitle {
    final region = admin1;
    final nation = country;
    final parts = <String>[
      if (region != null && region.isNotEmpty && region != name) region,
      if (nation != null && nation.isNotEmpty) nation,
    ];
    return parts.join(', ');
  }

  String get displayName => subtitle.isEmpty ? name : '$name, $subtitle';

  @override
  bool operator ==(Object other) =>
      other is City &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
