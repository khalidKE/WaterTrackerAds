import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final weekData = [
      {'day': 'Sat', 'amount': 2200, 'goal': 2000},
      {'day': 'Sun', 'amount': 1700, 'goal': 2000},
      {'day': 'Mon', 'amount': 1800, 'goal': 2000},
      {'day': 'Tue', 'amount': 2100, 'goal': 2000},
      {'day': 'Wed', 'amount': 1500, 'goal': 2000},
      {'day': 'Thu', 'amount': 2300, 'goal': 2000},
      {'day': 'Fri', 'amount': 1900, 'goal': 2000},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final maxChartHeight = constraints.maxHeight * 0.6;
        final barWidth = constraints.maxWidth / weekData.length / 2;
        final fontSize = isTablet ? 12.0 : 10.0;
        final padding = isTablet ? 16.0 : 8.0;

        return Container(
          height: maxChartHeight.clamp(150.0, 250.0), // Dynamic height
          padding: EdgeInsets.all(padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                weekData.map((day) {
                  final percentage =
                      (day['amount'] as num) / (day['goal'] as num);
                  final color =
                      percentage >= 1.0
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${day['amount']}',
                          style: TextStyle(fontSize: fontSize),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: padding / 2),
                        Container(
                          width: barWidth.clamp(
                            20.0,
                            40.0,
                          ), // Responsive bar width
                          height: (maxChartHeight * 0.7 * percentage).clamp(
                            0.0,
                            maxChartHeight * 1.2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: padding / 2),
                        Text(
                          day['day'] as String,
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
