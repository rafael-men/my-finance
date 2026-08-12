import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyExpensesChart extends StatelessWidget {
  final Map<String, double> monthlyData;

  const MonthlyExpensesChart({super.key, required this.monthlyData});

  double get _maxY {
    if (monthlyData.isEmpty) return 100.0;
    final maxValue = monthlyData.values.reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).clamp(100.0, double.infinity);
  }

  List<BarChartGroupData> get _barGroups {
    if (monthlyData.isEmpty) return [];
    final maxY = _maxY;
    int index = 0;
    return monthlyData.entries.map((entry) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.deepPurple,
            width: 25,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: Colors.grey[300]!,
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY;
    final entries = monthlyData.entries.toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          barGroups: _barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < entries.length) {
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        entries[value.toInt()].key,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: (maxY / 5).clamp(20, double.infinity),
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$${value.toInt()}',
                    style: const TextStyle(fontSize: 9),
                  );
                },
              ),
            ),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 5).clamp(20, double.infinity),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.grey, width: 1),
              left: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (group.x < entries.length) {
                  return BarTooltipItem(
                    '${entries[group.x].key}\nR\$ ${rod.toY.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }
                return null;
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
