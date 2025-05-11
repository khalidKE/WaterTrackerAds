import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterProgress extends StatefulWidget {
  final int progress;
  final int goal;
  final bool isExpanded;

  const WaterProgress({
    super.key,
    required this.progress,
    required this.goal,
    this.isExpanded = false,
  });

  @override
  State<WaterProgress> createState() => WaterProgressState();
}

class WaterProgressState extends State<WaterProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fillAnimation;

  double _currentFillPercentage = 0.0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _waveAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Only start animation if progress > 0 to save resources
    if (widget.progress > 0) {
      _animationController.repeat();
    }

    // Initialize fill percentage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFillPercentage();
    });
  }

  @override
  void didUpdateWidget(WaterProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _updateFillPercentage();
      // Start or stop animation based on progress
      if (widget.progress > 0 && !_animationController.isAnimating) {
        _animationController.repeat();
      } else if (widget.progress == 0 && _animationController.isAnimating) {
        _animationController.stop();
      }
    }
  }

  void _updateFillPercentage() {
    final percentage = (widget.progress / widget.goal).clamp(0.0, 1.0);
    setState(() {
      _currentFillPercentage = percentage;
    });
  }

  void triggerWaveAnimation() {
    if (!_isAnimating && widget.progress > 0) {
      _isAnimating = true;
      _animationController.stop();
      _animationController.duration = const Duration(milliseconds: 800);
      _animationController.forward(from: 0.0).then((_) {
        _animationController.duration = const Duration(seconds: 2);
        if (widget.progress > 0) {
          _animationController.repeat();
        }
        _isAnimating = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.progress / widget.goal).clamp(0.0, 1.0);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Fixed size for the circle regardless of expanded state
    const circleSize = 150.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress indicator with fixed size
              SizedBox(
                height: circleSize,
                width: circleSize,
                child: CustomPaint(
                  painter: WaveProgressPainter(
                    animationValue: _waveAnimation.value,
                    percentage: _currentFillPercentage,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor:
                        isDarkMode
                            ? Colors.grey.shade800
                            : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                    isAnimating: _isAnimating,
                  ),
                ),
              ),

              // Percentage text with FittedBox to prevent overflow
              SizedBox(
                height:
                    circleSize * 0.5, // Constrain height to fit within circle
                width: circleSize * 0.8, // Constrain width for text
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              percentage > 0.5 && !isDarkMode
                                  ? Colors.white
                                  : null,
                        ),
                      ),
                      Text(
                        '${widget.progress} / ${widget.goal} ml',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              percentage > 0.5 && !isDarkMode
                                  ? Colors.white.withOpacity(0.9)
                                  : Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaveProgressPainter extends CustomPainter {
  final double animationValue;
  final double percentage;
  final Color color;
  final Color backgroundColor;
  final bool isAnimating;

  WaveProgressPainter({
    required this.animationValue,
    required this.percentage,
    required this.color,
    required this.backgroundColor,
    this.isAnimating = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final radius = math.min(width, height) / 2;
    final center = Offset(width / 2, height / 2);

    // Draw background circle
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw border
    final borderPaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);

    if (percentage == 0) return;

    // Create a clipping path for the circle
    final clipPath =
        Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // Calculate wave parameters
    final waveHeight = isAnimating ? radius * 0.15 : radius * 0.1;
    final waveCount = 2.0;
    final baseHeight = height - percentage * height;

    // Create wave path
    final wavePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePath.moveTo(0, baseHeight);

    for (double i = 0; i <= width; i++) {
      final dx = i;
      final dy =
          baseHeight +
          math.sin(
                (i / width * waveCount * 2 * math.pi) +
                    (animationValue * 2 * math.pi),
              ) *
              waveHeight;
      wavePath.lineTo(dx, dy);
    }

    // Complete the path
    wavePath.lineTo(width, height);
    wavePath.lineTo(0, height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);

    // Add a second wave for more realistic effect
    final wave2Paint =
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    final wave2Path = Path();
    wave2Path.moveTo(0, baseHeight);

    for (double i = 0; i <= width; i++) {
      final dx = i;
      final dy =
          baseHeight +
          math.sin(
                (i / width * waveCount * 2 * math.pi) +
                    (animationValue * 2 * math.pi + math.pi / 2),
              ) *
              waveHeight *
              0.7;
      wave2Path.lineTo(dx, dy);
    }

    // Complete the path
    wave2Path.lineTo(width, height);
    wave2Path.lineTo(0, height);
    wave2Path.close();

    canvas.drawPath(wave2Path, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant WaveProgressPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.percentage != percentage ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.isAnimating != isAnimating;
  }
}
