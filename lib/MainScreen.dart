import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:water_tracker/screens/home_screen.dart';
import 'package:water_tracker/screens/profile_screen.dart';
import 'package:water_tracker/screens/settings_screen.dart';
import 'package:water_tracker/screens/statistics_screen.dart';
import 'package:water_tracker/services/ad_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AdManager().loadBannerAd(() {
      setState(() {});
    });
    AdManager().loadRewardedInterstitialAd(() {
      setState(() {});
    });
    AdManager().loadNativeAd(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    AdManager().disposeAds();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to exit the app?'),
                const SizedBox(height: 12),
                if (AdManager().nativeAd != null && AdManager().isNativeLoaded)
                  SizedBox(
                    height: 100,
                    child: AdWidget(ad: AdManager().nativeAd!),
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  exit(0);
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (AdManager().bannerAd != null && AdManager().isBannerLoaded)
              SizedBox(
                width: AdSize.banner.width.toDouble(),
                height: AdSize.banner.height.toDouble(),
                child: AdWidget(ad: AdManager().bannerAd!),
              ),
            NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onTabChange,
              elevation: 0,
              backgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Colors.white,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.water_drop_outlined),
                  selectedIcon: Icon(Icons.water_drop),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Statistics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
