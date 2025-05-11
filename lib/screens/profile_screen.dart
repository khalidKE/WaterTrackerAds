import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../providers/water_provider.dart';
import '../widgets/goal_calculator.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
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
          child: Consumer<WaterProvider>(
            builder: (context, waterProvider, child) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadeIn(
                            child: Text(
                              'My Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FadeInUp(
                      child: _buildGlassCard(
                        context,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(padding: const EdgeInsets.all(4)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daily Goal',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                        Text(
                                          '${waterProvider.dailyGoal} ml',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder:
                                              (context) => Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).scaffoldBackgroundColor,
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          20,
                                                        ),
                                                      ),
                                                ),
                                                padding: EdgeInsets.only(
                                                  bottom:
                                                      MediaQuery.of(
                                                        context,
                                                      ).viewInsets.bottom,
                                                ),
                                                child:
                                                    const WaterGoalCalculator(),
                                              ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Recalculate'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
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
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person,
                              color: colorScheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Personal Information',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildGlassCard(
                        context,
                        child: Column(
                          children: [
                            _buildInfoTile(
                              context,
                              'Weight',
                              '${waterProvider.weight} kg',
                              Icons.monitor_weight,
                              onTap:
                                  () => _showEditDialog(
                                    context,
                                    'Weight',
                                    waterProvider,
                                  ),
                            ),
                            const Divider(height: 1),
                            _buildInfoTile(
                              context,
                              'Height',
                              '${waterProvider.height} cm',
                              Icons.height,
                              onTap:
                                  () => _showEditDialog(
                                    context,
                                    'Height',
                                    waterProvider,
                                  ),
                            ),
                            const Divider(height: 1),
                            _buildInfoTile(
                              context,
                              'Age',
                              '${waterProvider.age} years', // New age tile
                              Icons.cake,
                              onTap:
                                  () => _showEditDialog(
                                    context,
                                    'Age',
                                    waterProvider,
                                  ),
                            ),
                            const Divider(height: 1),
                            _buildInfoTile(
                              context,
                              'Activity Level',
                              waterProvider.activityLevel[0].toUpperCase() +
                                  waterProvider.activityLevel.substring(1),
                              Icons.fitness_center,
                              onTap:
                                  () => _showActivityLevelDialog(
                                    context,
                                    waterProvider,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:
            isDarkMode
                ? Colors.grey[850]!.withOpacity(0.3)
                : Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
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
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: child),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, size: 20),
        onPressed: onTap,
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String field,
    WaterProvider provider,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit $field'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: field,
                suffixText:
                    field == 'Weight'
                        ? 'kg'
                        : field == 'Height'
                        ? 'cm'
                        : field == 'Age'
                        ? 'years'
                        : '',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (field == 'Age') {
                    final value = int.tryParse(controller.text);
                    if (value != null && value > 0) {
                      provider.updateProfile(age: value);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid age'),
                        ),
                      );
                    }
                  } else {
                    final value = double.tryParse(controller.text);
                    if (value != null && value > 0) {
                      if (field == 'Weight') {
                        provider.updateProfile(weight: value);
                      } else {
                        provider.updateProfile(height: value);
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid value'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showActivityLevelDialog(BuildContext context, WaterProvider provider) {
    const levels = ['sedentary', 'moderate', 'active', 'very_active'];
    String? selectedLevel;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Activity Level'),
            content: StatefulBuilder(
              builder:
                  (context, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        levels
                            .map(
                              (level) => RadioListTile<String>(
                                title: Text(
                                  level[0].toUpperCase() + level.substring(1),
                                ),
                                value: level,
                                groupValue:
                                    selectedLevel ?? provider.activityLevel,
                                onChanged:
                                    (value) =>
                                        setState(() => selectedLevel = value),
                              ),
                            )
                            .toList(),
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedLevel != null) {
                    provider.updateProfile(activityLevel: selectedLevel);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
