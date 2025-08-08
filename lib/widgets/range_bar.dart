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
    super.key,
    required this.sections,
    required this.value,
    this.height = 48.0,
  });

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
      for (var i = 0; i < sorted.length; i++) {
        final s = sorted[i];
        final segLen = (s.end - s.start).clamp(0.0, double.infinity);
        final segWidth = (segLen / totalSpan) * fullWidth;

        segmentWidgets.add(Container(
          width: segWidth,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: s.color,
            border: Border(
              right: i < sorted.length - 1
                  ? const BorderSide(color: Colors.white24, width: 1)
                  : BorderSide.none,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              s.meaning,
              style: TextStyle(
                color: _bestContrastColor(s.color),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
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
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // value bubble
                  Positioned(
                    left: (markerLeft - bubbleWidth / 2).clamp(0.0, fullWidth - bubbleWidth),
                    top: -36,
                    child: Container(
                      width: bubbleWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        value.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          // Min / Max labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minStart.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  maxEnd.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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