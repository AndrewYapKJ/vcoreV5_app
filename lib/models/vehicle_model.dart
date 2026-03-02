class Vehicle {
  final String id;
  final String plateNumber;
  final String status;
  final String mdtuid;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.status,
    required this.mdtuid,
  });

  /// Factory constructor to create a Vehicle from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['ID']?.toString() ?? '',
      plateNumber: json['NO']?.toString() ?? '',
      status: json['Status']?.toString() ?? '',
      mdtuid: json['MDTUID']?.toString() ?? '',
    );
  }

  /// Convert Vehicle to JSON
  Map<String, dynamic> toJson() {
    return {'ID': id, 'NO': plateNumber, 'Status': status, 'MDTUID': mdtuid};
  }
}
