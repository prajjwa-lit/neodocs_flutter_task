import 'package:flutter/material.dart';
import '../models/range_section.dart';
import 'dart:math' as math;

class RangeBar extends StatelessWidget {
  final List<RangeSection> sections;
  final double value;
  final double height;

  const RangeBar({
    super.key,
    required this.sections,
    required this.value,
    this.height = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = List<RangeSection>.from(sections)
      ..sort((a, b) => a.start.compareTo(b.start));
    final minStart = sorted.first.start;
    final maxEnd = sorted.map((s) => s.end).reduce(math.max);
    final totalSpan = maxEnd - minStart;

    if (totalSpan <= 0) {
      return const Center(child: Text('Invalid range data'));
    }

    return LayoutBuilder(builder: (context, constraints) {
      final fullWidth = constraints.maxWidth;

      final List<Widget> segmentWidgets = [];
      final List<Widget> labelWidgets = [];

    
      final int totalIntSpan = (maxEnd - minStart).toInt();

      final List<int> segmentStartsPx = sorted.map((s) {
        final ratio = (s.start - minStart) / totalIntSpan;
        return (ratio * fullWidth).round();
      }).toList();

      segmentStartsPx.add(fullWidth.round());

      for (var i = 0; i < sorted.length; i++) {
        final leftPx = segmentStartsPx[i];
        final rightPx = segmentStartsPx[i + 1];
        final segWidth = rightPx - leftPx;

        segmentWidgets.add(Positioned(
          left: leftPx.toDouble(),
          top: 0,
          child: SizedBox(
            width: segWidth.toDouble(),
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: sorted[i].color,
              ),
            ),
          ),
        ));

        if (i > 0) {
          final isUp = i % 2 != 0;
          labelWidgets.add(
            Positioned(
              left: leftPx.toDouble() - 20,
              top: isUp ? 5 : height + 25,
              child: SizedBox(
                width: 40,
                child: Text(
                  sorted[i].start.toInt().toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }
      }

      labelWidgets.add(
        Positioned(
          left: -25,
          top: height + 10,
          child: SizedBox(
            width: 40,
            child: Text(
              minStart.toInt().toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
      labelWidgets.add(
        Positioned(
          right: -27,
          top: height + 8,
          child: SizedBox(
            width: 40,
            child: Text(
              maxEnd.toInt().toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );

      final relative = ((value - minStart) / totalSpan);
      final clampedRelative =
          relative.isFinite ? relative.clamp(0.0, 1.0) : 0.0;
      final markerLeft = clampedRelative * fullWidth;
      final triangleWidth = 25.0;
      final triangleHeight = 15.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height + 48,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(height / 2),
                    child: SizedBox(
                      width: fullWidth,
                      height: height,
                      child: Stack(
                        children: segmentWidgets,
                      ),
                    ),
                  ),
                ),
  
                Positioned(
                  left: (markerLeft - triangleWidth / 2)
                      .clamp(0.0, fullWidth - triangleWidth),
                  top: 24 + height,
                  child: CustomPaint(
                    size: Size(triangleWidth, triangleHeight),
                    painter: TrianglePainter(),
                  ),
                ),
    
                Positioned(
                  left: (markerLeft - 20)
                      .clamp(0.0, fullWidth - 40),
                  top: 24 + height + triangleHeight + 4,
                  child: SizedBox(
                    width: 40,
                    child: Text(
                      value.toInt().toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                ...labelWidgets,
              ],
            ),
          ),
        ],
      );
    });
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => false;
}
