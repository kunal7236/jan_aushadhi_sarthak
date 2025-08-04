// Data models for the Jan Aushadhi Sarthak app

class Medicine {
  String commercialName;
  String? genericName;
  bool isVerified;
  bool isAvailableInJanAushadhi;
  String? janAushadhiPrice;
  String? marketPrice;
  List<String> alternatives;

  Medicine({
    required this.commercialName,
    this.genericName,
    this.isVerified = false,
    this.isAvailableInJanAushadhi = false,
    this.janAushadhiPrice,
    this.marketPrice,
    this.alternatives = const [],
  });

  // Calculate savings
  double? get savingsAmount {
    if (janAushadhiPrice == null || marketPrice == null) return null;
    final janPrice = double.tryParse(janAushadhiPrice!);
    final mktPrice = double.tryParse(marketPrice!);
    if (janPrice == null || mktPrice == null) return null;
    return mktPrice - janPrice;
  }

  double? get savingsPercentage {
    if (janAushadhiPrice == null || marketPrice == null) return null;
    final janPrice = double.tryParse(janAushadhiPrice!);
    final mktPrice = double.tryParse(marketPrice!);
    if (janPrice == null || mktPrice == null) return null;
    return ((mktPrice - janPrice) / mktPrice) * 100;
  }
}

class JanAushadhiStore {
  String name;
  String address;
  String? phone;
  double? distance;
  List<String> availableMedicines;

  JanAushadhiStore({
    required this.name,
    required this.address,
    this.phone,
    this.distance,
    this.availableMedicines = const [],
  });
}

class PrescriptionParseResult {
  List<Medicine> extractedMedicines;
  String? doctorName;
  String? patientName;
  DateTime? prescriptionDate;
  double confidence;

  PrescriptionParseResult({
    required this.extractedMedicines,
    this.doctorName,
    this.patientName,
    this.prescriptionDate,
    this.confidence = 0.0,
  });
}
