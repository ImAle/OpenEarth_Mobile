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
}
