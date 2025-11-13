import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatsView extends StatelessWidget {
  final Map<String, double> stats;
  const AdminStatsView({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(child: Text('No statistics available.'));
    }

    final List<PieChartSectionData> sections = [];
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple];
    int colorIndex = 0;

    stats.forEach((role, count) {
      sections.add(PieChartSectionData(
        color: colors[colorIndex % colors.length],
        value: count,
        title: '${role.toUpperCase()}\n(${count.toInt()})',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      colorIndex++;
    });

    return SizedBox(
      height: 200,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: sections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ),
    );
  }
}