class PTICheckItem {
  final String category;
  final String subCategory;
  final int type; // 1 = Poor/Average/Good, 2 = Poor/Good

  PTICheckItem({
    required this.category,
    required this.subCategory,
    required this.type,
  });

  factory PTICheckItem.fromJson(Map<String, dynamic> json) {
    return PTICheckItem(
      category: json['Category']?.toString() ?? '',
      subCategory: json['SubCategory']?.toString() ?? '',
      type: (json['Type'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'Category': category, 'SubCategory': subCategory, 'Type': type};
  }
}

class PTICheckItemsResponse {
  final bool status;
  final List<PTICheckItem> items;

  PTICheckItemsResponse({required this.status, required this.items});

  factory PTICheckItemsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['d'] as Map<String, dynamic>?;
    final status = data?['status'] as bool? ?? false;
    final itemsList = data?['d'] as List? ?? [];

    return PTICheckItemsResponse(
      status: status,
      items: itemsList
          .map((item) => PTICheckItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
