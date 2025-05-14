class UserInfo {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String picture;
  final DateTime creationDate;

  UserInfo({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.picture,
    required this.creationDate,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      picture: json['picture'],
      creationDate: DateTime.parse(json['creationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'picture': picture,
      'creationDate': creationDate.toIso8601String(),
    };
  }
}
