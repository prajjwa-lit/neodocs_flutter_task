// lib/controllers/range_controller.dart
import 'package:flutter/material.dart';
import '../models/range_section.dart';
import '../services/api_service.dart';

class RangeController extends ChangeNotifier {
  final ApiService apiService;

  // state
  List<RangeSection> sections = [];
  bool loading = false;
  String? error;
  double currentValue = 0.0;

  RangeController({required this.apiService});

  /// Fetch ranges from API and notify listeners for UI updates.
  Future<void> fetchRanges() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await apiService.fetchRanges();
      // Sort the sections by start to keep the bar ordered
      result.sort((a, b) => a.start.compareTo(b.start));
      sections = result;
    } catch (e) {
      error = e.toString();
      sections = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setValue(double v) {
    currentValue = v;
    notifyListeners();
  }

  void setValueFromString(String s) {
    final parsed = double.tryParse(s);
    if (parsed != null) {
      setValue(parsed);
    }
  }
}
