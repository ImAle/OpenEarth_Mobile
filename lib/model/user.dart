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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role'],
      enabled: json['enabled'],
      picture: json['picture'],
      houses: (json['houses'] as List).map((e) => HousePreview.fromJson(e)).toList(),
      rents: (json['rents'] as List).map((e) => Rent.fromJson(e)).toList(),
      reviews: (json['reviews'] as List).map((e) => Review.fromJson(e)).toList(),
      creationDate: json['creationDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'enabled': enabled,
      'picture': picture,
      'houses': houses.map((e) => e.toJson()).toList(),
      'rents': rents.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'creationDate': creationDate,
    };
  }
}
