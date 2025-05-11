import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/water_provider.dart';
import '../models/drink.dart';

class AddWaterDialog extends StatefulWidget {
  const AddWaterDialog({super.key});

  @override
  State<AddWaterDialog> createState() => _AddWaterDialogState();
}

class _AddWaterDialogState extends State<AddWaterDialog>
    with SingleTickerProviderStateMixin {
  int _amount = 250;
  DrinkType _selectedType = DrinkType.water;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _animation,
      child: AlertDialog(
        title: Text(
          'Add Drink',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drink type selection
              Text(
                'Select Drink Type',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDrinkTypeButton(
                    DrinkType.water,
                    'Water',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  _buildDrinkTypeButton(
                    DrinkType.coffee,
                    'Coffee',
                    Icons.coffee,
                    Colors.brown,
                  ),
                  _buildDrinkTypeButton(
                    DrinkType.tea,
                    'Tea',
                    Icons.emoji_food_beverage,
                    Colors.green,
                  ),
                  _buildDrinkTypeButton(
                    DrinkType.juice,
                    'Juice',
                    Icons.local_drink,
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Amount selection
              Text(
                'Amount (ml)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        if (_amount > 50) {
                          _amount -= 50;
                        }
                      });
                    },
                    iconSize: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$_amount ml',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _amount += 50;
                      });
                    },
                    iconSize: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                ),
                child: Slider(
                  value: _amount.toDouble(),
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  label: '$_amount ml',
                  onChanged: (value) {
                    setState(() {
                      _amount = value.toInt();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () {
              final drink = Drink(
                type: _selectedType,
                amount: _amount,
                timestamp: DateTime.now(),
              );

              Provider.of<WaterProvider>(
                context,
                listen: false,
              ).addDrink(drink);

              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Add', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkTypeButton(
    DrinkType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
