class UserCreation {
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;

  UserCreation({
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
  });

  factory UserCreation.fromJson(Map<String, dynamic> json) {
    return UserCreation(
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      password: json['password'],
      passwordConfirmation: json['passwordConfirmation'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
      'passwordConfirmation': passwordConfirmation,
      'role': role,
    };
  }
}
