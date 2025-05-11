import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  bool _isNavigating = false;
  int _currentPage = 0;
  Offset _touchOffset = Offset.zero;

  // Updated water-themed colors for Hydromate
  final Color _primaryColor = const Color(0xFF2196F3); // Vibrant water blue
  final Color _secondaryColor = const Color(0xFFE3F2FD); // Soft blue background
  final Color _accentColor = const Color.fromARGB(
    255,
    44,
    120,
    158,
  ); // Light blue accent
  final Color _lightColor = const Color(0xFFFFFFFF); // White
  final Color _darkAccentColor = const Color(0xFF1565C0); // Deep blue

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _waterAnimationController;
  late AnimationController _arcAnimationController;

  // Enhanced onboarding data with Hydromate branding
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'animationPath': 'images/goals.png', // Update to actual .png file path
      'title': 'SET YOUR GOALS',
      'description':
          'Customize your daily water intake based on your lifestyle, body, and environment for optimal hydration.',
      'iconData': Icons.water_drop,
      'bgColor': const Color(0xFF2196F3),
    },
    {
      'animationPath': 'images/alerts.png', // Update to actual .png file path
      'title': 'SMART ALERTS',
      'description':
          'Get personalized reminders that adapt to your schedule and drinking habits to keep you hydrated.',
      'iconData': Icons.notifications_active,
      'bgColor': const Color(0xFF42A5F5),
    },
    {
      'animationPath': 'images/tracking.gif', // Update to actual .png file path
      'title': 'TRACKING',
      'description':
          'Monitor your hydration journey with intuitive charts and detailed analytics to stay motivated.',
      'iconData': Icons.bar_chart,
      'bgColor': const Color(0xFF64B5F6),
    },
    {
      'animationPath': 'images/wellness.png', // Update to actual .png file path
      'title': 'ENHANCE WELLNESS',
      'description':
          'Learn how proper hydration boosts energy, improves focus, and enhances your overall health.',
      'iconData': Icons.favorite,
      'bgColor': const Color(0xFF90CAF9),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page?.round() ?? 0;
      });
      _backgroundAnimationController.forward(from: 0.0);
      _arcAnimationController.forward(from: 0.0);
    });

    // Initialize animation controllers
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _waterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _arcAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundAnimationController.dispose();
    _buttonAnimationController.dispose();
    _waterAnimationController.dispose();
    _arcAnimationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);
    HapticFeedback.mediumImpact();

    // Mark that onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            var scaleAnimation = Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: curve));
            return SlideTransition(
              position: offsetAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final horizontalPadding = screenWidth * 0.08;
    final verticalPadding = screenHeight * 0.04;

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _touchOffset = Offset(
                _touchOffset.dx + details.delta.dx * 0.1,
                _touchOffset.dy + details.delta.dy * 0.1,
              );
            });
          },
          child: Scaffold(
            body: AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                final currentColor =
                    _onboardingData[_currentPage]['bgColor'] as Color;
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            currentColor.withOpacity(0.9),
                            Color.lerp(currentColor, _secondaryColor, 0.8) ??
                                _secondaryColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _waterAnimationController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: WaterBackgroundPainter(
                              animation: _waterAnimationController.value,
                              baseColor: currentColor,
                            ),
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            SizedBox(height: 13.h),
                            Expanded(
                              child: PageView.builder(
                                controller: _controller,
                                itemCount: _onboardingData.length,
                                itemBuilder: (context, index) {
                                  return _buildResponsivePage(
                                    context,
                                    animationPath:
                                        _onboardingData[index]['animationPath'],
                                    title: _onboardingData[index]['title'],

                                    description:
                                        _onboardingData[index]['description'],
                                    iconData:
                                        _onboardingData[index]['iconData'],
                                    color: _onboardingData[index]['bgColor'],
                                    isActive: _currentPage == index,
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalPadding,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 5.h,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        _onboardingData.length,
                                        (index) => AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 5.w,
                                          ),
                                          height: 5.h,
                                          width:
                                              _currentPage == index
                                                  ? 30.w
                                                  : 10.w,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                _onboardingData[_currentPage]['bgColor'],
                                                _accentColor,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5.r,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    _onboardingData[_currentPage]['bgColor']
                                                        .withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).animate().scale(
                                      duration: 500.ms,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 25.h : 35.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            _isNavigating
                                                ? null
                                                : () {
                                                  HapticFeedback.lightImpact();
                                                  _buttonAnimationController
                                                      .forward(from: 0.0);
                                                  _navigateToLogin();
                                                },
                                        child: AnimatedBuilder(
                                          animation: _buttonAnimationController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale:
                                                  1.0 -
                                                  (_buttonAnimationController
                                                          .value *
                                                      0.1),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w,
                                                  vertical: 12.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _lightColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                  border: Border.all(
                                                    color: _lightColor
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  "SKIP",
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        isSmallScreen
                                                            ? 15.sp
                                                            : 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: _lightColor,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).animate().fadeIn(
                                          duration: 900.ms,
                                          delay: 300.ms,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:
                                            _isNavigating
                                                ? null
                                                : () {
                                                  HapticFeedback.lightImpact();
                                                  _buttonAnimationController
                                                      .forward(from: 0.0);
                                                  if (_currentPage ==
                                                      _onboardingData.length -
                                                          1) {
                                                    _navigateToLogin();
                                                  } else {
                                                    _controller.nextPage(
                                                      duration: const Duration(
                                                        milliseconds: 400,
                                                      ),
                                                      curve:
                                                          Curves.easeOutQuint,
                                                    );
                                                  }
                                                },
                                        child: AnimatedBuilder(
                                              animation:
                                                  _buttonAnimationController,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale:
                                                      1.0 -
                                                      (_buttonAnimationController
                                                              .value *
                                                          0.05),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          _onboardingData[_currentPage]['bgColor'],
                                                          _accentColor,
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            40.r,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              _onboardingData[_currentPage]['bgColor']
                                                                  .withOpacity(
                                                                    0.5,
                                                                  ),
                                                          blurRadius: 15,
                                                          offset: const Offset(
                                                            0,
                                                            5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          _currentPage ==
                                                                  _onboardingData
                                                                          .length -
                                                                      1
                                                              ? 35.w
                                                              : 28.w,
                                                      vertical:
                                                          isSmallScreen
                                                              ? 14.h
                                                              : 18.h,
                                                    ),
                                                    child:
                                                        _isNavigating
                                                            ? SizedBox(
                                                              width: 24.w,
                                                              height: 24.h,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth:
                                                                    2.5,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                      Color
                                                                    >(
                                                                      _lightColor,
                                                                    ),
                                                              ),
                                                            )
                                                            : Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  _currentPage ==
                                                                          _onboardingData.length -
                                                                              1
                                                                      ? "START NOW"
                                                                      : "NEXT",
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        isSmallScreen
                                                                            ? 14.sp
                                                                            : 16.sp,
                                                                    color:
                                                                        _lightColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    letterSpacing:
                                                                        1.5,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10.w,
                                                                ),
                                                                Icon(
                                                                  _currentPage ==
                                                                          _onboardingData.length -
                                                                              1
                                                                      ? Icons
                                                                          .play_circle_fill
                                                                      : Icons
                                                                          .arrow_forward_rounded,
                                                                  color:
                                                                      _lightColor,
                                                                  size:
                                                                      isSmallScreen
                                                                          ? 18.sp
                                                                          : 20.sp,
                                                                ),
                                                              ],
                                                            ),
                                                  ),
                                                );
                                              },
                                            )
                                            .animate()
                                            .scale(
                                              duration: 900.ms,
                                              delay: 400.ms,
                                              curve: Curves.easeOut,
                                            )
                                            .animate(
                                              onPlay:
                                                  (controller) => controller
                                                      .repeat(reverse: true),
                                            )
                                            .scale(
                                              duration: 1800.ms,
                                              begin: const Offset(1.0, 1.0),
                                              end: const Offset(1.06, 1.06),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsivePage(
    BuildContext context, {
    required String animationPath,
    required String title,
    required String description,
    required IconData iconData,
    required Color color,
    required bool isActive,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final horizontalPadding = screenWidth * 0.08;
    final verticalPadding = screenHeight * 0.03;
    final imageHeight =
        isSmallScreen ? screenHeight * 0.28 : screenHeight * 0.32;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildAnimationSection(
                    context,
                    animationPath: animationPath,
                    iconData: iconData,
                    color: color,
                    isActive: isActive,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildContentSection(
                      context,
                      title: title,
                      description: description,
                      color: color,
                      isActive: isActive,
                      isSmallScreen: isSmallScreen,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimationSection(
                    context,
                    animationPath: animationPath,
                    iconData: iconData,
                    color: color,
                    isActive: isActive,
                    height: imageHeight,
                  ),
                  SizedBox(height: isSmallScreen ? 25.h : 35.h),
                  _buildContentSection(
                    context,
                    title: title,
                    description: description,
                    color: color,
                    isActive: isActive,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAnimationSection(
    BuildContext context, {
    required String animationPath,
    required IconData iconData,
    required Color color,
    required bool isActive,
    double? height,
  }) {
    return Container(
          height: height ?? 240.h,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: _darkAccentColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.7),
                          color.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: _lightColor.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: 1.15,
                child: Transform.translate(
                  offset: Offset(_touchOffset.dx * 0.2, _touchOffset.dy * 0.2),
                  child: Image.asset(
                    animationPath,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              if (isActive)
                CustomPaint(
                  painter: ArcProgressPainter(
                    progress: _arcAnimationController.value,
                    color: color,
                  ),
                ),
            ],
          ),
        )
        .animate(target: isActive ? 1 : 0)
        .slideY(
          duration: 900.ms,
          begin: 0.3,
          end: 0,
          curve: Curves.easeOutQuint,
        )
        .animate(
          onPlay:
              (controller) =>
                  controller.repeat(period: const Duration(milliseconds: 2500)),
        )
        .shimmer(duration: 2500.ms, color: _lightColor.withOpacity(0.3));
  }

  Widget _buildContentSection(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required bool isActive,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Column(
              children: [
                Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, _accentColor]),
                    borderRadius: BorderRadius.circular(3.r),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 22.sp : 26.sp,
                    fontWeight: FontWeight.w800,
                    color: _lightColor,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: _darkAccentColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ],
            )
            .animate(target: isActive ? 1 : 0)
            .fadeIn(duration: 900.ms, delay: 200.ms)
            .slideY(begin: 0.3, end: 0, duration: 900.ms),
        SizedBox(height: 15.h),

        Container(
              padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: _lightColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: _lightColor.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _darkAccentColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 15.sp : 16.sp,
                  fontWeight: FontWeight.w400,
                  color: _lightColor.withOpacity(0.95),
                  height: 1.7,
                  letterSpacing: 0.4,
                ),
              ),
            )
            .animate(target: isActive ? 1 : 0)
            .fadeIn(duration: 900.ms, delay: 400.ms)
            .slideY(begin: 0.3, end: 0, duration: 900.ms)
            .animate(
              onPlay:
                  (controller) => controller.repeat(
                    period: const Duration(milliseconds: 2800),
                  ),
            )
            .shimmer(duration: 2800.ms, color: _accentColor.withOpacity(0.25)),
      ],
    );
  }
}

// Arc progress painter for animation section
class ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  ArcProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ArcProgressPainter oldDelegate) => true;
}

// Optimized water background painter
class WaterBackgroundPainter extends CustomPainter {
  final double animation;
  final Color baseColor;

  WaterBackgroundPainter({required this.animation, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = baseColor.withOpacity(0.25)
          ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height;
    final width = size.width;

    path.moveTo(0, height * 0.65);

    for (double i = 0; i <= width; i += 4) {
      path.lineTo(
        i,
        height * 0.65 + sin((i * 0.006) + animation * 2 * pi) * 18,
      );
    }

    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);

    final paint2 =
        Paint()
          ..color = baseColor.withOpacity(0.15)
          ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, height * 0.7);

    for (double i = 0; i <= width; i += 4) {
      path2.lineTo(
        i,
        height * 0.7 + sin((i * 0.005) + animation * 2 * pi + 1.2) * 22,
      );
    }

    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WaterBackgroundPainter oldDelegate) => true;
}
