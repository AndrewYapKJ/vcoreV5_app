// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import '../models/login_response_model.dart';

// class ApiService {
//   static const String _baseUrl =
//       'https://vcore.x1.com.my/VCoreMultiTDriverMDT2025.asmx';

//   late Dio _dio;

//   ApiService() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: _baseUrl,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         contentType: 'application/json',
//       ),
//     );

//     // Add interceptors for logging and error handling
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           debugPrint('API Request: ${options.method} ${options.path}');
//           debugPrint('Headers: ${options.headers}');
//           if (options.data != null) {
//             debugPrint('Data: ${options.data}');
//           }
//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           debugPrint('API Response: ${response.statusCode}');
//           debugPrint('Response Data: ${response.data}');
//           return handler.next(response);
//         },
//         onError: (error, handler) {
//           debugPrint('API Error: ${error.message}');
//           debugPrint('Error Response: ${error.response?.data}');
//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   /// Login API endpoint
//   /// POST /login
//   ///
//   /// Request body:
//   /// {
//   ///   "mobile": "01397851577",
//   ///   "password": "1234"
//   /// }
//   ///
//   /// Response: LoginResponse model
//   Future<LoginResponse> login({
//     required String mobile,
//     required String password,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/login',
//         data: {'mobile': mobile, 'password': password},
//       );

//       // API returns data wrapped in 'd' property
//       if (response.statusCode == 200 && response.data != null) {
//         final data = response.data['d'] as Map<String, dynamic>;
//         return LoginResponse.fromJson(data);
//       }

//       throw DioException(
//         requestOptions: response.requestOptions,
//         message: 'Unexpected response format',
//       );
//     } on DioException catch (e) {
//       debugPrint('Login API Error: ${e.message}');
//       rethrow;
//     }
//   }

//   /// Register API endpoint (if available)
//   Future<Map<String, dynamic>> register({
//     required String mobile,
//     required String password,
//     required String name,
//     required String email,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/register',
//         data: {
//           'mobile': mobile,
//           'password': password,
//           'name': name,
//           'email': email,
//         },
//       );

//       if (response.statusCode == 200 && response.data != null) {
//         final result = response.data['d'] as Map<String, dynamic>;
//         return result;
//       }

//       throw DioException(
//         requestOptions: response.requestOptions,
//         message: 'Unexpected response format',
//       );
//     } on DioException catch (e) {
//       debugPrint('Register API Error: ${e.message}');
//       rethrow;
//     }
//   }
// }
