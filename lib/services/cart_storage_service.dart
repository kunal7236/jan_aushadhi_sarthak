import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';
import 'janaushadhi_api_service.dart';
import '../utils/http_date_utils.dart';

class CartStorageService {
  static const String _storageKey = 'draft_medicine_carts';

  static final ValueNotifier<List<MedicineDraft>> draftsNotifier =
      ValueNotifier<List<MedicineDraft>>(<MedicineDraft>[]);

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await loadDrafts();
    _initialized = true;
  }

  static Future<List<MedicineDraft>> loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final rawDrafts = prefs.getStringList(_storageKey) ?? <String>[];

    final drafts = rawDrafts
        .map((value) => MedicineDraft.fromJson(
              json.decode(value) as Map<String, dynamic>,
            ))
        .toList();

    draftsNotifier.value = drafts;
    return drafts;
  }

  static Future<void> _saveDrafts(List<MedicineDraft> drafts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      drafts.map((draft) => json.encode(draft.toJson())).toList(),
    );
    draftsNotifier.value = List<MedicineDraft>.from(drafts);
  }

  static String _nowLabel() {
    return HttpDateUtils.formatDateTime(
        DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)));
  }

  static Future<MedicineDraft> _getOrCreateDraftByTitle(String title) async {
    await initialize();

    final drafts = List<MedicineDraft>.from(draftsNotifier.value);
    final existingIndex = drafts.indexWhere((draft) => draft.title == title);
    if (existingIndex != -1) {
      return drafts[existingIndex];
    }

    final draft = MedicineDraft(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: _nowLabel(),
      medicines: <CartMedicineItem>[],
    );

    drafts.insert(0, draft);
    await _saveDrafts(drafts);
    return draft;
  }

  static Future<bool> addMedicine(
    JanAushadhiMedicine medicine, {
    String? draftTitle,
  }) async {
    await initialize();

    final drafts = List<MedicineDraft>.from(draftsNotifier.value);
    final title = (draftTitle == null || draftTitle.trim().isEmpty)
        ? 'List'
        : draftTitle.trim();
    final targetDraft = await _getOrCreateDraftByTitle(title);
    final activeIndex =
        drafts.indexWhere((draft) => draft.id == targetDraft.id);
    if (activeIndex == -1) {
      // Draft might have been created in _getOrCreateDraftByTitle.
      await loadDrafts();
      return addMedicine(medicine, draftTitle: draftTitle);
    }

    final item = CartMedicineItem(
      drugCode: medicine.drugCode,
      genericName: medicine.cleanGenericName,
      unitSize: medicine.unitSize,
      mrp: medicine.mrp,
    );

    final draft = drafts[activeIndex];
    final alreadyExists = draft.medicines.any(
      (existing) =>
          existing.drugCode == item.drugCode &&
          existing.genericName == item.genericName,
    );

    if (alreadyExists) {
      return false;
    }

    draft.medicines.add(item);
    await _saveDrafts(drafts);
    return true;
  }

  static Future<void> updateDraft({
    required String draftId,
    required String title,
    required String createdAt,
  }) async {
    await initialize();

    final drafts = List<MedicineDraft>.from(draftsNotifier.value);
    final draftIndex = drafts.indexWhere((draft) => draft.id == draftId);
    if (draftIndex == -1) {
      return;
    }

    drafts[draftIndex].title = title;
    drafts[draftIndex].createdAt = createdAt;
    await _saveDrafts(drafts);
  }
}
