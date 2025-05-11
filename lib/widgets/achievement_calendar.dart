import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';

class AchievementCalendar extends StatelessWidget {
  const AchievementCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size and orientation
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final padding = size.width * 0.04; // Dynamic padding (4% of screen width)
    final gridItemSize =
        size.width / (isLandscape ? 10 : 8); // Adjust grid size for orientation

    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final monthData = waterProvider.getMonthlyData();
        final goal = waterProvider.dailyGoal;

        // Determine which days achieved the goal
        final achievedDays = <int>{};
        for (int i = 0; i < monthData.length; i++) {
          if ((monthData[i]['amount'] as int) >= goal) {
            achievedDays.add(i + 1); // Days are 1-indexed
          }
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              size.width * 0.04,
            ), // Responsive border radius
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(now),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: size.width * 0.05, // Responsive font size
                  ),
                ),
                SizedBox(height: padding),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    crossAxisSpacing: padding * 0.5,
                    mainAxisSpacing: padding * 0.5,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isAchieved = achievedDays.contains(day);
                    final isToday = day == now.day;
                    final isPast = day < now.day;

                    return Container(
                      margin: EdgeInsets.all(padding * 0.2),
                      decoration: BoxDecoration(
                        color:
                            isAchieved
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.7)
                                : isPast
                                ? Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(padding * 0.5),
                        border:
                            isToday
                                ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                                : isPast
                                ? Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: isAchieved ? Colors.white : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                            fontSize: size.width * 0.04, // Responsive text size
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: padding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width * 0.04,
                      height: size.width * 0.04,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(padding * 0.25),
                      ),
                    ),
                    SizedBox(width: padding * 0.5),
                    Text(
                      'Achieved',
                      style: TextStyle(fontSize: size.width * 0.035),
                    ),
                    SizedBox(width: padding),
                    Container(
                      width: size.width * 0.04,
                      height: size.width * 0.04,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(padding * 0.25),
                      ),
                    ),
                    SizedBox(width: padding * 0.5),
                    Text(
                      'Not achieved',
                      style: TextStyle(fontSize: size.width * 0.035),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
