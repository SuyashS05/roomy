import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildOccupancyChart(BuildContext context) {
  // Example occupancy data for a week
  final occupancyData = [5, 7, 6, 8, 4, 9, 3]; // You can replace with Firestore data

  return Container(
    height: 200,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.indigo.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
    ),
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10, // max value for Y-axis
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(days[value.toInt() % 7],
                      style: const TextStyle(fontSize: 12)),
                );
              },
              reservedSize: 28,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: occupancyData
            .asMap()
            .map((index, value) => MapEntry(
                  index,
                  BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                      toY: value.toDouble(),
                      color: Colors.indigo,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    )
                  ]),
                ))
            .values
            .toList(),
      ),
    ),
  );
}
