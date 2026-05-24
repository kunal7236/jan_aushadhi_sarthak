class CartMedicineItem {
  final String drugCode;
  final String genericName;
  final String unitSize;
  final String mrp;
  bool isBought;

  CartMedicineItem({
    required this.drugCode,
    required this.genericName,
    required this.unitSize,
    required this.mrp,
    this.isBought = false,
  });

  factory CartMedicineItem.fromJson(Map<String, dynamic> json) {
    return CartMedicineItem(
      drugCode: json['drugCode']?.toString() ?? '',
      genericName: json['genericName']?.toString() ?? '',
      unitSize: json['unitSize']?.toString() ?? '',
      mrp: json['mrp']?.toString() ?? '',
      isBought: json['isBought'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drugCode': drugCode,
      'genericName': genericName,
      'unitSize': unitSize,
      'mrp': mrp,
      'isBought': isBought,
    };
  }
}

class MedicineDraft {
  final String id;
  String title;
  String createdAt;
  final List<CartMedicineItem> medicines;

  MedicineDraft({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.medicines,
  });

  factory MedicineDraft.fromJson(Map<String, dynamic> json) {
    return MedicineDraft(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      medicines: ((json['medicines'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CartMedicineItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt,
      'medicines': medicines.map((medicine) => medicine.toJson()).toList(),
    };
  }
}
