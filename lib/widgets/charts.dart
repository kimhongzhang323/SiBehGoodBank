import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Custom line chart widget for analytics
class FlowChart extends StatelessWidget {
  final List<List<double>> dataLines;
  final List<Color> lineColors;
  final double height;
  final bool showVerticalBars;

  const FlowChart({
    super.key,
    required this.dataLines,
    required this.lineColors,
    this.height = 120,
    this.showVerticalBars = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _FlowChartPainter(
          dataLines: dataLines,
          lineColors: lineColors,
          showVerticalBars: showVerticalBars,
        ),
      ),
    );
  }
}

class _FlowChartPainter extends CustomPainter {
  final List<List<double>> dataLines;
  final List<Color> lineColors;
  final bool showVerticalBars;

  _FlowChartPainter({
    required this.dataLines,
    required this.lineColors,
    required this.showVerticalBars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw data lines
    for (var lineIndex = 0; lineIndex < dataLines.length; lineIndex++) {
      final data = dataLines[lineIndex];
      final color = lineColors[lineIndex % lineColors.length];
      
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final pointSpacing = size.width / (data.length - 1);

      for (var i = 0; i < data.length; i++) {
        final x = i * pointSpacing;
        final y = size.height - (data[i] * size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          // Create smooth curves using cubic bezier
          final prevX = (i - 1) * pointSpacing;
          final prevY = size.height - (data[i - 1] * size.height);
          final controlX1 = prevX + pointSpacing * 0.4;
          final controlX2 = x - pointSpacing * 0.4;
          path.cubicTo(controlX1, prevY, controlX2, y, x, y);
        }
      }

      canvas.drawPath(path, linePaint);

      // Draw gradient fill below the line
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw vertical bars at the end
    if (showVerticalBars) {
      final barWidth = 8.0;
      final barSpacing = 12.0;
      final startX = size.width - (barWidth * 3 + barSpacing * 2);
      
      final barColors = [
        AppColors.accent,
        AppColors.pastelBlue,
        AppColors.lavender,
      ];
      
      final barHeights = [0.6, 0.8, 0.5];

      for (var i = 0; i < 3; i++) {
        final barPaint = Paint()
          ..color = barColors[i]
          ..style = PaintingStyle.fill;

        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            startX + i * (barWidth + barSpacing),
            size.height * (1 - barHeights[i]),
            barWidth,
            size.height * barHeights[i],
          ),
          const Radius.circular(4),
        );

        canvas.drawRRect(barRect, barPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mini sparkline chart for revenue analysis
class MiniLineChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final double height;
  final double width;
  final bool showTooltip;
  final String? tooltipValue;
  final int? highlightIndex;

  const MiniLineChart({
    super.key,
    required this.data,
    this.lineColor = AppColors.accentBlue,
    this.height = 40,
    this.width = 100,
    this.showTooltip = false,
    this.tooltipValue,
    this.highlightIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _MiniLineChartPainter(
          data: data,
          lineColor: lineColor,
          showTooltip: showTooltip,
          tooltipValue: tooltipValue,
          highlightIndex: highlightIndex,
        ),
      ),
    );
  }
}

class _MiniLineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final bool showTooltip;
  final String? tooltipValue;
  final int? highlightIndex;

  _MiniLineChartPainter({
    required this.data,
    required this.lineColor,
    this.showTooltip = false,
    this.tooltipValue,
    this.highlightIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final pointSpacing = size.width / (data.length - 1);

    double? highlightX;
    double? highlightY;

    for (var i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height - (data[i] * size.height * 0.8) - size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      if (highlightIndex != null && i == highlightIndex) {
        highlightX = x;
        highlightY = y;
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw highlight point and tooltip
    if (highlightX != null && highlightY != null) {
      // Point
      final pointPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(highlightX, highlightY), 4, pointPaint);

      // Outer ring
      final ringPaint = Paint()
        ..color = lineColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(highlightX, highlightY), 7, ringPaint);

      // Tooltip
      if (showTooltip && tooltipValue != null) {
        final tooltipPaint = Paint()
          ..color = AppColors.textPrimary
          ..style = PaintingStyle.fill;

        final tooltipRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(highlightX, highlightY - 20),
            width: 50,
            height: 20,
          ),
          const Radius.circular(4),
        );

        canvas.drawRRect(tooltipRect, tooltipPaint);

        final textPainter = TextPainter(
          text: TextSpan(
            text: tooltipValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            highlightX - textPainter.width / 2,
            highlightY - 20 - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
