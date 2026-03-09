/// Rest Value Model
/// Response model for /GetRestValue API
class RestValueModel {
  final bool result;
  final String? error;
  final String? remarks;
  final String? maxid;
  final String status;
  final String? trailer;
  final String id;
  final String? trailerId;
  final String? trailerName;
  final String primeMoverName;
  final String primeMoverId;
  final String driverId;
  final String driverName;

  RestValueModel({
    required this.result,
    this.error,
    this.remarks,
    this.maxid,
    required this.status,
    this.trailer,
    required this.id,
    this.trailerId,
    this.trailerName,
    required this.primeMoverName,
    required this.primeMoverId,
    required this.driverId,
    required this.driverName,
  });

  factory RestValueModel.fromJson(Map<String, dynamic> json) {
    return RestValueModel(
      result: json['Result'] as bool? ?? false,
      error: json['Error'] as String?,
      remarks: json['remarks'] as String?,
      maxid: json['maxid'] as String?,
      status: json['status'] as String? ?? '',
      trailer: json['trailer'] as String?,
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
      'Id': id,
      'TrailerId': trailerId,
      'TrailerName': trailerName,
      'PrimeMoverName': primeMoverName,
      'PrimeMoverId': primeMoverId,
      'DriverId': driverId,
      'DriverName': driverName,
    };
  }

  /// Determine the rest state based on result and status
  /// Returns: 'request', 'start', or 'end'
  String get restState {
    if (!result) {
      return 'request'; // Request Rest
    } else if (status == '0') {
      return 'start'; // Start Rest
    } else if (status == '2') {
      return 'end'; // End Rest
    }
    return 'request'; // Default
  }

  /// Get a user-friendly state description
  String get stateDescription {
    switch (restState) {
      case 'request':
        return 'Request Rest';
      case 'start':
        return 'Start Rest';
      case 'end':
        return 'End Rest';
      default:
        return 'Unknown State';
    }
  }
}
