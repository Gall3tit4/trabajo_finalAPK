class User {
  final int id;
  final String username;
  final String password;
  final String role; // Puede ser 'admin' o 'client'

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });
}
