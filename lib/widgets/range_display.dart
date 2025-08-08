// lib/widgets/range_display.dart
import 'package:flutter/material.dart';
import '../models/range_section.dart';
import 'range_bar.dart';
import 'range_legend.dart';

class RangeDisplay extends StatelessWidget {
  final List<RangeSection> sections;
  final double currentValue;
  final String? currentRange;

  const RangeDisplay({
    Key? key,
    required this.sections,
    required this.currentValue,
    this.currentRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentRange != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Current Range: $currentRange',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: 600,
              child: RangeBar(
                sections: sections,
                value: currentValue,
              ),
            ),
            const SizedBox(height: 16),
            RangeLegend(sections: sections),
          ],
        ),
      ),
    );
  }
}
