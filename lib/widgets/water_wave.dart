import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterWave extends StatefulWidget {
  final double percentage;
  
  const WaterWave({
    super.key,
    required this.percentage,
  });

  @override
  State<WaterWave> createState() => _WaterWaveState();
}

class _WaterWaveState extends State<WaterWave> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            animationValue: _animationController.value,
            percentage: widget.percentage,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Container(),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double percentage;
  final Color color;
  
  WavePainter({
    required this.animationValue,
    required this.percentage,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path();
    
    final y = (1 - percentage) * height;
    
    final wavePeriod = width * 0.5;
    final waveHeight = 10.0;
    
    path.moveTo(0, y);
    
    for (double i = 0; i < width; i++) {
      path.lineTo(
        i,
        y + math.sin((i / wavePeriod) * 2 * math.pi + animationValue * 2 * math.pi) * waveHeight,
      );
    }
    
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.percentage != percentage ||
           oldDelegate.color != color;
  }
}
