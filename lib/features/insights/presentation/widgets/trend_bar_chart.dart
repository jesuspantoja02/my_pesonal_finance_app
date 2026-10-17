import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/domain/models/analytics.dart';

class TrendBarChart extends StatelessWidget {
  const TrendBarChart({super.key, required this.points});

  final List<MonthlyTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.every((p) => p.expenseCents == 0 && p.incomeCents == 0)) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Aún no hay historial suficiente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.financeMuted,
                ),
          ),
        ),
      );
    }

    final maxY = points
        .map((p) => [p.expenseCents, p.incomeCents])
        .expand((e) => e)
        .fold<int>(0, (m, v) => v > m ? v : m)
        .toDouble();

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.15,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.financeChartGridLine,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  final label = DateFormat.MMM('es').format(points[index].month);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.financeMuted,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].expenseCents.toDouble(),
                    color: AppColors.expense.withValues(alpha: 0.95),
                    width: 11,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                  BarChartRodData(
                    toY: points[i].incomeCents.toDouble(),
                    color: AppColors.income.withValues(alpha: 0.85),
                    width: 11,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
                barsSpace: 4,
              ),
          ],
        ),
      ),
    );
  }
}
