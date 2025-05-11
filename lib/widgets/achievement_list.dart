import 'package:flutter/material.dart';

class AchievementList extends StatelessWidget {
  const AchievementList({super.key});

  @override
  Widget build(BuildContext context) {
    // This would be replaced with actual data from the provider
    final achievements = [
      {
        'title': 'First Sip',
        'description': 'Track your first drink',
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'unlocked': true,
      },
      {
        'title': 'Hydration Hero',
        'description': 'Reach your daily goal 7 days in a row',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'unlocked': true,
      },
      {
        'title': 'Early Bird',
        'description': 'Drink water within 30 minutes of waking up for 5 days',
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
        'unlocked': true,
      },
      {
        'title': 'Perfect Month',
        'description': 'Reach your daily goal every day for a month',
        'icon': Icons.calendar_month,
        'color': Colors.green,
        'unlocked': false,
      },
      {
        'title': 'Variety Pack',
        'description': 'Track 5 different types of drinks',
        'icon': Icons.local_bar,
        'color': Colors.purple,
        'unlocked': false,
      },
    ];
    
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: achievements.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final unlocked = achievement['unlocked'] as bool;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: unlocked
                  ? (achievement['color'] as Color)
                  : Colors.grey.withOpacity(0.3),
              child: Icon(
                achievement['icon'] as IconData,
                color: unlocked ? Colors.white : Colors.grey,
              ),
            ),
            title: Text(
              achievement['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: unlocked ? null : Colors.grey,
              ),
            ),
            subtitle: Text(
              achievement['description'] as String,
              style: TextStyle(
                color: unlocked ? null : Colors.grey,
              ),
            ),
            trailing: unlocked
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.lock, color: Colors.grey),
          );
        },
      ),
    );
  }
}
