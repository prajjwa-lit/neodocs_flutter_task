// lib/models/range_section.dart
import 'package:flutter/material.dart';

class RangeSection {
  final double start;
  final double end;
  final String meaning;
  final Color color;

  RangeSection({
    required this.start,
    required this.end,
    required this.meaning,
    required this.color,
  });

  factory RangeSection.fromJson(Map<String, dynamic> json) {
    // Accepts a "range" string like "0-28" or " 0 - 28 "
    double start = 0;
    double end = 0;

    final rangeRaw = json['range'];
    if (rangeRaw is String) {
      final parts = rangeRaw.split('-');
      if (parts.length >= 2) {
        start = double.tryParse(parts[0].trim()) ?? 0.0;
        end = double.tryParse(parts[1].trim()) ?? start;
      } else {
        // If single number provided
        start = double.tryParse(rangeRaw.trim()) ?? 0.0;
        end = start;
      }
    } else if (rangeRaw is num) {
      start = rangeRaw.toDouble();
      end = start;
    } else if (rangeRaw is Map) {
      // In case future data uses { "min":..., "max":... }
      start = (rangeRaw['min'] ?? 0).toDouble();
      end = (rangeRaw['max'] ?? start).toDouble();
    }

    final meaning = (json['meaning'] ?? '').toString();

    final colorStr = (json['color'] ?? '#FF0000').toString();
    final color = _parseHexColor(colorStr);

    return RangeSection(start: start, end: end, meaning: meaning, color: color);
  }
}

Color _parseHexColor(String hex) {
  var cleaned = hex.replaceAll('#', '').trim();
  if (cleaned.length == 6) {
    cleaned = 'FF$cleaned'; 
  } else if (cleaned.length == 3) {
    final r = cleaned[0] * 2;
    final g = cleaned[1] * 2;
    final b = cleaned[2] * 2;
    cleaned = 'FF$r$g$b';
  } else if (cleaned.length == 8) {
    // already ARGB/RGBA depending on format; we'll treat as ARGB
  } else {
    cleaned = 'FFFF0000';
  }
  return Color(int.parse(cleaned, radix: 16));
}
