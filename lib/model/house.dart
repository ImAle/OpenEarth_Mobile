import 'user_info.dart';
import 'picture.dart';
import 'review.dart';

class House {
  final int id;
  final String title;
  final String description;
  final int guests;
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final double price;
  final String currency;
  final String location;
  final double latitude;
  final double longitude;
  final String category;
  final String status;
  final String creationDate;
  final List<Picture> pictures;
  final UserInfo owner;
  final List<Review> reviews;

  House({
    required this.id,
    required this.title,
    required this.description,
    required this.guests,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
    required this.price,
    required this.currency,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.status,
    required this.creationDate,
    required this.pictures,
    required this.owner,
    required this.reviews,
  });
}
