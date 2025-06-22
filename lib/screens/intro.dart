import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:water_tracker/MainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionScreen extends StatefulWidget {
  final bool skipToLogin;

  const IntroductionScreen({super.key, this.skipToLogin = false});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  bool _isTapped = false;
  Offset _logoOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    // Setup wave animation with optimized duration
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Navigate to appropriate screen after splash or on tap
    Timer(const Duration(seconds: 2), () {
      if (mounted && !_isTapped) {
        if (widget.skipToLogin) {
          _navigateToLogin();
        } else {
          _navigateToOnboarding();
        }
      }
    });
  }

  void _navigateToOnboarding() async {
    if (!_isTapped) {
      _isTapped = true;

      // Mark that onboarding has been shown
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _navigateToLogin() {
    if (!_isTapped) {
      _isTapped = true;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.skipToLogin ? _navigateToLogin : _navigateToOnboarding,
          onPanUpdate: (details) {
            setState(() {
              _logoOffset = Offset(
                _logoOffset.dx + details.delta.dx * 0.2,
                _logoOffset.dy + details.delta.dy * 0.2,
              );
            });
          },
          child: Scaffold(
            body: AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Optimized wave background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WavePainter(
                            waveAnimation: _waveAnimation.value,
                            waveColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),

                      // Particle animation for water droplets
                      Positioned.fill(
                        child: ParticleAnimation(
                          particleCount: 15,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),

                      // Floating bubbles
                      Positioned.fill(
                        child: BubbleAnimation(
                          color: Colors.white.withOpacity(0.25),
                          bubbleCount: 12,
                        ),
                      ),

                      // Enhanced typography
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25.w,
                            vertical: 50.h,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "HYDRATE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34.sp,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 3,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "NOW",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 34.sp,
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: 3,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Icon(
                                            Icons.water_drop_rounded,
                                            color: Colors.white,
                                            size: 34.sp,
                                          )
                                          .animate(
                                            onPlay:
                                                (controller) => controller
                                                    .repeat(reverse: true),
                                          )
                                          .scaleXY(
                                            begin: 1.0,
                                            end: 1.3,
                                            duration: 1200.ms,
                                          ),
                                    ],
                                  )
                                  .animate()
                                  .slideY(
                                    duration: 700.ms,
                                    begin: 1,
                                    end: 0,
                                    curve: Curves.easeOutCubic,
                                  )
                                  .fadeIn(duration: 700.ms),

                              SizedBox(height: 12.h),

                              Text(
                                    "Your Daily Water Companion",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      letterSpacing: 0.8,
                                    ),
                                  )
                                  .animate()
                                  .slideY(
                                    duration: 700.ms,
                                    delay: 200.ms,
                                    begin: 1,
                                    end: 0,
                                    curve: Curves.easeOutCubic,
                                  )
                                  .fadeIn(duration: 700.ms, delay: 200.ms),

                              SizedBox(height: 25.h),

                              SizedBox(
                                width: 180.w,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.25,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  minHeight: 4.h,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ).animate().fadeIn(
                                duration: 400.ms,
                                delay: 400.ms,
                              ),

                              SizedBox(height: 15.h),

                           
                                  
                                  
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Existing classes remain unchanged
class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color waveColor;

  WavePainter({required this.waveAnimation, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = waveColor
          ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height;
    final width = size.width;

    path.moveTo(0, height * 0.6);

    for (double i = 0; i <= width; i += 2) {
      path.lineTo(i, height * 0.6 + sin(i * 0.008 + waveAnimation) * 12);
    }

    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);

    final paint2 =
        Paint()
          ..color = waveColor.withOpacity(0.4)
          ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, height * 0.65);

    for (double i = 0; i <= width; i += 2) {
      path2.lineTo(
        i,
        height * 0.65 + sin((i * 0.012) + waveAnimation + 1.5) * 10,
      );
    }

    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

class ParticleAnimation extends StatefulWidget {
  final Color color;
  final int particleCount;

  const ParticleAnimation({
    super.key,
    required this.color,
    this.particleCount = 10,
  });

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Map<String, dynamic>> particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final random = Random();
    for (int i = 0; i < widget.particleCount; i++) {
      particles.add({
        'position': Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 800,
        ),
        'size': random.nextDouble() * 8 + 4,
        'speed': random.nextDouble() * 1.5 + 0.5,
        'angle': random.nextDouble() * 2 * pi,
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            animation: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;
  final double animation;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final position = particle['position'] as Offset;
      final size = particle['size'] as double;
      final speed = particle['speed'] as double;
      final angle = particle['angle'] as double;

      final animatedPosition = Offset(
        position.dx + cos(angle) * animation * 100 * speed,
        position.dy + sin(angle) * animation * 100 * speed,
      );

      canvas.drawCircle(animatedPosition, size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class BubbleAnimation extends StatefulWidget {
  final Color color;
  final int bubbleCount;

  const BubbleAnimation({
    super.key,
    required this.color,
    this.bubbleCount = 15,
  });

  @override
  State<BubbleAnimation> createState() => _BubbleAnimationState();
}

class _BubbleAnimationState extends State<BubbleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Map<String, dynamic>> bubbles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final random = Random();
    for (int i = 0; i < widget.bubbleCount; i++) {
      bubbles.add({
        'position': Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 800 + 100,
        ),
        'size': random.nextDouble() * 12 + 4,
        'speed': random.nextDouble() * 1.5 + 0.8,
        'delay': random.nextDouble() * 8,
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BubblePainter(
            bubbles: bubbles,
            animation: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class BubblePainter extends CustomPainter {
  final List<Map<String, dynamic>> bubbles;
  final double animation;
  final Color color;

  BubblePainter({
    required this.bubbles,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final position = bubble['position'] as Offset;
      final bubbleSize = bubble['size'] as double;
      final speed = bubble['speed'] as double;
      final delay = bubble['delay'] as double;

      final animatedPosition = Offset(
        position.dx + sin(animation * 2 * pi + delay) * 10,
        (position.dy - ((animation * 400 * speed) + (delay * 80))) %
                (size.height + 200) -
            100,
      );

      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;

      canvas.drawCircle(animatedPosition, bubbleSize, paint);

      final highlightPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.5)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          animatedPosition.dx - bubbleSize * 0.3,
          animatedPosition.dy - bubbleSize * 0.3,
        ),
        bubbleSize * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) => true;
}
