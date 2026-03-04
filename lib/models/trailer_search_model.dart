/// Trailer Search Model
/// Response model for /GetTrailerRegNoSearch API
class TrailerSearchResult {
  final String trailerRegNoDisp;
  final String trailerRegNo;
  final String trailerID;
  final String trailerSize;
  final String status;
  final String reason;

  TrailerSearchResult({
    required this.trailerRegNoDisp,
    required this.trailerRegNo,
    required this.trailerID,
    required this.trailerSize,
    required this.status,
    required this.reason,
  });

  factory TrailerSearchResult.fromJson(Map<String, dynamic> json) {
    return TrailerSearchResult(
      trailerRegNoDisp: json['TrailerRegNoDisp'] as String? ?? '',
      trailerRegNo: json['TrailerRegNo'] as String? ?? '',
      trailerID: json['Id'] as String? ?? '',
      trailerSize: json['TrailerSize'] as String? ?? '',
      status: json['Status'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TrailerRegNoDisp': trailerRegNoDisp,
      'TrailerRegNo': trailerRegNo,
      'TrailerID': trailerID,
      'TrailerSize': trailerSize,
      'Id': trailerID,
      'Status': status,
      'reason': reason,
    };
  }
}
