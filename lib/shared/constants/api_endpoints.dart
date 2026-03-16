/// API Endpoints - Centralized URL management
/// All API endpoints are defined here to avoid hardcoding across the app
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://vcore.x1.com.my';

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String validateOtp = '/ValidateOTP';

  // Job endpoints
  static const String getJobsWithDriver = '/GetJobswithdriver';
  static const String getJobListToday = '/Z_GetJobListToday';
  static const String updateJob = '/UpdateJob';
  static const String updateJobDetails = '/UpdateJobDetails';
  static const String getJobImages = '/GetJobImages';
  static const String uploadImage = '/app/ReceiveFile.ashx';

  // MDT endpoints
  static const String getMDTFunctions = '/GetMDTFunctions';
  static const String requestJob = '/RequestJob';

  // Vehicle endpoints
  static const String searchTrailers = '/SearchTrailers';
  static const String searchContainers = '/SearchContainers';
  static const String getVehicleList = '/GetVehicleList';

  // PTI endpoints
  static const String getPTIList = '/GetPTIList';
  static const String submitPTI = '/SubmitPTI';

  // Payment endpoints
  static const String paymentList = '/PaymentList';
  static const String paymentDetail = '/PaymentDetail';
}

/// HTTP Headers
class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String contentTypeJson = 'application/json; charset=utf-8';
  static const String contentTypeForm = 'application/x-www-form-urlencoded';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
}

/// HTTP Status Codes
class HttpStatusCodes {
  static const int ok = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
}
