import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StrengthBar extends StatelessWidget {
  const StrengthBar({super.key, required this.strengthScore});

  final double strengthScore; // 0.0 – 1.0

  @override
  Widget build(BuildContext context) {
    final value = strengthScore.clamp(0.0, 1.0);
    return SizedBox(
      height: 16,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: Colors.blueAccent,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ],
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}

