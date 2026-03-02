class UserModel {
  final String userId;
  final String? name;
  final String? email;
  final String? driverId;
  final String? imei;

  UserModel(this.userId, {this.name, this.email, this.driverId, this.imei});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      json['Mobile'] ?? json['userId'] ?? '',
      name: json['Name'],
      email: json['Email'],
      driverId: json['DriverID'],
      imei: json['IMEI'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'driverId': driverId,
      'imei': imei,
    };
  }
}
