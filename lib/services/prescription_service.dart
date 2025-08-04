import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/medicine_model.dart';

class PrescriptionParser {
  static final _textRecognizer = TextRecognizer();

  static Future<PrescriptionParseResult> parseImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      List<Medicine> extractedMedicines = [];
      double confidence = 0.0;

      // Extract medicines from recognized text
      List<String> allLines = [];
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String lineText = line.text.trim();
          if (lineText.isNotEmpty) {
            allLines.add(lineText);
            print('OCR Line: $lineText'); // Debug: see what OCR extracted
          }
        }
      }

      print('Total lines extracted: ${allLines.length}'); // Debug

      // Process each line to find medicine names
      for (String line in allLines) {
        List<Medicine> medicinesFromLine = _extractMedicinesFromLine(line);
        extractedMedicines.addAll(medicinesFromLine);
      }

      // Remove duplicates
      extractedMedicines = _removeDuplicateMedicines(extractedMedicines);

      // Calculate confidence based on how much text was recognized
      confidence = recognizedText.blocks.isNotEmpty
          ? (extractedMedicines.isNotEmpty ? 0.85 : 0.4)
          : 0.0;

      print(
          'Final extracted medicines: ${extractedMedicines.map((m) => m.commercialName).toList()}'); // Debug

      // If no medicines found, show what was actually extracted
      if (extractedMedicines.isEmpty && allLines.isNotEmpty) {
        // Try to extract any meaningful text as potential medicine names
        extractedMedicines = _extractPotentialMedicines(allLines);
        confidence = 0.3; // Lower confidence for uncertain extractions
      }

      return PrescriptionParseResult(
        extractedMedicines: extractedMedicines,
        confidence: confidence,
        prescriptionDate: DateTime.now(),
      );
    } catch (e) {
      print('OCR Error: $e');
      // Return empty result instead of dummy data
      return PrescriptionParseResult(
        extractedMedicines: [],
        confidence: 0.0,
        prescriptionDate: DateTime.now(),
      );
    }
  }

  static List<Medicine> _extractMedicinesFromLine(String line) {
    List<Medicine> medicines = [];

    // Medicine indicators - expanded list
    List<String> medicineKeywords = [
      'tab',
      'tablet',
      'cap',
      'capsule',
      'syrup',
      'injection',
      'mg',
      'ml',
      'gm',
      'drops',
      'ointment',
      'cream',
      'gel',
      'powder',
      'suspension',
      'solution'
    ];

    String lowerLine = line.toLowerCase();

    // Check if line contains medicine indicators
    bool hasMedicineKeyword =
        medicineKeywords.any((keyword) => lowerLine.contains(keyword));

    if (hasMedicineKeyword || _containsMedicineName(line)) {
      // Extract medicine name (before dosage)
      String medicineName = _cleanMedicineName(line);

      if (medicineName.isNotEmpty && medicineName.length > 2) {
        medicines.add(Medicine(commercialName: medicineName));
        print('Extracted medicine: $medicineName from line: $line'); // Debug
      }
    }

    return medicines;
  }

  static List<Medicine> _extractPotentialMedicines(List<String> allLines) {
    List<Medicine> potentialMedicines = [];

    for (String line in allLines) {
      // Look for words that could be medicine names
      List<String> words = line.split(RegExp(r'\s+'));

      for (String word in words) {
        String cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');

        // If word is 4+ characters and looks like a medicine name
        if (cleanWord.length >= 4 && _looksLikeMedicineName(cleanWord)) {
          potentialMedicines.add(Medicine(commercialName: cleanWord));
          print(
              'Potential medicine found: $cleanWord from line: $line'); // Debug
        }
      }
    }

    return _removeDuplicateMedicines(potentialMedicines);
  }

  static bool _looksLikeMedicineName(String word) {
    // Common medicine name endings
    List<String> medicineEndings = [
      'cin',
      'zole',
      'pril',
      'olol',
      'mycin',
      'cillin',
      'zone',
      'tide'
    ];

    String lowerWord = word.toLowerCase();

    // Check if it ends with common medicine suffixes
    bool hasCommonEnding =
        medicineEndings.any((ending) => lowerWord.endsWith(ending));

    // Check if it contains common patterns
    bool hasCommonPattern = lowerWord.contains('oxy') ||
        lowerWord.contains('anti') ||
        lowerWord.contains('para') ||
        lowerWord.contains('meta');

    return hasCommonEnding || hasCommonPattern;
  }

  static bool _containsMedicineName(String line) {
    // Common medicine name patterns
    List<String> commonMedicines = [
      'paracetamol',
      'ibuprofen',
      'aspirin',
      'amoxicillin',
      'azithromycin',
      'crocin',
      'dolo',
      'combiflam',
      'calpol',
      'metacin',
      'disprin',
      'augmentin',
      'amoxiclav',
      'pantocid',
      'omeprazole',
      'ranitidine',
      'cetirizine',
      'loratadine',
      'allegra',
      'zyrtec'
    ];

    String lowerLine = line.toLowerCase();
    return commonMedicines.any((med) => lowerLine.contains(med));
  }

  static String _cleanMedicineName(String rawName) {
    // Remove common prescription text and extract clean medicine name
    String cleaned = rawName
        .replaceAll(RegExp(r'\d+\s*mg'), '') // Remove dosage
        .replaceAll(RegExp(r'\d+\s*ml'), '')
        .replaceAll(RegExp(r'\d+\s*gm'), '')
        .replaceAll(RegExp(r'tab\.?', caseSensitive: false), '')
        .replaceAll(RegExp(r'tablet', caseSensitive: false), '')
        .replaceAll(RegExp(r'cap\.?', caseSensitive: false), '')
        .replaceAll(RegExp(r'capsule', caseSensitive: false), '')
        .replaceAll(RegExp(r'syrup', caseSensitive: false), '')
        .replaceAll(RegExp(r'injection', caseSensitive: false), '')
        .replaceAll(RegExp(r'drops', caseSensitive: false), '')
        .replaceAll(RegExp(r'cream', caseSensitive: false), '')
        .replaceAll(RegExp(r'ointment', caseSensitive: false), '')
        .replaceAll(RegExp(r'\d+'), '') // Remove all numbers
        .replaceAll(
            RegExp(r'[^\w\s]'), '') // Remove special characters except spaces
        .trim();

    // Take first meaningful word as medicine name
    List<String> words = cleaned
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && word.length > 2)
        .toList();

    if (words.isNotEmpty) {
      String medicineName = words.first.trim();
      // Return only if it's a meaningful medicine name
      if (medicineName.length >= 3 && !_isCommonWord(medicineName)) {
        return medicineName;
      }
    }

    return '';
  }

  static bool _isCommonWord(String word) {
    // Filter out common non-medicine words
    List<String> commonWords = [
      'the',
      'and',
      'for',
      'with',
      'take',
      'use',
      'day',
      'time',
      'daily',
      'twice',
      'once',
      'morning',
      'evening',
      'night',
      'before',
      'after',
      'food',
      'meal',
      'water',
      'medicine',
      'drug',
      'dose',
      'prescription',
      'doctor',
      'patient'
    ];

    return commonWords.contains(word.toLowerCase());
  }

  static List<Medicine> _removeDuplicateMedicines(List<Medicine> medicines) {
    Map<String, Medicine> uniqueMedicines = {};

    for (Medicine medicine in medicines) {
      String key = medicine.commercialName.toLowerCase();
      if (!uniqueMedicines.containsKey(key)) {
        uniqueMedicines[key] = medicine;
      }
    }

    return uniqueMedicines.values.toList();
  }

  static Future<PrescriptionParseResult> parsePDF(File pdfFile) async {
    // Simulate PDF parsing time
    await Future.delayed(const Duration(seconds: 3));

    // TODO: Implement PDF text extraction using packages like:
    // - pdf_text
    // - syncfusion_flutter_pdf

    return PrescriptionParseResult(
      extractedMedicines: [
        Medicine(commercialName: "Paracetamol 500mg"),
        Medicine(commercialName: "Amoxicillin 250mg"),
        Medicine(commercialName: "Omeprazole 20mg"),
      ],
      confidence: 0.92,
      prescriptionDate: DateTime.now(),
    );
  }
}

