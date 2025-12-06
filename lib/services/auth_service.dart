import 'dart:async';

class AuthService {
  Future<bool> login(String userId, String password) async {
    await Future.delayed(Duration(seconds: 2)); // Fake API delay

    // Fake validation
    if (userId == "admin" && password == "123456") {
      return true;
    }
    return false;
  }
}
