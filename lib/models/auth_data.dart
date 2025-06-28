import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'user.dart';

class AuthData extends ChangeNotifier {
  final Box<User> _userBox = Hive.box<User>('users');
  final Box settingsBox = Hive.box('settings');

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> loadLoggedInUser() async {
    final key = settingsBox.get('loggedInUser');
    if (key != null) {
      _currentUser = _userBox.get(key);
      notifyListeners();
    }
  }

  bool login(String username, String password) {
    final user = _userBox.values.cast<User?>().firstWhere(
      (u) => u?.username == username && u?.password == password,
      orElse: () => null,
    );

    if (user != null) {
      _currentUser = user;
      settingsBox.put('loggedInUser', user.key);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool signUp(String username, String password) {
    final exists = _userBox.values.any((u) => u.username == username);
    if (exists) return false;

    final user = User(username: username, password: password);
    final key = _userBox.add(user);

    _currentUser = _userBox.get(key);
    settingsBox.put('loggedInUser', key);
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    settingsBox.delete('loggedInUser');
    notifyListeners();
  }
}