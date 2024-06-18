class User {
  final String email;
  final String username;
  final String? profilePicture;
  final String? password;

  const User({
    required this.email,
    required this.username,
    this.profilePicture,
    this.password,
  });

  // Add a method to convert User to a Map for easier JSON encoding
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      "profilePicture": profilePicture,
      'password': password,
    };
  }
}
