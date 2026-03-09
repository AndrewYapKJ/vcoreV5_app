/// Return Value Model
/// Response model for /GetReturnValue API
class ReturnValueModel {
  final bool result;
  final String? error;
  final String? remarks;
  final String? maxid;
  final String status;
  final String? trailer;
  final String? yardID;
  final String? yardName;
  final String? yardCode;
  final String id;
  final String? trailerId;
  final String? trailerName;
  final String primeMoverName;
  final String primeMoverId;
  final String driverId;
  final String driverName;

  ReturnValueModel({
    required this.result,
    this.error,
    this.remarks,
    this.maxid,
    required this.status,
    this.trailer,
    this.yardID,
    this.yardName,
    this.yardCode,
    required this.id,
    this.trailerId,
    this.trailerName,
    required this.primeMoverName,
    required this.primeMoverId,
    required this.driverId,
    required this.driverName,
  });

  factory ReturnValueModel.fromJson(Map<String, dynamic> json) {
    return ReturnValueModel(
      result: json['Result'] as bool? ?? false,
      error: json['Error'] as String?,
      remarks: json['remarks'] as String?,
      maxid: json['maxid'] as String?,
      status: json['status'] as String? ?? '',
      trailer: json['trailer'] as String?,
      yardID: json['yardID'] as String?,
      yardName: json['yardName'] as String?,
      yardCode: json['yardCode'] as String?,
      id: json['Id'] as String? ?? '',
      trailerId: json['TrailerId'] as String?,
      trailerName: json['TrailerName'] as String?,
      primeMoverName: json['PrimeMoverName'] as String? ?? '',
      primeMoverId: json['PrimeMoverId'] as String? ?? '',
      driverId: json['DriverId'] as String? ?? '',
      driverName: json['DriverName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Result': result,
      'Error': error,
      'remarks': remarks,
      'maxid': maxid,
      'status': status,
      'trailer': trailer,
      'yardID': yardID,
      'yardName': yardName,
      'yardCode': yardCode,
      'Id': id,
      'TrailerId': trailerId,
      'TrailerName': trailerName,
      'PrimeMoverName': primeMoverName,
      'PrimeMoverId': primeMoverId,
      'DriverId': driverId,
      'DriverName': driverName,
    };
  }

  /// Determine the return state based on result and status
  /// Returns: 'request', 'start', or 'end'
  String get returnState {
    if (!result) {
      return 'request'; // Request Return
    } else if (status == '0') {
      return 'start'; // Start Return
    } else if (status == '1') {
      return 'end'; // End Return
    }
    return 'request'; // Default
  }

  /// Get a user-friendly state description
  String get stateDescription {
    switch (returnState) {
      case 'request':
        return 'Request Return';
      case 'start':
        return 'Start Return';
      case 'end':
        return 'End Return';
      default:
        return 'Unknown State';
    }
  }
}
