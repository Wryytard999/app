class Prof {
  final int? id;
  final String? username;
  final String? password;
  final String? email;
  final String? role;
  final String? verificationToken;
  final bool? validate;

  Prof({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.role,
    required this.verificationToken,
    required this.validate
  });

  // Factory constructor to create an instance from JSON
  factory Prof.fromJson(Map<String, dynamic> json) {
    return Prof(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        email: json['email'],
        role: json['role'],
        verificationToken: json['verificationToken'],
        validate: json['validate']
    );
  }
}