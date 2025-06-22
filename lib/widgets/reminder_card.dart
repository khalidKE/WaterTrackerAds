import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/water_provider.dart';
import '../services/notification_service.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDarkMode ? 0 : 2,
      shadowColor:
          isDarkMode ? Colors.transparent : Colors.blue.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDarkMode ? Theme.of(context).colorScheme.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Consumer<WaterProvider>(
          builder: (context, waterProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: Text(
                    'Enable Reminders',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'Get notifications to stay hydrated',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  value: waterProvider.remindersEnabled,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (value) {
                    waterProvider.setRemindersEnabled(value);
                    if (value) {
                      NotificationService().scheduleReminders();
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Reminders Enabled'),
                              content: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'You will now receive hydration reminders.\n\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'Make sure app notifications are not muted in ',
                                    ),
                                    TextSpan(
                                      text: 'system settings.',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    } else {
                      NotificationService().cancelAllNotifications();
                    }
                  },
                ),
                if (waterProvider.remindersEnabled) ...[
                  const Divider(),
                  const Text(
                    'Remind me in:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        
                        _buildReminderChip(context, 5, 'minutes'),
                        _buildReminderChip(context, 10, 'minutes'),
                        _buildReminderChip(context, 15, 'minutes'),
                        _buildReminderChip(context, 20, 'minutes'),
                        _buildReminderChip(context, 30, 'minutes'),
                        _buildReminderChip(context, 1, 'hour'),
                        _buildReminderChip(context, 2, 'hours'),
                        _buildReminderChip(context, 4, 'hours'),
                        _buildCustomReminderChip(context),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReminderChip(BuildContext context, int value, String unit) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(
          Icons.alarm,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        label: Text('$value $unit'),
        backgroundColor:
            isDarkMode
                ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
                : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
        onPressed: () {
          final minutes = unit == 'minutes' ? value : value * 60;
          NotificationService().scheduleReminderIn(minutes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder set for $value $unit from now'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomReminderChip(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(
          Icons.add_alarm,
          size: 16,
          color: Theme.of(context).colorScheme.secondary,
        ),
        label: const Text('Custom'),
        backgroundColor:
            isDarkMode
                ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
                : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
        onPressed: () {
          _showCustomReminderDialog(context);
        },
      ),
    );
  }

  void _showCustomReminderDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Custom Reminder',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter minutes',
              hintText: 'e.g., 45',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final input = controller.text;
                final minutes = int.tryParse(input);
                if (minutes != null && minutes > 0) {
                  NotificationService().scheduleReminderIn(minutes);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reminder set for $minutes minutes from now',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid positive number'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }
}
