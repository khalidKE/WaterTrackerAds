import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:water_tracker/providers/water_provider.dart';
import 'package:water_tracker/screens/profile_screen.dart';

class WaterGoalCalculator extends StatefulWidget {
  const WaterGoalCalculator({super.key});

  @override
  State<WaterGoalCalculator> createState() => _WaterGoalCalculatorState();
}
class _WaterGoalCalculatorState extends State<WaterGoalCalculator> {
  final TextEditingController _weightController = TextEditingController(
    text: '',
  );
  final TextEditingController _heightController = TextEditingController(
    text: '',
  );
  final TextEditingController _ageController = TextEditingController(
    text: '',
  ); // New age controller
  final TextEditingController _manualGoalController = TextEditingController();
  String _gender = 'male';
  String _activityLevel = 'moderate';
  bool _isManualGoal = false;
  int _calculatedGoal = 0;

  @override
  void initState() {
    super.initState();
    _calculateGoal();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose(); // Dispose age controller
    _manualGoalController.dispose();
    super.dispose();
  }

  void _calculateGoal() {
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 170.0;
    final age = int.tryParse(_ageController.text) ?? 30; // Parse age
    double factor = _gender == 'female' ? 28 : 30;

    switch (_activityLevel) {
      case 'sedentary':
        factor -= 5;
        break;
      case 'active':
        factor += 5;
        break;
      case 'very_active':
        factor += 10;
        break;
    }

    factor += (height - 170) * 0.05;
    // Adjust factor based on age
    if (age > 60) {
      factor -= 2; // Slightly lower requirement for older adults
    } else if (age < 18) {
      factor += 2; // Slightly higher for younger individuals
    }

    setState(() {
      _calculatedGoal = (weight * factor).round();
      if (!_isManualGoal) {
        _manualGoalController.text = _calculatedGoal.toString();
      }
    });
  }

  void _saveForm() {
    final goal =
        _isManualGoal
            ? int.tryParse(_manualGoalController.text) ?? _calculatedGoal
            : _calculatedGoal;
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 170.0;
    final age = int.tryParse(_ageController.text) ?? 30; // Get age
    final activityLevel = _activityLevel;

    // Update WaterProvider with new values including age
    Provider.of<WaterProvider>(context, listen: false).updateProfile(
      weight: weight,
      height: height,
      activityLevel: activityLevel,
      age: age,
    );
    Provider.of<WaterProvider>(context, listen: false).setDailyGoal(goal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal and profile saved successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.poppinsTextTheme(theme.textTheme);

    return Theme(
      data: theme.copyWith(
        textTheme: textTheme,
        colorScheme: theme.colorScheme.copyWith(
          primary: const Color(0xFF4DB8FF),
          secondary: const Color(0xFF007AFF),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Water Goal Calculator'),
          backgroundColor: const Color(0xFF4DB8FF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Gender'),
                  Row(
                    children:
                        ['male', 'female'].map((gender) {
                          return Expanded(
                            child: RadioListTile(
                              value: gender,
                              groupValue: _gender,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _gender = val;
                                    _calculateGoal();
                                  });
                                }
                              },
                              title: Text(
                                gender[0].toUpperCase() + gender.substring(1),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Activity Level'),
                  DropdownButtonFormField<String>(
                    value: _activityLevel,
                    items: const [
                      DropdownMenuItem(
                        value: 'sedentary',
                        child: Text('Sedentary'),
                      ),
                      DropdownMenuItem(
                        value: 'moderate',
                        child: Text('Moderate'),
                      ),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'very_active',
                        child: Text('Very Active'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _activityLevel = val;
                          _calculateGoal();
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.directions_walk),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNumberField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    icon: Icons.monitor_weight,
                    onChanged: (_) => _calculateGoal(),
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    icon: Icons.height,
                    onChanged: (_) => _calculateGoal(),
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    controller: _ageController, // New age field
                    label: 'Age (years)',
                    icon: Icons.cake,
                    onChanged: (_) => _calculateGoal(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _isManualGoal,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _isManualGoal = val;
                              if (!val) {
                                _manualGoalController.text =
                                    _calculatedGoal.toString();
                              }
                            });
                          }
                        },
                      ),
                      const Text('Set goal manually'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recommended Goal: $_calculatedGoal ml',
                    style: textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _manualGoalController,
                    enabled: _isManualGoal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily Water Goal (ml)',
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed:
                            () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            ),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _validateAndSave,
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _validateAndSave() {
    final weightValid =
        double.tryParse(_weightController.text) != null &&
        double.parse(_weightController.text) > 0;
    final heightValid =
        double.tryParse(_heightController.text) != null &&
        double.parse(_heightController.text) > 0;
    final ageValid =
        int.tryParse(_ageController.text) != null &&
        int.parse(_ageController.text) > 0; // Validate age
    final manualValid =
        !_isManualGoal ||
        (int.tryParse(_manualGoalController.text) != null &&
            int.parse(_manualGoalController.text) > 0);

    if (weightValid && heightValid && ageValid && manualValid) {
      _saveForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
