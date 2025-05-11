import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../providers/water_provider.dart';
import '../widgets/achievement_calendar.dart';
import '../models/drink.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _lottieController;
  int _selectedTabIndex = 0;

  // Banner ad variables
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Initialize and load banner ad
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8639311525630636/3338897592',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _lottieController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors:
                      isDarkMode
                          ? [const Color(0xFF1A1F25), const Color(0xFF101418)]
                          : [const Color(0xFFE6F4FF), const Color(0xFFF5FAFF)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Custom App Bar with animated water drop
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        isTablet ? 24 : 16,
                        20,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 12),
                              FadeIn(
                                controller:
                                    (controller) => _animationController,
                                child: Text(
                                  'Hydration Analytics',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 28 : 22,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Custom Tab Bar with responsive sizing
                    Container(
                      margin: EdgeInsets.fromLTRB(
                        20,
                        isTablet ? 32 : 24,
                        20,
                        0,
                      ),
                      height: isTablet ? 64 : 56,
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.grey[850]!.withOpacity(0.3)
                                : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(isTablet ? 32 : 28),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDarkMode
                                    ? Colors.black12
                                    : Colors.blue.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 17 : 15,
                        ),
                        unselectedLabelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: isTablet ? 16 : 14,
                        ),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 32 : 28,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              const Color(0xFF5AC8FA),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor:
                            isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: EdgeInsets.all(isTablet ? 6 : 4),
                        tabs: const [
                          Tab(text: 'Daily'),
                          Tab(text: 'Week'),
                          Tab(text: 'Month'),
                        ],
                      ),
                    ),

                    // Tab content
                    Expanded(
                      child: Consumer<WaterProvider>(
                        builder: (context, waterProvider, child) {
                          return TabBarView(
                            controller: _tabController,
                            children: [
                              _buildDailyStatistics(waterProvider),
                              _buildWeeklyStatistics(waterProvider),
                              _buildMonthlyStatistics(waterProvider),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Banner Ad
          if (_isAdLoaded && _bannerAd != null)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyStatistics(WaterProvider waterProvider) {
    final todayDrinks = waterProvider.getTodayDrinks();
    final todayTotal = waterProvider.getTodayTotal();
    final goal = waterProvider.dailyGoal;
    final percentage = (todayTotal / goal * 100).clamp(0, 100).toInt();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    final Map<DrinkType, int> drinkDistribution = {};
    for (var drink in todayDrinks) {
      drinkDistribution[drink.type] =
          (drinkDistribution[drink.type] ?? 0) + drink.amount;
    }

    final Map<int, int> hourlyConsumption = {};
    for (var drink in todayDrinks) {
      final hour = drink.timestamp.hour;
      hourlyConsumption[hour] = (hourlyConsumption[hour] ?? 0) + drink.amount;
    }

    // Adjust layout for landscape mode
    if (isLandscape && !isTablet) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's summary card with wave animation
            FadeInUp(
              controller: (controller) => _animationController,
              child: _buildGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Hydration',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMMM d').format(DateTime.now()),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildAnimatedStatItem(
                                  context,
                                  '$todayTotal ml',
                                  'Consumed',
                                  Icons.water_drop,
                                ),
                                _buildAnimatedStatItem(
                                  context,
                                  '$goal ml',
                                  'Goal',
                                  Icons.flag,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildProgressCircle(percentage),
                            const SizedBox(height: 16),
                            _buildAnimatedStatItem(
                              context,
                              '${todayDrinks.length}',
                              'Drinks',
                              Icons.local_drink,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Two-column layout for landscape
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title with icon
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        controller: (controller) => _animationController,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.pie_chart,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Drink Distribution',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Drink distribution chart
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        controller: (controller) => _animationController,
                        child: _buildGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              height: 200,
                              child:
                                  drinkDistribution.isEmpty
                                      ? _buildEmptyStateWidget(
                                        'No drinks recorded today',
                                        'Try adding different types of drinks to see your distribution',
                                      )
                                      : PieChart(
                                        PieChartData(
                                          sectionsSpace: 10,
                                          centerSpaceRadius: 40,
                                          sections: _buildPieChartSections(
                                            drinkDistribution,
                                            context,
                                          ),
                                          pieTouchData: PieTouchData(
                                            touchCallback:
                                                (
                                                  FlTouchEvent event,
                                                  pieTouchResponse,
                                                ) {},
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title with icon
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        controller: (controller) => _animationController,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.bar_chart,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Hourly Consumption',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Hourly consumption chart
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        controller: (controller) => _animationController,
                        child: _buildGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              height: 200,
                              child:
                                  hourlyConsumption.isEmpty
                                      ? _buildEmptyStateWidget(
                                        'No hourly data available',
                                        'Add drinks throughout the day to see your consumption pattern',
                                      )
                                      : BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY: _getMaxHourlyConsumption(
                                            hourlyConsumption,
                                          ),
                                          barGroups: _buildHourlyBarGroups(
                                            hourlyConsumption,
                                            context,
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (
                                                  double value,
                                                  TitleMeta meta,
                                                ) {
                                                  return SideTitleWidget(
                                                    angle: 0,
                                                    meta: meta,
                                                    space: 6,
                                                    child: Text(
                                                      '${value.toInt()}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                reservedSize: 24,
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 500,
                                                getTitlesWidget: (
                                                  double value,
                                                  TitleMeta meta,
                                                ) {
                                                  return SideTitleWidget(
                                                    meta: meta,
                                                    space: 6,
                                                    child: Text(
                                                      '${value.toInt()}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                reservedSize: 30,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            horizontalInterval: 500,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          borderData: FlBorderData(show: false),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Hydration tips card
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              controller: (controller) => _animationController,
              child: _buildGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber[600]),
                          const SizedBox(width: 10),
                          Text(
                            'Hydration Tip',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Try drinking a glass of water before each meal. This helps with digestion and can prevent overeating.',
                        style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default portrait layout
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's summary card with wave animation
          FadeInUp(
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Stack(
                children: [
                  // Wave animation in background
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today\'s Hydration',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 22 : 18,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'EEEE, MMMM d',
                                  ).format(DateTime.now()),
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            _buildProgressCircle(percentage),
                          ],
                        ),
                        SizedBox(height: isTablet ? 24 : 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAnimatedStatItem(
                              context,
                              '$todayTotal ml',
                              'Consumed',
                              Icons.water_drop,
                            ),
                            _buildAnimatedStatItem(
                              context,
                              '$goal ml',
                              'Goal',
                              Icons.flag,
                            ),
                            _buildAnimatedStatItem(
                              context,
                              '${todayDrinks.length}',
                              'Drinks',
                              Icons.local_drink,
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

          SizedBox(height: isTablet ? 28 : 24),

          // Section title with icon
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            controller: (controller) => _animationController,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                  ),
                  child: Icon(
                    Icons.pie_chart,
                    color: Theme.of(context).colorScheme.primary,
                    size: isTablet ? 22 : 18,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 10),
                Text(
                  'Drink Distribution',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // FIXED: Water percentage display moved to bottom
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: isTablet ? 250 : 200,
                      child:
                          drinkDistribution.isEmpty
                              ? _buildEmptyStateWidget(
                                'No drinks recorded today',
                                'Try adding different types of drinks to see your distribution',
                              )
                              : PieChart(
                                PieChartData(
                                  sectionsSpace: isTablet ? 12 : 10,
                                  centerSpaceRadius: isTablet ? 70 : 60,
                                  sections: _buildPieChartSections(
                                    drinkDistribution,
                                    context,
                                  ),
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (
                                          FlTouchEvent event,
                                          pieTouchResponse,
                                        ) {},
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: isTablet ? 28 : 24),

          // Section title with icon
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            controller: (controller) => _animationController,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: Theme.of(context).colorScheme.primary,
                    size: isTablet ? 22 : 18,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 10),
                Text(
                  'Hourly Consumption',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // FIXED: Bar chart with proper y-axis labels and scaling
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: SizedBox(
                  height: isTablet ? 300 : 250,
                  child:
                      hourlyConsumption.isEmpty
                          ? _buildEmptyStateWidget(
                            'No hourly data available',
                            'Add drinks throughout the day to see your consumption pattern',
                          )
                          : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _getMaxHourlyConsumption(hourlyConsumption),
                              barGroups: _buildHourlyBarGroups(
                                hourlyConsumption,
                                context,
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (
                                      double value,
                                      TitleMeta meta,
                                    ) {
                                      return SideTitleWidget(
                                        angle: 0,
                                        meta: meta,
                                        space: 6,
                                        child: Text(
                                          '${value.toInt()} h', // Added 'h' for hours
                                          style: GoogleFonts.poppins(
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                        ),
                                      );
                                    },
                                    reservedSize: isTablet ? 36 : 32,
                                  ),
                                ),
                                // FIXED: Proper y-axis labels with better spacing and interval
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 500,
                                    getTitlesWidget: (
                                      double value,
                                      TitleMeta meta,
                                    ) {
                                      return SideTitleWidget(
                                        meta: meta,
                                        space: 6,
                                        child: Text(
                                          '${value.toInt()} ml', // Added 'ml' for milliliters
                                          style: GoogleFonts.poppins(
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                        ),
                                      );
                                    },
                                    reservedSize:
                                        isTablet
                                            ? 48
                                            : 40, // Increased reserved size for 'ml'
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 500,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                ),
              ),
            ),
          ),

          // Hydration tips card
          SizedBox(height: isTablet ? 28 : 24),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.amber[600],
                          size: isTablet ? 24 : 20,
                        ),
                        SizedBox(width: isTablet ? 12 : 10),
                        Text(
                          'Hydration Tip',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Text(
                      'Try drinking a glass of water before each meal. This helps with digestion and can prevent overeating.',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 16 : 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatistics(WaterProvider waterProvider) {
    final weekData = waterProvider.getWeeklyData();
    final weeklyTotal = weekData.fold(
      0,
      (sum, day) => sum + (day['amount'] as int),
    );
    final weeklyAverage = weekData.isEmpty ? 0 : weeklyTotal ~/ weekData.length;
    final goal = waterProvider.dailyGoal;
    final goalDays =
        weekData.where((day) => (day['amount'] as int) >= goal).length;
    final goalPercentage =
        weekData.isEmpty ? 0 : (goalDays / weekData.length * 100).round();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    // Adjust layout for landscape mode on smaller devices
    if (isLandscape && !isTablet) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly overview card
            FadeInUp(
              controller: (controller) => _animationController,
              child: _buildGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Overview',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                'Last 7 days',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  goalPercentage >= 70
                                      ? Colors.green.withOpacity(0.2)
                                      : goalPercentage >= 40
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  goalPercentage >= 70
                                      ? Icons.sentiment_very_satisfied
                                      : goalPercentage >= 40
                                      ? Icons.sentiment_satisfied
                                      : Icons.sentiment_dissatisfied,
                                  size: 16,
                                  color:
                                      goalPercentage >= 70
                                          ? Colors.green
                                          : goalPercentage >= 40
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$goalPercentage% Goal Days',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        goalPercentage >= 70
                                            ? Colors.green
                                            : goalPercentage >= 40
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAnimatedStatItem(
                            context,
                            '$weeklyTotal ml',
                            'Total',
                            Icons.water_drop,
                          ),
                          _buildAnimatedStatItem(
                            context,
                            '$weeklyAverage ml',
                            'Daily Avg',
                            Icons.trending_up,
                          ),
                          _buildAnimatedStatItem(
                            context,
                            '$goalDays/${weekData.length}',
                            'Goal Days',
                            Icons.emoji_events,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Two-column layout for landscape
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Weekly chart
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        controller: (controller) => _animationController,
                        child: _buildGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              height: 200,
                              child:
                                  weekData.isEmpty
                                      ? _buildEmptyStateWidget(
                                        'No data for this week',
                                        'Start tracking your water intake to see weekly statistics',
                                      )
                                      : BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY: _getMaxWeeklyConsumption(
                                            weekData,
                                            goal,
                                          ),
                                          barGroups: _buildWeeklyBarGroups(
                                            weekData,
                                            goal,
                                          ),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (
                                                  double value,
                                                  TitleMeta meta,
                                                ) {
                                                  final days = [
                                                    'M',
                                                    'T',
                                                    'W',
                                                    'T',
                                                    'F',
                                                    'S',
                                                    'S',
                                                  ];
                                                  final index = value.toInt();
                                                  if (index >= 0 &&
                                                      index < days.length) {
                                                    return SideTitleWidget(
                                                      meta: meta,
                                                      space: 6,
                                                      child: Text(
                                                        days[index],
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 10,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox();
                                                },
                                                reservedSize: 24,
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (
                                                  double value,
                                                  TitleMeta meta,
                                                ) {
                                                  return SideTitleWidget(
                                                    meta: meta,
                                                    space: 6,
                                                    child: Text(
                                                      '${value.toInt()}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                reservedSize: 30,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            horizontalInterval: 500,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          borderData: FlBorderData(show: false),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right column - Weekly insights
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        controller: (controller) => _animationController,
                        child: _buildGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.insights,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Weekly Insights',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInsightTile(
                                  context,
                                  'Best Hydration Day',
                                  _getBestDayOfWeek(weekData),
                                  Icons.emoji_events,
                                  Colors.amber,
                                ),

                                const Divider(height: 24, thickness: 1),
                                _buildInsightTile(
                                  context,
                                  'Weekly Streak',
                                  '${_getCurrentWeeklyStreak(weekData, goal)} consecutive goal days',
                                  Icons.local_fire_department,
                                  Colors.deepOrange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Achievement calendar
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              controller: (controller) => _animationController,
              child: _buildGlassCard(
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  // child: AchievementCalendar(compactMode: true),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default portrait layout
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly overview card
          FadeInUp(
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Overview',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 20 : 15,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              'Last 7 days',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 14 : 12,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                goalPercentage >= 70
                                    ? Colors.green.withOpacity(0.2)
                                    : goalPercentage >= 40
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              isTablet ? 24 : 20,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                goalPercentage >= 70
                                    ? Icons.sentiment_very_satisfied
                                    : goalPercentage >= 40
                                    ? Icons.sentiment_satisfied
                                    : Icons.sentiment_dissatisfied,
                                size: isTablet ? 20 : 16,
                                color:
                                    goalPercentage >= 70
                                        ? Colors.green
                                        : goalPercentage >= 40
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                              SizedBox(width: isTablet ? 6 : 4),
                              Text(
                                '$goalPercentage% Goal Days',
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      goalPercentage >= 70
                                          ? Colors.green
                                          : goalPercentage >= 40
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 24 : 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAnimatedStatItem(
                          context,
                          '$weeklyTotal ml',
                          'Total',
                          Icons.water_drop,
                        ),
                        _buildAnimatedStatItem(
                          context,
                          '$weeklyAverage ml',
                          'Daily Avg',
                          Icons.trending_up,
                        ),
                        _buildAnimatedStatItem(
                          context,
                          '$goalDays/${weekData.length}',
                          'Goal Days',
                          Icons.emoji_events,
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 24 : 20),
                    SizedBox(
                      height: isTablet ? 300 : 250,
                      child:
                          weekData.isEmpty
                              ? _buildEmptyStateWidget(
                                'No data for this week',
                                'Start tracking your water intake to see weekly statistics',
                              )
                              : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: _getMaxWeeklyConsumption(
                                    weekData,
                                    goal,
                                  ),
                                  barGroups: _buildWeeklyBarGroups(
                                    weekData,
                                    goal,
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (
                                          double value,
                                          TitleMeta meta,
                                        ) {
                                          final days = [
                                            'M',
                                            'T',
                                            'W',
                                            'T',
                                            'F',
                                            'S',
                                            'S',
                                          ];
                                          final index = value.toInt();
                                          if (index >= 0 &&
                                              index < days.length) {
                                            return SideTitleWidget(
                                              meta: meta,
                                              space: 6,
                                              child: Text(
                                                days[index],
                                                style: GoogleFonts.poppins(
                                                  fontSize: isTablet ? 14 : 12,
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                        reservedSize: isTablet ? 36 : 32,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (
                                          double value,
                                          TitleMeta meta,
                                        ) {
                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 6,
                                            child: Text(
                                              '${value.toInt()} ml',
                                              style: GoogleFonts.poppins(
                                                fontSize: isTablet ? 14 : 12,
                                              ),
                                            ),
                                          );
                                        },
                                        reservedSize: isTablet ? 48 : 40,
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 500,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.withOpacity(0.2),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: isTablet ? 28 : 24),

          // Section title with icon
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            controller: (controller) => _animationController,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: isTablet ? 22 : 18,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 10),
                Text(
                  'Achievement Calendar',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Achievement calendar with enhanced design
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: const AchievementCalendar(),
              ),
            ),
          ),

          // Weekly insights card
          SizedBox(height: isTablet ? 28 : 24),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insights,
                          color: Theme.of(context).colorScheme.secondary,
                          size: isTablet ? 24 : 20,
                        ),
                        SizedBox(width: isTablet ? 12 : 10),
                        Text(
                          'Weekly Insights',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildInsightTile(
                      context,
                      'Best Hydration Day',
                      _getBestDayOfWeek(weekData),
                      Icons.emoji_events,
                      Colors.amber,
                    ),

                    const Divider(height: 24, thickness: 1),
                    _buildInsightTile(
                      context,
                      'Weekly Streak',
                      '${_getCurrentWeeklyStreak(weekData, goal)} consecutive goal days',
                      Icons.local_fire_department,
                      Colors.deepOrange,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatistics(WaterProvider waterProvider) {
    final monthData = waterProvider.getMonthlyData();
    final monthlyTotal = monthData.fold(
      0,
      (sum, day) => sum + (day['amount'] as int),
    );
    final monthlyAverage =
        monthData.isEmpty ? 0 : monthlyTotal ~/ monthData.length;
    final goal = waterProvider.dailyGoal;
    final goalDays =
        monthData.where((day) => (day['amount'] as int) >= goal).length;
    final goalPercentage =
        monthData.isEmpty ? 0 : (goalDays / monthData.length * 100).round();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    // Adjust layout for landscape mode
    if (isLandscape && !isTablet) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly insights card with gradient background
            FadeInUp(
              controller: (controller) => _animationController,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      const Color(0xFF5AC8FA),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Overview',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWhiteStatItem(
                            '$monthlyTotal ml',
                            'Total',
                            Icons.water_drop,
                          ),
                          _buildWhiteStatItem(
                            '$monthlyAverage ml',
                            'Daily Avg',
                            Icons.trending_up,
                          ),
                          _buildWhiteStatItem(
                            '$goalPercentage%',
                            'Goal Days',
                            Icons.emoji_events,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Two-column layout for landscape
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Monthly chart
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title with icon
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        controller: (controller) => _animationController,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.show_chart,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Monthly Progress',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Monthly chart
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        controller: (controller) => _animationController,
                        child: _buildGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SizedBox(
                              height: 200,
                              child:
                                  monthData.isEmpty
                                      ? _buildEmptyStateWidget(
                                        'No data for this month',
                                        'Start tracking your water intake to see monthly statistics',
                                      )
                                      : LineChart(
                                        LineChartData(
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: _buildMonthlySpots(
                                                monthData,
                                              ),
                                              isCurved: true,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  const Color(0xFF5AC8FA),
                                                ],
                                              ),
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(
                                                show: false,
                                                getDotPainter: (
                                                  spot,
                                                  percent,
                                                  barData,
                                                  index,
                                                ) {
                                                  return FlDotCirclePainter(
                                                    radius: 4,
                                                    color: const Color(
                                                      0xFF5AC8FA,
                                                    ),
                                                    strokeWidth: 1,
                                                    strokeColor: Colors.white,
                                                  );
                                                },
                                              ),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.3),
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.05),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            LineChartBarData(
                                              spots: List.generate(
                                                monthData.length,
                                                (index) => FlSpot(
                                                  index.toDouble(),
                                                  goal.toDouble(),
                                                ),
                                              ),
                                              isCurved: false,
                                              color: Colors.red.withOpacity(
                                                0.5,
                                              ),
                                              barWidth: 1,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(show: false),
                                              dashArray: [5, 5],
                                            ),
                                          ],
                                          titlesData: FlTitlesData(
                                            show: true,
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (
                                                  double value,
                                                  TitleMeta meta,
                                                ) {
                                                  if (value.toInt() % 5 == 0) {
                                                    return SideTitleWidget(
                                                      meta: meta,
                                                      space: 6,
                                                      child: Text(
                                                        '${value.toInt() + 1}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 10,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox();
                                                },
                                                reservedSize: 24,
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (
                                                  double value,
                                                  TitleMeta meta,
                                                ) {
                                                  return SideTitleWidget(
                                                    meta: meta,
                                                    space: 6,
                                                    child: Text(
                                                      '${value.toInt()} ml',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                reservedSize: 30,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                            horizontalInterval: 500,
                                            getDrawingHorizontalLine: (value) {
                                              return FlLine(
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                                strokeWidth: 1,
                                              );
                                            },
                                          ),
                                          borderData: FlBorderData(show: false),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right column - Monthly trends
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title with icon
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        controller: (controller) => _animationController,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.analytics,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Monthly Trends',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Monthly trends
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        controller: (controller) => _animationController,
                        child: _buildGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                _buildTrendTile(
                                  context,
                                  'Best Day',
                                  _getBestDay(monthData),
                                  Icons.trending_up,
                                  Theme.of(context).colorScheme.primary,
                                ),
                                const Divider(height: 24, thickness: 1),
                                _buildTrendTile(
                                  context,
                                  'Most Active Time',
                                  _getMostActiveTime(waterProvider),
                                  Icons.access_time,
                                  Colors.orange,
                                ),
                                const Divider(height: 24, thickness: 1),
                                _buildTrendTile(
                                  context,
                                  'Longest Streak',
                                  _getLongestStreak(monthData, goal),
                                  Icons.emoji_events,
                                  Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Default portrait layout
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly insights card with gradient background
          FadeInUp(
            controller: (controller) => _animationController,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    const Color(0xFF5AC8FA),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Overview',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 26 : 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWhiteStatItem(
                          '$monthlyTotal ml',
                          'Total',
                          Icons.water_drop,
                        ),
                        _buildWhiteStatItem(
                          '$monthlyAverage ml',
                          'Daily Avg',
                          Icons.trending_up,
                        ),
                        _buildWhiteStatItem(
                          '$goalPercentage%',
                          'Goal Days',
                          Icons.emoji_events,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: isTablet ? 28 : 24),

          // Section title with icon
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            controller: (controller) => _animationController,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                  ),
                  child: Icon(
                    Icons.show_chart,
                    color: Theme.of(context).colorScheme.primary,
                    size: isTablet ? 22 : 18,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 10),
                Text(
                  'Monthly Progress',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Monthly chart with enhanced design
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: SizedBox(
                  height: isTablet ? 300 : 250,
                  child:
                      monthData.isEmpty
                          ? _buildEmptyStateWidget(
                            'No data for this month',
                            'Start tracking your water intake to see monthly statistics',
                          )
                          : LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _buildMonthlySpots(monthData),
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      const Color(0xFF5AC8FA),
                                    ],
                                  ),
                                  barWidth: isTablet ? 5 : 4,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (
                                      spot,
                                      percent,
                                      barData,
                                      index,
                                    ) {
                                      return FlDotCirclePainter(
                                        radius: isTablet ? 7 : 6,
                                        color: const Color(0xFF5AC8FA),
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.3),
                                        Theme.of(context).colorScheme.secondary
                                            .withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                ),
                                LineChartBarData(
                                  spots: List.generate(
                                    monthData.length,
                                    (index) => FlSpot(
                                      index.toDouble(),
                                      goal.toDouble(),
                                    ),
                                  ),
                                  isCurved: false,
                                  color: Colors.red.withOpacity(0.5),
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: false),
                                  dashArray: [5, 5],
                                ),
                              ],
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (
                                      double value,
                                      TitleMeta meta,
                                    ) {
                                      if (value.toInt() % 5 == 0) {
                                        return SideTitleWidget(
                                          meta: meta,
                                          space: 6,
                                          child: Text(
                                            '${value.toInt() + 1}',
                                            style: GoogleFonts.poppins(
                                              fontSize: isTablet ? 14 : 12,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                    reservedSize: isTablet ? 36 : 32,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (
                                      double value,
                                      TitleMeta meta,
                                    ) {
                                      return SideTitleWidget(
                                        meta: meta,
                                        space: 6,
                                        child: Text(
                                          '${value.toInt()} ml',
                                          style: GoogleFonts.poppins(
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                        ),
                                      );
                                    },
                                    reservedSize: isTablet ? 48 : 40,
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 500,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                ),
              ),
            ),
          ),

          SizedBox(height: isTablet ? 28 : 24),

          // Section title with icon
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            controller: (controller) => _animationController,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                    size: isTablet ? 22 : 18,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 10),
                Text(
                  'Monthly Trends',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 16 : 12),

          // Monthly trends with enhanced design
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            controller: (controller) => _animationController,
            child: _buildGlassCard(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                child: Column(
                  children: [
                    _buildTrendTile(
                      context,
                      'Best Day',
                      _getBestDay(monthData),
                      Icons.trending_up,
                      Theme.of(context).colorScheme.primary,
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildTrendTile(
                      context,
                      'Most Active Time',
                      _getMostActiveTime(waterProvider),
                      Icons.access_time,
                      Colors.orange,
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildTrendTile(
                      context,
                      'Longest Streak',
                      _getLongestStreak(monthData, goal),
                      Icons.emoji_events,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        color:
            isDarkMode
                ? Colors.grey[850]!.withOpacity(0.3)
                : Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: isTablet ? 24 : 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildProgressCircle(int percentage) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final circleSize = isTablet ? 70.0 : 60.0;
    final strokeWidth = isTablet ? 10.0 : 8.0;
    final fontSize = isTablet ? 18.0 : 16.0;

    final color =
        percentage >= 100
            ? Colors.green
            : percentage >= 70
            ? Theme.of(context).colorScheme.primary
            : percentage >= 50
            ? Colors.orange
            : Colors.red;

    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: Stack(
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: strokeWidth,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Center(
            child: Text(
              '$percentage%',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final iconSize = isTablet ? 32.0 : 28.0;
    final containerSize = isTablet ? 64.0 : 56.0;
    final valueSize = isTablet ? 20.0 : 18.0;
    final labelSize = isTablet ? 14.0 : 12.0;

    return ElasticIn(
      controller: (controller) => _animationController,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  const Color(0xFF5AC8FA).withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: labelSize,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteStatItem(String value, String label, IconData icon) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final iconSize = isTablet ? 32.0 : 28.0;
    final containerSize = isTablet ? 64.0 : 56.0;
    final valueSize = isTablet ? 20.0 : 18.0;
    final labelSize = isTablet ? 14.0 : 12.0;

    return ElasticIn(
      controller: (controller) => _animationController,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          SizedBox(height: isTablet ? 12 : 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: labelSize,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final iconSize = isTablet ? 28.0 : 24.0;
    final titleSize = isTablet ? 18.0 : 16.0;
    final subtitleSize = isTablet ? 16.0 : 14.0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: titleSize,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: subtitleSize,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildInsightTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final iconSize = isTablet ? 28.0 : 24.0;
    final titleSize = isTablet ? 18.0 : 16.0;
    final subtitleSize = isTablet ? 16.0 : 14.0;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
        SizedBox(width: isTablet ? 18 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: titleSize,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: subtitleSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateWidget(String title, String subtitle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 600;
        final lottieSize =
            isLargeScreen ? 120.0 : 80.0; // Scale placeholder size
        final titleFontSize = isLargeScreen ? 18.0 : 14.0;
        final subtitleFontSize = isLargeScreen ? 16.0 : 12.0;
        final spacing = isLargeScreen ? 12.0 : 8.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: lottieSize,
              width: lottieSize,
              // Placeholder for Lottie animation (URL missing in code)
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.water_drop,
                    size: lottieSize * 0.5,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing / 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: subtitleFontSize,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<DrinkType, int> distribution,
    BuildContext context, // Added context for MediaQuery
  ) {
    final List<PieChartSectionData> sections = [];
    final colors = {
      DrinkType.water: const Color(0xFF5AC8FA),
      DrinkType.coffee: const Color(0xFFBF8970),
      DrinkType.tea: const Color(0xFF7ED957),
      DrinkType.juice: const Color(0xFFFFB74D),
    };

    final labels = {
      DrinkType.water: 'Water',
      DrinkType.coffee: 'Coffee',
      DrinkType.tea: 'Tea',
      DrinkType.juice: 'Juice',
    };

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final radius = isLargeScreen ? 40.0 : 25.0; // Scale radius
    final fontSize = isLargeScreen ? 16.0 : 12.0; // Scale font
    final badgeOffset = isLargeScreen ? 1.4 : 1.2; // Adjust badge position

    final total = distribution.values.fold(0, (sum, amount) => sum + amount);

    distribution.forEach((type, amount) {
      final percentage = total > 0 ? (amount / total * 100).round() : 0;
      sections.add(
        PieChartSectionData(
          value: amount.toDouble(),
          title: '', // Empty title since we're using badges
          color: colors[type],
          radius: radius,
          titleStyle: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          badgeWidget: _Badge(
            '${labels[type]} $percentage%',
            colors[type]!,
          ), // Updated badge with percentage
          badgePositionPercentageOffset: badgeOffset,
        ),
      );
    });

    return sections;
  }

  List<BarChartGroupData> _buildHourlyBarGroups(
    Map<int, int> hourlyConsumption,
    BuildContext context, // Added context for MediaQuery
  ) {
    final List<BarChartGroupData> groups = [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final barWidth = isLargeScreen ? 22.0 : 14.0; // Scale bar width
    final borderRadius = isLargeScreen ? 8.0 : 4.0; // Scale border radius

    hourlyConsumption.forEach((hour, amount) {
      groups.add(
        BarChartGroupData(
          x: hour,
          barRods: [
            BarChartRodData(
              toY: amount.toDouble(),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  const Color(0xFF5AC8FA),
                ],
              ),
              width: barWidth,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
          ],
        ),
      );
    });

    return groups;
  }

  // FIXED: Modified to calculate a more appropriate max value based on actual data
  double _getMaxHourlyConsumption(Map<int, int> hourlyConsumption) {
    if (hourlyConsumption.isEmpty) return 500;
    final maxAmount = hourlyConsumption.values.reduce((a, b) => a > b ? a : b);
    // Add 20% padding to the max value for better visualization
    return (maxAmount).ceilToDouble();
  }

  List<BarChartGroupData> _buildWeeklyBarGroups(
    List<Map<String, dynamic>> weekData,
    int goal,
  ) {
    final List<BarChartGroupData> groups = [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final barWidth = isLargeScreen ? 28.0 : 22.0; // Scale bar width

    for (int i = 0; i < weekData.length; i++) {
      final amount = weekData[i]['amount'] as int;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: amount.toDouble(),
              gradient: LinearGradient(
                colors:
                    amount >= goal
                        ? [Colors.green[400]!, Colors.green[600]!]
                        : [
                          Theme.of(context).colorScheme.primary,
                          const Color(0xFF5AC8FA),
                        ],
              ),
              width: barWidth,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isLargeScreen ? 8.0 : 6.0),
                topRight: Radius.circular(isLargeScreen ? 8.0 : 6.0),
              ),
            ),
          ],
        ),
      );
    }

    return groups;
  }

  double _getMaxWeeklyConsumption(
    List<Map<String, dynamic>> weekData,
    int goal,
  ) {
    if (weekData.isEmpty) return goal.toDouble() + 500;
    final maxAmount = weekData
        .map((day) => day['amount'] as int)
        .reduce((a, b) => a > b ? a : b);
    return math.max(maxAmount, goal).toDouble();
  }

  List<FlSpot> _buildMonthlySpots(List<Map<String, dynamic>> monthData) {
    final List<FlSpot> spots = [];

    for (int i = 0; i < monthData.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), (monthData[i]['amount'] as int).toDouble()),
      );
    }

    return spots;
  }

  String _getBestDay(List<Map<String, dynamic>> monthData) {
    if (monthData.isEmpty || monthData.every((day) => day['amount'] == 0)) {
      return 'No data available';
    }

    int maxAmount = 0;
    int maxDay = 0;

    for (int i = 0; i < monthData.length; i++) {
      final amount = monthData[i]['amount'] as int;
      if (amount > maxAmount) {
        maxAmount = amount;
        maxDay = i + 1;
      }
    }

    final now = DateTime.now();
    final bestDay = DateTime(now.year, now.month, maxDay);
    return '${DateFormat('MMMM d').format(bestDay)} with $maxAmount ml';
  }

  String _getBestDayOfWeek(List<Map<String, dynamic>> weekData) {
    if (weekData.isEmpty || weekData.every((day) => day['amount'] == 0)) {
      return 'No data available';
    }

    int maxAmount = 0;
    int maxDayIndex = 0;

    for (int i = 0; i < weekData.length; i++) {
      final amount = weekData[i]['amount'] as int;
      if (amount > maxAmount) {
        maxAmount = amount;
        maxDayIndex = i;
      }
    }

    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[maxDayIndex]} with $maxAmount ml';
  }

  String _getWorstDayOfWeek(List<Map<String, dynamic>> weekData) {
    if (weekData.isEmpty || weekData.every((day) => day['amount'] == 0)) {
      return 'No data available';
    }

    int minAmount = weekData.first['amount'] as int;
    int minDayIndex = 0;

    for (int i = 0; i < weekData.length; i++) {
      final amount = weekData[i]['amount'] as int;
      if (amount < minAmount) {
        minAmount = amount;
        minDayIndex = i;
      }
    }

    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[minDayIndex]} with only $minAmount ml';
  }

  String _getMostActiveTime(WaterProvider waterProvider) {
    final allDrinks = waterProvider.drinks;
    if (allDrinks.isEmpty) return 'No data available';

    final Map<int, int> hourlyCount = {};

    for (var drink in allDrinks) {
      final hour = drink.timestamp.hour;
      hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
    }

    int maxCount = 0;
    int maxHour = 0;

    hourlyCount.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        maxHour = hour;
      }
    });

    final period = maxHour < 12 ? 'AM' : 'PM';
    final displayHour =
        maxHour == 0 ? 12 : (maxHour > 12 ? maxHour - 12 : maxHour);

    return '$displayHour:00 $period with $maxCount drinks';
  }

  String _getLongestStreak(List<Map<String, dynamic>> monthData, int goal) {
    if (monthData.isEmpty) return 'No data available';

    int currentStreak = 0;
    int maxStreak = 0;

    for (var day in monthData) {
      final amount = day['amount'] as int;
      if (amount >= goal) {
        currentStreak++;
        maxStreak = math.max(maxStreak, currentStreak);
      } else {
        currentStreak = 0;
      }
    }

    return '$maxStreak days in a row';
  }

  int _getCurrentWeeklyStreak(List<Map<String, dynamic>> weekData, int goal) {
    if (weekData.isEmpty) return 0;

    int currentStreak = 0;

    // Count from the end (most recent days first)
    for (int i = weekData.length - 1; i >= 0; i--) {
      final amount = weekData[i]['amount'] as int;
      if (amount >= goal) {
        currentStreak++;
      } else {
        break;
      }
    }

    return currentStreak;
  }

  String _generateMonthlySummary(
    List<Map<String, dynamic>> monthData,
    int goal,
    int average,
  ) {
    if (monthData.isEmpty) {
      return "You haven't tracked your hydration this month yet. Start adding your water intake to see your monthly summary.";
    }

    final goalDays =
        monthData.where((day) => (day['amount'] as int) >= goal).length;
    final totalDays = monthData.length;
    final goalPercentage = (goalDays / totalDays * 100).round();

    String summary = '';

    if (goalPercentage >= 80) {
      summary =
          "Excellent job this month! You've reached your daily hydration goal on $goalDays out of $totalDays days ($goalPercentage%). Your average daily intake was $average ml, which is ";
    } else if (goalPercentage >= 50) {
      summary =
          "Good progress this month! You've reached your daily hydration goal on $goalDays out of $totalDays days ($goalPercentage%). Your average daily intake was $average ml, which is ";
    } else {
      summary =
          "You're making progress, but there's room for improvement. You've reached your daily hydration goal on $goalDays out of $totalDays days ($goalPercentage%). Your average daily intake was $average ml, which is ";
    }

    if (average >= goal) {
      summary += "above your daily goal of $goal ml. Keep up the great work!";
    } else if (average >= goal * 0.8) {
      summary +=
          "close to your daily goal of $goal ml. You're on the right track!";
    } else {
      summary +=
          "below your daily goal of $goal ml. Try setting reminders to drink more water throughout the day.";
    }

    return summary;
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 8,
        vertical: isTablet ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
