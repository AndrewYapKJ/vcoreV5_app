class LoginResponse {
  final String? driverId;
  final String? name;
  final String? email;
  final String? mobile;
  final bool result;
  final String? error;
  final bool critUpdate;
  final String? version;
  final String? imei;
  final bool ptiStatus;
  final String? latestapk;
  final String? driverLicenceNo;
  final String? driverDob;
  final String? driverDateOfJoining;
  final String? gdlExpiryDate;
  final String? westPortExpiry;
  final String? northPortExpiry;
  final String? driverEmployeeCode;
  final String? tenantId;
  final String? username;

  LoginResponse({
    this.driverId,
    this.name,
    this.email,
    this.mobile,
    required this.result,
    this.error,
    required this.critUpdate,
    this.version,
    this.imei,
    required this.ptiStatus,
    this.latestapk,
    this.driverLicenceNo,
    this.driverDob,
    this.driverDateOfJoining,
    this.gdlExpiryDate,
    this.westPortExpiry,
    this.northPortExpiry,
    this.driverEmployeeCode,
    this.tenantId,
    this.username,
  });

  /// Create LoginResponse from API JSON
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      driverId: json['DriverID'] as String?,
      name: json['Name'] as String?,
      email: json['Email'] as String?,
      mobile: json['Mobile'] as String?,
      result: json['Result'] as bool? ?? false,
      error: json['Error'] as String?,
      critUpdate: json['CritUpdate'] as bool? ?? false,
      version: json['Version'] as String?,
      imei: json['IMEI'] as String?,
      ptiStatus: json['PTIstatus'] as bool? ?? false,
      latestapk: json['latestapk'] as String?,
      driverLicenceNo: json['Driver_Licence_No'] as String?,
      driverDob: json['Driver_DOB'] as String?,
      driverDateOfJoining: json['Driver_Date_Of_Joining'] as String?,
      gdlExpiryDate: json['GDLExpiryDate'] as String?,
      westPortExpiry: json['WestPortExpiry'] as String?,
      northPortExpiry: json['NorthPortExpiry'] as String?,
      driverEmployeeCode: json['Driver_Employee_Code'] as String?,
      tenantId: json['TenantId'] as String?,
      username: json['Username'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'DriverID': driverId,
      'Name': name,
      'Email': email,
      'Mobile': mobile,
      'Result': result,
      'Error': error,
      'CritUpdate': critUpdate,
      'Version': version,
      'IMEI': imei,
      'PTIstatus': ptiStatus,
      'latestapk': latestapk,
      'Driver_Licence_No': driverLicenceNo,
      'Driver_DOB': driverDob,
      'Driver_Date_Of_Joining': driverDateOfJoining,
      'GDLExpiryDate': gdlExpiryDate,
      'WestPortExpiry': westPortExpiry,
      'NorthPortExpiry': northPortExpiry,
      'Driver_Employee_Code': driverEmployeeCode,
      'TenantId': tenantId,
      'Username': username,
    };
  }

  /// Check if login was successful
  bool get isSuccess => result && error == null;

  /// Get error message
  String get errorMessage => error ?? 'Unknown error occurred';

  /// Check if critical update is required
  bool get requiresCriticalUpdate => critUpdate;

  @override
  String toString() =>
      'LoginResponse(result: $result, mobile: $mobile, error: $error)';
}
