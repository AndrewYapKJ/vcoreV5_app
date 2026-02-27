import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/storage/login_cache_service.dart';
import '../models/user_model.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  final _authService = AuthService();
  final _storage = LocalStorageService();
  late final LoginCacheService _loginCacheService;

  @override
  LoginState build() {
    _loginCacheService = LoginCacheService();
    return LoginState.initial();
  }

  Future<void> login() async {
    // if (!state.isValid) return;

    state = state.copyWith(isLoading: true);

    final result = await _authService.login(
      state.userId.trim(),
      state.password.trim(),
    );

    if (result == true) {
      if (state.rememberMe) {
        await _storage.saveRememberMe(true);
        await _storage.saveUserId(state.userId);
      }

      // Initialize and cache login data
      await _loginCacheService.initialize();
      await _loginCacheService.cacheLoginData(
        userEmail: state.userId.trim(),
        userId: state.userId.trim(),
        token:
            'auth_token_${state.userId}', // Replace with actual token from auth service
        userInfo: {'email': state.userId.trim(), 'userId': state.userId.trim()},
      );

      state = state.copyWith(
        isLoading: false,
        success: true,
        user: UserModel(state.userId),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Invalid login credentials.",
      );
    }
  }

  void setUserId(String v) => state = state.copyWith(userId: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void toggleRememberMe(bool v) => state = state.copyWith(rememberMe: v);

  Future<void> logout() async {
    // Clear cached login data
    await _loginCacheService.clearCache();
    // Reset state
    state = LoginState.initial();
  }
}

class LoginState {
  final String userId;
  final String password;
  final bool rememberMe;
  final bool isLoading;
  final String? errorMessage;
  final bool success;
  final UserModel? user;

  bool get isValid => userId.isNotEmpty && password.length >= 6;

  LoginState({
    required this.userId,
    required this.password,
    required this.rememberMe,
    required this.isLoading,
    required this.errorMessage,
    required this.success,
    required this.user,
  });

  factory LoginState.initial() => LoginState(
    userId: "",
    password: "",
    rememberMe: false,
    isLoading: false,
    errorMessage: null,
    success: false,
    user: null,
  );

  LoginState copyWith({
    String? userId,
    String? password,
    bool? rememberMe,
    bool? isLoading,
    String? errorMessage,
    bool? success,
    UserModel? user,
  }) {
    return LoginState(
      userId: userId ?? this.userId,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? this.success,
      user: user ?? this.user,
    );
  }
}
