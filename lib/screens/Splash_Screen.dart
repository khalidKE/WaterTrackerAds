
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:water_tracker/screens/intro.dart';
import 'package:water_tracker/MainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait a bit to allow the splash animation to play
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Check if user is already logged in
    final currentUser = FirebaseAuth.instance.currentUser;

    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;

    if (currentUser != null) {
      // User is logged in, go directly to main screen
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else if (hasCompletedOnboarding) {
      // User has completed onboarding but is not logged in
      // Go to login screen (you'll need to modify IntroductionScreen to handle this)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const IntroductionScreen(skipToLogin: true),
        ),
      );
    } else {
      // First time user, show the full onboarding flow
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const IntroductionScreen()),
      );
    }
  } 
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen(
        splash: LottieBuilder.asset('images/splash.json'),
        
            
                    nextScreen: const SizedBox(),
                ));
       
}}
