import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

part 'register_controller.g.dart';

@riverpod
class RegisterController extends _$RegisterController {
  final _authService = AuthService();

  @override
  RegisterState build() => RegisterState.initial();

  Future<void> register() async {
    // Validate form before API call
    if (!state.isValid) {
      if (state.email.isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter your email');
      } else if (!state.isValidEmail) {
        state = state.copyWith(errorMessage: 'Please enter a valid email');
      } else if (state.password.isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter a password');
      } else if (!state.isPasswordStrong) {
        state = state.copyWith(
          errorMessage:
              'Password must contain at least 1 uppercase letter and 1 number',
        );
      } else if (!state.isPasswordMatch) {
        state = state.copyWith(errorMessage: 'Passwords do not match');
      } else if (state.fullName.isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter your full name');
      } else if (!state.agreeToTerms) {
        state = state.copyWith(
          errorMessage: 'Please agree to the terms and conditions',
        );
      }
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.register(
        mobile: state.email.trim(), // Using email as mobile for now
        password: state.password.trim(),
        name: state.fullName.trim(),
        email: state.email.trim(),
      );

      if (response.result && response.error == null) {
        // Create user model from API response
        final user = UserModel(
          response.mobile ?? state.email,
          name: response.name,
          email: response.email,
          driverId: response.driverId,
          imei: response.imei,
        );

        state = state.copyWith(isLoading: false, success: true, user: user);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error: Please check your connection',
      );
    }
  }

  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setConfirmPassword(String v) =>
      state = state.copyWith(confirmPassword: v);
  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setAgreeToTerms(bool v) => state = state.copyWith(agreeToTerms: v);
}

class RegisterState {
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final bool agreeToTerms;
  final bool isLoading;
  final String? errorMessage;
  final bool success;
  final UserModel? user;

  bool get isPasswordMatch => password == confirmPassword;
  bool get isPasswordStrong =>
      password.length >= 6 &&
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[0-9]'));
  bool get isValidEmail => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);
  bool get isValid =>
      email.isNotEmpty &&
      isValidEmail &&
      password.isNotEmpty &&
      isPasswordStrong &&
      isPasswordMatch &&
      fullName.isNotEmpty &&
      agreeToTerms;

  RegisterState({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
    required this.agreeToTerms,
    required this.isLoading,
    required this.errorMessage,
    required this.success,
    required this.user,
  });

  factory RegisterState.initial() => RegisterState(
    email: "",
    password: "",
    confirmPassword: "",
    fullName: "",
    agreeToTerms: false,
    isLoading: false,
    errorMessage: null,
    success: false,
    user: null,
  );

  RegisterState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? fullName,
    bool? agreeToTerms,
    bool? isLoading,
    String? errorMessage,
    bool? success,
    UserModel? user,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fullName: fullName ?? this.fullName,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? this.success,
      user: user ?? this.user,
    );
  }
}
