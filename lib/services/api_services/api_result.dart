class OfflineModeException implements Exception {
  final String message;
  final String requestId;
  final bool dataUpdatedLocally;

  const OfflineModeException({
    required this.message,
    required this.requestId,
    this.dataUpdatedLocally = false,
  });

  @override
  String toString() => 'OfflineModeException: $message';
}

class OnlineApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  const OnlineApiException({
    required this.message,
    this.statusCode,
    this.responseData,
  });

  @override
  String toString() => 'OnlineApiException: $message';
}

class ApiResult<T> {
  final T? data;
  final bool isSuccess;
  final bool isOffline;
  final bool dataUpdatedLocally;
  final String? errorMessage;
  final String? requestId;

  const ApiResult._({
    this.data,
    required this.isSuccess,
    required this.isOffline,
    required this.dataUpdatedLocally,
    this.errorMessage,
    this.requestId,
  });

  factory ApiResult.success(T data) {
    return ApiResult._(
      data: data,
      isSuccess: true,
      isOffline: false,
      dataUpdatedLocally: false,
    );
  }

  factory ApiResult.offlineSuccess({T? data, required String requestId}) {
    return ApiResult._(
      data: data,
      isSuccess: true,
      isOffline: true,
      dataUpdatedLocally: true,
      requestId: requestId,
    );
  }

  factory ApiResult.onlineFailure(String errorMessage) {
    return ApiResult._(
      isSuccess: false,
      isOffline: false,
      dataUpdatedLocally: false,
      errorMessage: errorMessage,
    );
  }

  factory ApiResult.offlineFailure(String errorMessage) {
    return ApiResult._(
      isSuccess: false,
      isOffline: true,
      dataUpdatedLocally: false,
      errorMessage: errorMessage,
    );
  }
}
