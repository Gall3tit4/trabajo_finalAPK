import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  List<User> _users = [
    User(id: 1, username: 'admin', password: 'admin123', role: 'admin'),
    User(id: 2, username: 'client', password: 'client123', role: 'client'),
  ];

  User? _authenticatedUser;

  User? get authenticatedUser => _authenticatedUser;
  List<User> get users => _users;

  // Añadir el getter 'userRole'
  String? get userRole => _authenticatedUser?.role;

  bool login(String username, String password) {
    final user = _users.firstWhere(
      (user) => user.username == username && user.password == password,
      orElse: () => User(id: 0, username: '', password: '', role: ''),
    );

    if (user.id != 0) {
      _authenticatedUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _authenticatedUser = null;
    notifyListeners();
  }

  void addUser(String username, String password, String role) {
    final newUser = User(
      id: _users.length + 1,
      username: username,
      password: password,
      role: role,
    );
    _users.add(newUser);
    notifyListeners();
  }

  void editUser(int id, String username, String password, String role) {
    final userIndex = _users.indexWhere((user) => user.id == id);
    if (userIndex >= 0) {
      _users[userIndex] = User(
        id: id,
        username: username,
        password: password,
        role: role,
      );
      notifyListeners();
    }
  }

  void deleteUser(int id) {
    _users.removeWhere((user) => user.id == id);
    notifyListeners();
  }
}
