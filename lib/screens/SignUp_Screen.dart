import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water_tracker/MainScreen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Apply subtle haptic feedback when screen loads
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Please correct the errors in the form';
      });
      return;
    }

    // Apply haptic feedback for interaction
    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Firebase authentication
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // Prevent back navigation to signup
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage =
            e.code == 'email-already-in-use'
                ? 'This email is already registered.'
                : e.code == 'weak-password'
                ? 'Password is too weak.'
                : e.message ?? 'Failed to create account.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0288D1),
                  Color(0xFF03A9F4),
                  Color(0xFF4FC3F7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Animated water background
                Positioned.fill(
                  child: CustomPaint(
                    painter: SignupBackgroundPainter(
                      animation: _backgroundAnimationController.value,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),

                child!,
              ],
            ),
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo with water droplet
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hydromate",
                            style: GoogleFonts.montserrat(
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 5),
                          Icon(
                            Icons.water_drop_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .slideY(
                        begin: -0.2,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOutQuint,
                      ),

                  const SizedBox(height: 10),

                  Text(
                    "Create Your Account",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms),

                  const SizedBox(height: 30),

                  // Modern glassmorphism signup card
                  Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Colors.white),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Confirm password field
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                      HapticFeedback.lightImpact();
                                    },
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Colors.white),
                                obscureText: _obscureConfirmPassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Error message display
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (_errorMessage != null)
                                const SizedBox(height: 20),

                              // Sign up button with animated effects
                              SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _signup,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0277BD,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 5,
                                        shadowColor: const Color(
                                          0xFF0277BD,
                                        ).withOpacity(0.5),
                                      ),
                                      child:
                                          _isLoading
                                              ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    "CREATING ACCOUNT",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          letterSpacing: 1,
                                                        ),
                                                  ),
                                                ],
                                              )
                                              : Text(
                                                'SIGN UP',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 600.ms)
                                  .slideY(
                                    begin: 0.2,
                                    end: 0,
                                    duration: 600.ms,
                                    curve: Curves.easeOut,
                                    delay: 600.ms,
                                  ),

                              const SizedBox(height: 20),

                              // Login option
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) => const LoginScreen(),
                                          transitionsBuilder: (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            const begin = Offset(-1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeOutCubic;

                                            var tween = Tween(
                                              begin: begin,
                                              end: end,
                                            ).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation
                                                .drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                          transitionDuration: const Duration(
                                            milliseconds: 500,
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Log In',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(
                                duration: 600.ms,
                                delay: 800.ms,
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOutQuint,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Signup background with animated water waves
class SignupBackgroundPainter extends CustomPainter {
  final double animation;

  SignupBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw multiple wave layers for depth effect
    _drawWave(
      canvas,
      size,
      Color(0xFFB3E5FC).withOpacity(0.2),
      animation,
      0.85,
      20,
    );

    _drawWave(
      canvas,
      size,
      Color(0xFF81D4FA).withOpacity(0.2),
      animation + 0.3,
      0.8,
      15,
    );

    _drawWave(
      canvas,
      size,
      Color(0xFF4FC3F7).withOpacity(0.1),
      animation + 0.6,
      0.75,
      10,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    Color color,
    double animation,
    double heightFactor,
    double amplitude,
  ) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height;
    final width = size.width;

    path.moveTo(0, height * heightFactor);

    for (int i = 0; i < width; i += 5) {
      path.lineTo(
        i.toDouble(),
        height * heightFactor +
            sin((i * 0.01) + animation * 2 * pi) * amplitude,
      );
    }

    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SignupBackgroundPainter oldDelegate) => true;
}
