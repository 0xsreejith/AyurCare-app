// lib/providers/register_provider.dart
import 'package:flutter/material.dart';
import 'package:ayur_care_app/data/models/branch_model.dart';
import 'package:ayur_care_app/data/models/treatment_model.dart';
import 'package:ayur_care_app/data/services/api_service.dart';
import 'package:flutter/foundation.dart';

class RegisterProvider extends ChangeNotifier {
  final ApiService _apiService;

  RegisterProvider(this._apiService);

  bool isLoadingBranches = false;
  bool isLoadingTreatments = false;
  bool isSubmitting = false;

  List<Branch> branches = [];
  List<Treatment> treatments = [];

  Branch? selectedBranch;
  // We keep lists of Treatment objects; duplicates allowed (for counts).
  List<Treatment> selectedMaleTreatments = [];
  List<Treatment> selectedFemaleTreatments = [];
  // unique treatments added (one per type)
  List<Treatment> selectedTreatments = [];

  double discountAmount = 0.0;
  double advanceAmount = 0.0;

  // Fetch branches
  Future<void> fetchBranches() async {
    isLoadingBranches = true;
    notifyListeners();
    try {
      branches = await _api_apiSafeGetBranches();
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      branches = [];
    } finally {
      isLoadingBranches = false;
      notifyListeners();
    }
  }

  // helper wrapper to isolate API calls
  Future<List<Branch>> _api_apiSafeGetBranches() => _apiService.getBranchList();

  // Fetch treatments
  Future<void> fetchTreatments() async {
    isLoadingTreatments = true;
    notifyListeners();
    try {
      treatments = await _apiService.getTreatmentList();
    } catch (e) {
      debugPrint('Error fetching treatments: $e');
      treatments = [];
    } finally {
      isLoadingTreatments = false;
      notifyListeners();
    }
  }

  // set branch
  void setSelectedBranch(Branch branch) {
    selectedBranch = branch;
    notifyListeners();
  }

  // Add repeated treatment objects to male/female lists (used by screen)
  void addMaleTreatment(Treatment t, int count) {
    for (int i = 0; i < count; i++) selectedMaleTreatments.add(t);
    if (!selectedTreatments.any((s) => s.id == t.id)) selectedTreatments.add(t);
    notifyListeners();
  }

  void addFemaleTreatment(Treatment t, int count) {
    for (int i = 0; i < count; i++) selectedFemaleTreatments.add(t);
    if (!selectedTreatments.any((s) => s.id == t.id)) selectedTreatments.add(t);
    notifyListeners();
  }

  void removeTreatmentCompletely(Treatment t) {
    selectedMaleTreatments.removeWhere((e) => e.id == t.id);
    selectedFemaleTreatments.removeWhere((e) => e.id == t.id);
    selectedTreatments.removeWhere((e) => e.id == t.id);
    notifyListeners();
  }

  void updateTreatmentCounts(Treatment t, int maleCount, int femaleCount) {
    // remove previous entries then add new
    selectedMaleTreatments.removeWhere((e) => e.id == t.id);
    selectedFemaleTreatments.removeWhere((e) => e.id == t.id);
    addMaleTreatment(t, maleCount);
    addFemaleTreatment(t, femaleCount);
    notifyListeners();
  }

  // Price calculations
  double get selectedTreatmentsTotal {
    final all = [...selectedMaleTreatments, ...selectedFemaleTreatments];
    return all.fold(0.0, (sum, t) => sum + t.price);
  }

  double get totalAmount => selectedTreatmentsTotal;

  double get netAfterDiscount => (totalAmount - discountAmount).clamp(0.0, double.infinity);

  double get balanceAmount => (netAfterDiscount - advanceAmount).clamp(0.0, double.infinity);

  void setDiscount(double d) {
    discountAmount = d;
    notifyListeners();
  }

  void setAdvance(double a) {
    advanceAmount = a;
    notifyListeners();
  }

  // Register patient: converts lists to CSV id strings and calls API
  Future<bool> registerPatient({
    required String name,
    required String executive,
    required String payment,
    required String phone,
    required String address,
    required String dateAndTime,
  }) async {
    if (selectedBranch == null) {
      debugPrint('Branch not selected');
      return false;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      // male/female lists contain Treatment objects repeated per count -> map to ids
      final maleIds = selectedMaleTreatments.map((t) => t.id.toString()).toList();
      final femaleIds = selectedFemaleTreatments.map((t) => t.id.toString()).toList();
      final uniqueTreatmentIds = selectedTreatments.map((t) => t.id.toString()).toList();

      await _apiService.registerPatient(
        name: name,
        executive: executive,
        payment: payment,
        phone: phone,
        address: address,
        totalAmount: totalAmount,
        discountAmount: discountAmount,
        advanceAmount: advanceAmount,
        balanceAmount: balanceAmount,
        dateAndTime: dateAndTime,
        branch: selectedBranch!.id.toString(),
        maleTreatments: maleIds,
        femaleTreatments: femaleIds,
        treatments: uniqueTreatmentIds,
      );

      return true;
    } catch (e) {
      debugPrint('Error registering patient: $e');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // Clear selections after successful register if needed
  void clearSelections() {
    selectedBranch = null;
    selectedMaleTreatments = [];
    selectedFemaleTreatments = [];
    selectedTreatments = [];
    discountAmount = 0.0;
    advanceAmount = 0.0;
    notifyListeners();
  }
}
