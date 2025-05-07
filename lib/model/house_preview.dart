class HousePreview {
  final int id;
  final String title;
  final String location;
  final double latitude;
  final double longitude;
  final int guests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final double price;
  final String currency;
  final List<String> pictures;

  HousePreview({
    required this.id,
    required this.title,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.guests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.price,
    required this.currency,
    required this.pictures,
  });

  factory HousePreview.fromJson(Map<String, dynamic> json) {
    return HousePreview(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      guests: json['guests'],
      bedrooms: json['bedrooms'],
      beds: json['beds'],
      bathrooms: json['bathrooms'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      pictures: List<String>.from(json['pictures']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'guests': guests,
      'bedrooms': bedrooms,
      'beds': beds,
      'bathrooms': bathrooms,
      'price': price,
      'currency': currency,
      'pictures': pictures,
    };
  }
}
