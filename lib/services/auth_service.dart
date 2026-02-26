import 'dart:async';

class AuthService {
  Future<bool> login(String userId, String password) async {
    await Future.delayed(Duration(seconds: 0)); // Fake API delay

    // Fake validation
    if (userId == "" && password == "") {
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password, String fullName) async {
    await Future.delayed(Duration(seconds: 2)); // Fake API delay

    // Fake validation - check if email already exists
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      return false;
    }

    // Simulate successful registration
    return true;
  }
}
