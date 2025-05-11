import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:water_tracker/models/drink.dart';

class WaterProvider with ChangeNotifier {
  List<Drink> _drinks = [];
  int _dailyGoal = 2000; // Default goal in ml
  bool _remindersEnabled = false;
  String _unit = 'ml'; 

  // Profile info
  double _weight = 70.0; // in kg
  double _height = 175.0; // in cm
  String _activityLevel = 'Moderate'; // Sedentary, Moderate, Active
int _age = 30;

  WaterProvider() {
    _loadData();
  }
int get age => _age;
  // Getters
  List<Drink> get drinks => _drinks;
  int get dailyGoal => _dailyGoal;
  bool get remindersEnabled => _remindersEnabled;
  String get unit => _unit;

  double get weight => _weight;
  double get height => _height;
  String get activityLevel => _activityLevel;

  // Drink Management
  void addDrink(Drink drink) {
    _drinks.add(drink);
    _saveData();
    notifyListeners();
  }

  void removeDrink(int index) {
    _drinks.removeAt(index);
    _saveData();
    notifyListeners();
  }

  // Settings
  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    _saveData();
    notifyListeners();
  }

  void setRemindersEnabled(bool enabled) {
    _remindersEnabled = enabled;
    _saveData();
    notifyListeners();
  }

  void setUnit(String unit) {
    _unit = unit;
    _saveData();
    notifyListeners();
  }

  // Profile update
  void updateProfile({
    double? weight,
    double? height,
    String? activityLevel, 
    int? age,
  }) async {
    if (weight != null) _weight = weight;
    if (height != null) _height = height;
    if (activityLevel != null) _activityLevel = activityLevel;
    if (age != null) _age = age;
    await _saveData();
    notifyListeners();
  }

  // Today tracking
  List<Drink> getTodayDrinks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _drinks.where((drink) {
      final drinkDate = DateTime(
        drink.timestamp.year,
        drink.timestamp.month,
        drink.timestamp.day,
      );
      return drinkDate.isAtSameMomentAs(today);
    }).toList();
  }

  int getTodayTotal() {
    return getTodayDrinks().fold(0, (sum, drink) => sum + drink.amount);
  }

  double getTodayProgress() {
    return getTodayTotal() / _dailyGoal;
  }

  // Weekly data
  List<Map<String, dynamic>> getWeeklyData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> weekData = [];
    final int currentWeekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayDrinks = _getDrinksForDate(day);
      final amount = dayDrinks.fold(0, (sum, drink) => sum + drink.amount);
      weekData.add({
        'day': _getWeekdayName(day.weekday),
        'amount': amount,
        'goal': _dailyGoal,
      });
    }

    return weekData;
  }

  // Monthly data
  List<Map<String, dynamic>> getMonthlyData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> monthData = [];
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(now.year, now.month, i);
      final dayDrinks = _getDrinksForDate(day);
      final amount = dayDrinks.fold(0, (sum, drink) => sum + drink.amount);
      monthData.add({'day': i, 'amount': amount, 'goal': _dailyGoal});
    }

    return monthData;
  }

  // Get drinks for specific day
  List<Drink> _getDrinksForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _drinks.where((drink) {
      final drinkDate = DateTime(
        drink.timestamp.year,
        drink.timestamp.month,
        drink.timestamp.day,
      );
      return drinkDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Day names
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  // Load from storage
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _dailyGoal = prefs.getInt('dailyGoal') ?? 2000;
    _remindersEnabled = prefs.getBool('remindersEnabled') ?? false;
    _unit = prefs.getString('unit') ?? 'ml';

    _weight = prefs.getDouble('weight') ?? 70.0;
    _height = prefs.getDouble('height') ?? 175.0;
    _activityLevel = prefs.getString('activityLevel') ?? 'Moderate';
_age = prefs.getInt('age') ?? 30;
    final drinksJson = prefs.getStringList('drinks') ?? [];
    _drinks =
        drinksJson.map((json) => Drink.fromJson(jsonDecode(json))).toList();

    notifyListeners();
  }

  // Save to storage
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('dailyGoal', _dailyGoal);
    await prefs.setBool('remindersEnabled', _remindersEnabled);
    await prefs.setString('unit', _unit);

    await prefs.setDouble('weight', _weight);
    await prefs.setDouble('height', _height);
    await prefs.setString('activityLevel', _activityLevel);
await prefs.setInt('age', _age);
    final drinksJson =
        _drinks.map((drink) => jsonEncode(drink.toJson())).toList();
    await prefs.setStringList('drinks', drinksJson);
  }
}
