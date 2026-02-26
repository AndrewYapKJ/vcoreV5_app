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
    if (!state.isValid) return;

    state = state.copyWith(isLoading: true);

    final result = await _authService.register(
      state.email.trim(),
      state.password.trim(),
      state.fullName.trim(),
    );

    if (result == true) {
      state = state.copyWith(
        isLoading: false,
        success: true,
        user: UserModel(state.email),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Registration failed. Please try again.",
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
