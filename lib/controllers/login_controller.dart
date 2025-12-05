import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<bool>>(
      (ref) => LoginController(),
    );

class LoginController extends StateNotifier<AsyncValue<bool>> {
  LoginController() : super(const AsyncValue.data(false));

  Future<void> login(String email, String password, bool rememberMe) async {
    state = const AsyncValue.loading();
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      // Fake success if email contains 'test'
      if (email.contains('test')) {
        state = const AsyncValue.data(true);
      } else {
        state = AsyncValue.error('Invalid credentials', StackTrace.current);
      }
    } catch (e) {
      state = AsyncValue.error('Network error', StackTrace.current);
    }
  }
}
