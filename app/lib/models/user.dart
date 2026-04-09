class User{
  final String id;
  final String email;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'].toString(),
      isActive: json['isActive'] ?? true,
    );
  }

}