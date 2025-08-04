import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/medicine_model.dart';

class ModernPrescriptionParser {
  static final _textRecognizer = TextRecognizer();

  static Future<PrescriptionParseResult> parseImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      List<Medicine> extractedMedicines = [];
      double confidence = 0.0;

      // Extract medicines from recognized text
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String lineText = line.text.trim();

          // Look for medicine patterns
          Medicine? medicine = _extractMedicineFromLine(lineText);
          if (medicine != null) {
            extractedMedicines.add(medicine);
          }
        }
      }

      // Calculate confidence based on text blocks found
      confidence = recognizedText.blocks.isNotEmpty ? 0.85 : 0.0;

      return PrescriptionParseResult(
        extractedMedicines: extractedMedicines,
        confidence: confidence,
        prescriptionDate: DateTime.now(),
      );
    } catch (e) {
      print('Error parsing image: $e');
      return PrescriptionParseResult(
        extractedMedicines: [],
        confidence: 0.0,
      );
    }
  }

  static Medicine? _extractMedicineFromLine(String line) {
    // Medicine name patterns and extraction logic
    List<String> medicineKeywords = [
      'tab',
      'tablet',
      'cap',
      'capsule',
      'syrup',
      'injection',
      'mg',
      'ml'
    ];

    String lowerLine = line.toLowerCase();

    // Check if line contains medicine indicators
    bool hasMedicineKeyword =
        medicineKeywords.any((keyword) => lowerLine.contains(keyword));

    if (hasMedicineKeyword) {
      // Extract medicine name (before dosage)
      String medicineName = _cleanMedicineName(line);

      if (medicineName.isNotEmpty) {
        return Medicine(commercialName: medicineName);
      }
    }

    return null;
  }

  static String _cleanMedicineName(String rawName) {
    // Remove common prescription text and extract clean medicine name
    String cleaned = rawName
        .replaceAll(RegExp(r'\d+\s*mg'), '') // Remove dosage
        .replaceAll(RegExp(r'\d+\s*ml'), '')
        .replaceAll(RegExp(r'tab\.?', caseSensitive: false), '')
        .replaceAll(RegExp(r'tablet', caseSensitive: false), '')
        .replaceAll(RegExp(r'cap\.?', caseSensitive: false), '')
        .replaceAll(RegExp(r'capsule', caseSensitive: false), '')
        .replaceAll(RegExp(r'syrup', caseSensitive: false), '')
        .trim();

    // Take first word/phrase as medicine name
    List<String> words = cleaned.split(' ');
    if (words.isNotEmpty) {
      return words.first.trim();
    }

    return '';
  }

  // Dispose resources
  static void dispose() {
    _textRecognizer.close();
  }
}

// Enhanced prescription service using ML Kit
class EnhancedPrescriptionService {
  static Future<PrescriptionParseResult> parseFile(File file) async {
    String extension = file.path.toLowerCase();

    if (extension.endsWith('.pdf')) {
      return await _parsePDF(file);
    } else if (extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png')) {
      return await ModernPrescriptionParser.parseImage(file);
    } else {
      throw Exception('Unsupported file format');
    }
  }

  static Future<PrescriptionParseResult> _parsePDF(File pdfFile) async {
    // TODO: Implement PDF text extraction
    // You can use packages like:
    // - syncfusion_flutter_pdf
    // - pdf_text

    await Future.delayed(const Duration(seconds: 2));

    return PrescriptionParseResult(
      extractedMedicines: [
        Medicine(commercialName: "Paracetamol 500mg"),
        Medicine(commercialName: "Amoxicillin 250mg"),
      ],
      confidence: 0.75,
      prescriptionDate: DateTime.now(),
    );
  }
}
