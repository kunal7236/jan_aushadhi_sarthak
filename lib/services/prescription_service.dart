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
          }
        }
      }

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
}
