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

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      guests: json['guests'],
      bedrooms: json['bedrooms'],
      beds: json['beds'],
      bathrooms: json['bathrooms'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      location: json['location'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: json['category'],
      status: json['status'],
      creationDate: json['creationDate'],
      pictures: (json['pictures'] as List).map((e) => Picture.fromJson(e)).toList(),
      owner: UserInfo.fromJson(json['owner']),
      reviews: (json['reviews'] as List).map((e) => Review.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'guests': guests,
      'bedrooms': bedrooms,
      'beds': beds,
      'bathrooms': bathrooms,
      'price': price,
      'currency': currency,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'status': status,
      'creationDate': creationDate,
      'pictures': pictures.map((e) => e.toJson()).toList(),
      'owner': owner.toJson(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }
}
