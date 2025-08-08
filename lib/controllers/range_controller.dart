// lib/controllers/range_controller.dart
import 'package:flutter/material.dart';
import '../models/range_section.dart';
import '../services/api_service.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  static const valid = ValidationResult(isValid: true);
}

class RangeController extends ChangeNotifier {
  final ApiService apiService;

  // state
  List<RangeSection> sections = [];
  bool loading = false;
  String? error;
  double currentValue = 0.0;
  String? inputError;
  bool isRetrying = false;
  int retryAttempt = 0;

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
      retryAttempt = 0;
      isRetrying = false;
    } on ApiException catch (e) {
      error = e.message;
      sections = [];
    } catch (e) {
      error = 'An unexpected error occurred: ${e.toString()}';
      sections = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setValue(double v) {
    final validation = _validateValue(v);
    if (validation.isValid) {
      currentValue = v;
      inputError = null;
    } else {
      inputError = validation.errorMessage;
    }
    notifyListeners();
  }

  void setValueFromString(String s) {
    if (s.trim().isEmpty) {
      inputError = 'Please enter a value';
      notifyListeners();
      return;
    }

    final parsed = double.tryParse(s);
    if (parsed == null) {
      inputError = 'Please enter a valid number';
      notifyListeners();
      return;
    }

    setValue(parsed);
  }

  ValidationResult _validateValue(double value) {
    if (sections.isEmpty) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'No range data available',
      );
    }

    final minValue = sections.map((s) => s.start).reduce((a, b) => a < b ? a : b);
    final maxValue = sections.map((s) => s.end).reduce((a, b) => a > b ? a : b);

    if (value < minValue) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Value must be at least ${minValue.toStringAsFixed(1)}',
      );
    }

    if (value > maxValue) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Value must not exceed ${maxValue.toStringAsFixed(1)}',
      );
    }

    return ValidationResult.valid;
  }

  Future<void> retryWithDelay() async {
    if (isRetrying) return;

    isRetrying = true;
    retryAttempt++;
    notifyListeners();

    // Exponential backoff
    final delay = Duration(seconds: (1 << (retryAttempt - 1)).clamp(1, 30));
    await Future.delayed(delay);

    await fetchRanges();
  }

  String? getCurrentRange() {
    if (sections.isEmpty) return null;
    
    for (final section in sections) {
      if (currentValue >= section.start && currentValue <= section.end) {
        return section.meaning;
      }
    }
    return null;
  }
}