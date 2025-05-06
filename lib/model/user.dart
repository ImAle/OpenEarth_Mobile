import 'house_preview.dart';
import 'rent.dart';
import 'review.dart';

class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool enabled;
  final String picture;
  final List<HousePreview> houses;
  final List<Rent> rents;
  final List<Review> reviews;
  final int creationDate;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.enabled,
    required this.picture,
    required this.houses,
    required this.rents,
    required this.reviews,
    required this.creationDate,
  });
}
