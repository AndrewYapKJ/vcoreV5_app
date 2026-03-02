class MDTFunction {
  final int mdtCode;
  final String mdtDesc;
  final bool result;
  final String? error;

  MDTFunction({
    required this.mdtCode,
    required this.mdtDesc,
    required this.result,
    this.error,
  });

  factory MDTFunction.fromJson(Map<String, dynamic> json) {
    return MDTFunction(
      mdtCode: int.tryParse(json['MDTCode']?.toString() ?? '0') ?? 0,
      mdtDesc: json['MDTDesc'] as String? ?? '',
      result: json['Result'] as bool? ?? false,
      error: json['Error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MDTCode': mdtCode,
      'MDTDesc': mdtDesc,
      'Result': result,
      'Error': error,
    };
  }

  bool get isSuccess => result && error == null;
}

class MDTFunctionsResponse {
  final List<MDTFunction> functions;
  final String? error;

  MDTFunctionsResponse({required this.functions, this.error});

  factory MDTFunctionsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['d'] as List<dynamic>? ?? [];
    final functions = data
        .map((item) => MDTFunction.fromJson(item as Map<String, dynamic>))
        .toList();

    return MDTFunctionsResponse(
      functions: functions,
      error: json['Error'] as String?,
    );
  }

  bool get isSuccess => functions.isNotEmpty && error == null;
}