class MedicineDatabase {
  // TODO: Implement actual database integration
  // This could be:
  // - Local SQLite database
  // - Firebase Firestore
  // - REST API calls to your backend
  // - CSV/JSON file parsing

  static Future<Medicine?> findGenericName(String commercialName) async {
    // Simulate database lookup
    await Future.delayed(const Duration(milliseconds: 500));

    // Dummy mapping - replace with actual database
    final Map<String, String> commercialToGeneric = {
      'crocin': 'Paracetamol',
      'dolo': 'Paracetamol',
      'calpol': 'Paracetamol',
      'amoxiclav': 'Amoxicillin + Clavulanic Acid',
      'augmentin': 'Amoxicillin + Clavulanic Acid',
      'pantoprazole': 'Pantoprazole',
      'pantocid': 'Pantoprazole',
      'cetirizine': 'Cetirizine',
      'zyrtec': 'Cetirizine',
    };

    final generic = commercialToGeneric[commercialName.toLowerCase()];
    if (generic != null) {
      return Medicine(
        commercialName: commercialName,
        genericName: generic,
        isVerified: true,
      );
    }

    return null;
  }

  static Future<List<Medicine>> searchJanAushadhiAvailability(
      List<Medicine> medicines) async {
    // Simulate API call to Jan Aushadhi database
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Replace with actual Jan Aushadhi API integration
    for (var medicine in medicines) {
      // Dummy availability check
      medicine.isAvailableInJanAushadhi = medicine.genericName != null;
      if (medicine.isAvailableInJanAushadhi) {
        medicine.janAushadhiPrice =
            "₹${(10 + (medicine.commercialName.length % 50)).toString()}";
        medicine.marketPrice =
            "₹${(50 + (medicine.commercialName.length % 200)).toString()}";
      }
    }

    return medicines;
  }

  static Future<List<JanAushadhiStore>> findNearbyStores({
    double? latitude,
    double? longitude,
    int radius = 10, // km
  }) async {
    // Simulate location-based store search
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Replace with actual store locator API
    return [
      JanAushadhiStore(
        name: "Jan Aushadhi Store - Central Plaza",
        address: "123 Main Street, City Center",
        phone: "+91 98765 43210",
        distance: 2.5,
      ),
      JanAushadhiStore(
        name: "Jan Aushadhi Medical Store",
        address: "456 Health Avenue, Medical District",
        phone: "+91 87654 32109",
        distance: 4.2,
      ),
      JanAushadhiStore(
        name: "Generic Medicine Center",
        address: "789 Wellness Road, Healthcare Hub",
        phone: "+91 76543 21098",
        distance: 6.8,
      ),
    ];
  }
}
