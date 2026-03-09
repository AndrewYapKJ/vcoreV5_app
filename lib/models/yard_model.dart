/// Staging Yard Model
/// Response model for /RTBYard API
class YardModel {
  final String yardID;
  final String yardName;
  final bool result;
  final String error;

  YardModel({
    required this.yardID,
    required this.yardName,
    required this.result,
    required this.error,
  });

  factory YardModel.fromJson(Map<String, dynamic> json) {
    return YardModel(
      yardID: json['YardID'] as String? ?? '',
      yardName: json['YardName'] as String? ?? '',
      result: json['Result'] as bool? ?? false,
      error: json['Error'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'YardID': yardID,
      'YardName': yardName,
      'Result': result,
      'Error': error,
    };
  }
}
