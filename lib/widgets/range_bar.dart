// lib/widgets/range_bar.dart
import 'package:flutter/material.dart';
import '../models/range_section.dart';
import 'dart:math' as math;

/// A self-contained widget that draws a horizontal bar made of segments
/// and overlays a marker for the given value (value can be outside the bounds).
class RangeBar extends StatelessWidget {
  final List<RangeSection> sections;
  final double value;
  final double height;

  const RangeBar({
    Key? key,
    required this.sections,
    required this.value,
    this.height = 48.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = List<RangeSection>.from(sections)..sort((a, b) => a.start.compareTo(b.start));
    final minStart = sorted.first.start;
    final maxEnd = sorted.map((s) => s.end).reduce(math.max);
    final totalSpan = maxEnd - minStart;

    if (totalSpan <= 0) {
      return const Center(child: Text('Invalid range data'));
    }

    return LayoutBuilder(builder: (context, constraints) {
      final fullWidth = constraints.maxWidth;

      // Build segments as Widgets with proportional width
      final List<Widget> segmentWidgets = [];
      for (var s in sorted) {
        final segLen = (s.end - s.start).clamp(0.0, double.infinity);
        final segWidth = (segLen / totalSpan) * fullWidth;

        segmentWidgets.add(Container(
          width: segWidth,
          height: height,
          alignment: Alignment.center,
          // Text inside uses contrasting color for readability
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              s.meaning,
              style: TextStyle(
                color: _bestContrastColor(s.color),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          decoration: BoxDecoration(color: s.color),
        ));
      }

      // compute marker position (clamped for display)
      final relative = ((value - minStart) / totalSpan);
      final clampedRelative = relative.isFinite ? relative.clamp(0.0, 1.0) : 0.0;
      final markerLeft = clampedRelative * fullWidth;
      final markerWidth = 2.0;
      final bubbleWidth = 80.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // bar with overlayed marker
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(children: segmentWidgets),
              // vertical marker line
              Positioned(
                left: (markerLeft - markerWidth / 2).clamp(0.0, fullWidth - markerWidth),
                top: -8,
                child: Container(
                  width: markerWidth,
                  height: height + 16,
                  color: Colors.black,
                ),
              ),
              // small bubble that shows the value; positioned above the marker
              Positioned(
                left: (markerLeft - bubbleWidth / 2).clamp(0.0, fullWidth - bubbleWidth),
                top: -36,
                child: Container(
                  width: bubbleWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    value.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Min / Max labels under the bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minStart.toString()),
              Text(maxEnd.toString()),
            ],
          ),
        ],
      );
    });
  }

  /// Pick readable color (black/white) based on background luminance
  Color _bestContrastColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
