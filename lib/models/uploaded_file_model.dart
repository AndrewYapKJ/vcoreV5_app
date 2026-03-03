class UploadedFile {
  final String id;
  final String name;
  final String contentType;
  final String data; // base64 encoded image data

  UploadedFile({
    required this.id,
    required this.name,
    required this.contentType,
    required this.data,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      contentType: json['ContentType'] ?? '',
      data: json['Data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'Id': id, 'Name': name, 'ContentType': contentType, 'Data': data};
  }
}
