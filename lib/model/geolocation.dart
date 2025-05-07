class Geolocation {
  final String latitude;
  final String longitude;
  final String location;

  Geolocation({
    required this.latitude,
    required this.longitude,
    required this.location,
  });

  factory Geolocation.fromJson(Map<String, dynamic> json) {
    return Geolocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
    };
  }
}
