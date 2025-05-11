import 'package:flutter/material.dart';

class MonthlyChart extends StatelessWidget {
  const MonthlyChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final monthData = List.generate(30, (index) {
      final day = index + 1;
      final amount = 1500 + (day % 7) * 200;
      return {'day': day, 'amount': amount, 'goal': 2000};
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final chartHeight = constraints.maxHeight * 0.6;

        return Container(
          height: chartHeight.clamp(150.0, 250.0), // Responsive height
          padding: EdgeInsets.all(isTablet ? 16.0 : 8.0),
          child: CustomPaint(
            painter: MonthlyChartPainter(
              data: monthData,
              lineColor: Theme.of(context).colorScheme.primary,
              goalLineColor: Colors.red,
              isTablet: isTablet,
            ),
            size: Size(constraints.maxWidth, chartHeight),
          ),
        );
      },
    );
  }
}

class MonthlyChartPainter extends CustomPainter {
  final List<Map<String, int>> data;
  final Color lineColor;
  final Color goalLineColor;
  final bool isTablet;

  MonthlyChartPainter({
    required this.data,
    required this.lineColor,
    required this.goalLineColor,
    required this.isTablet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Responsive scaling
    final strokeWidth = isTablet ? 2.5 : 2.0;
    final goalStrokeWidth = isTablet ? 1.5 : 1.0;
    final pointRadius = isTablet ? 4.0 : 3.0;
    final maxYValue = 3000.0; // Maximum value for scaling
    final pointInterval = isTablet ? 3 : 5; // Less clutter on tablets

    // Draw goal line
    final goalPaint =
        Paint()
          ..color = goalLineColor.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = goalStrokeWidth;

    final goalY = height - (height * (data[0]['goal']! / maxYValue));
    canvas.drawLine(Offset(0, goalY), Offset(width, goalY), goalPaint);

    // Draw data line
    final linePaint =
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = width * (i / (data.length - 1));
      final y = height - (height * (data[i]['amount']! / maxYValue));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw data points
    final pointPaint =
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = width * (i / (data.length - 1));
      final y = height - (height * (data[i]['amount']! / maxYValue));

      // Draw points at intervals to avoid clutter
      if (i % pointInterval == 0) {
        canvas.drawCircle(Offset(x, y), pointRadius, pointPaint);
      }
    }

    // Optional: Draw day labels for every 5th day
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < data.length; i += 5) {
      final x = width * (i / (data.length - 1));
      final textSpan = TextSpan(
        text: '${data[i]['day']}',
        style: TextStyle(color: lineColor, fontSize: isTablet ? 12.0 : 10.0),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant MonthlyChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.goalLineColor != goalLineColor ||
        oldDelegate.isTablet != isTablet;
  }
}
