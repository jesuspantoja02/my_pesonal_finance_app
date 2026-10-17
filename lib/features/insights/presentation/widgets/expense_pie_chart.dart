import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_personal_finance_app/core/theme/app_colors.dart';
import 'package:my_personal_finance_app/core/theme/chart_palette.dart';
import 'package:my_personal_finance_app/core/theme/finance_theme.dart';
import 'package:my_personal_finance_app/core/utils/money_format.dart';
import 'package:my_personal_finance_app/domain/models/analytics.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({
    super.key,
    required this.slices,
    required this.currencyCode,
    this.compact = false,
  });

  final List<CategoryExpenseSlice> slices;
  final String currencyCode;
  final bool compact;

  static const _mergeBelowPercent = 0.035;

  List<CategoryExpenseSlice> _pieSlices(int totalCents) {
    if (totalCents <= 0) return [];

    final main = <CategoryExpenseSlice>[];
    var otrosCents = 0;
    for (final slice in slices) {
      final share = slice.amountCents / totalCents;
      if (share >= _mergeBelowPercent || slices.length <= 3) {
        main.add(slice);
      } else {
        otrosCents += slice.amountCents;
      }
    }
    if (otrosCents > 0) {
      main.add(
        CategoryExpenseSlice(
          categoryId: 'otros',
          categoryName: 'Otros',
          iconCodePoint: 0xe5c3,
          amountCents: otrosCents,
        ),
      );
    }
    return main;
  }

  Color _colorForSlice(CategoryExpenseSlice slice, int pieIndex) {
    final fullIndex = slices.indexWhere((s) => s.categoryId == slice.categoryId);
    final idx = fullIndex >= 0 ? fullIndex : pieIndex;
    return ChartPalette.forCategoryId(slice.categoryId, idx);
  }

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) {
      return SizedBox(
        height: compact ? 140 : 200,
        child: Center(
          child: Text(
            'Sin gastos este mes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.financeMuted,
                ),
          ),
        ),
      );
    }

    final total = slices.fold<int>(0, (sum, s) => sum + s.amountCents);
    final pieSlices = _pieSlices(total);

    final legend = _LegendList(
      slices: slices,
      currencyCode: currencyCode,
      colorFor: _colorForSlice,
      compact: compact,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 320.0;
        final donutMaxSide = compact
            ? math.min(maxW, 188.0)
            : math.min(maxW < 420 ? maxW : maxW * 0.38, 220.0);

        final donut = SizedBox(
          width: donutMaxSide,
          child: AspectRatio(
            aspectRatio: 1,
            child: _DonutChart(
              pieSlices: pieSlices,
              totalCents: total,
              currencyCode: currencyCode,
              colorFor: _colorForSlice,
            ),
          ),
        );

        final useSideBySide = !compact && maxW >= 420;

        if (useSideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              donut,
              const SizedBox(width: 12),
              Expanded(child: legend),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: donut),
            SizedBox(height: compact ? 10 : 16),
            legend,
          ],
        );
      },
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.pieSlices,
    required this.totalCents,
    required this.currencyCode,
    required this.colorFor,
  });

  final List<CategoryExpenseSlice> pieSlices;
  final int totalCents;
  final String currencyCode;
  final Color Function(CategoryExpenseSlice slice, int index) colorFor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final outerRadius = (side / 2) - 8;
        final centerSpaceRadius = outerRadius * 0.52;
        final innerRatio = centerSpaceRadius / outerRadius;
        // Centrar etiquetas en la banda del anillo (no en el hueco ni fuera).
        final titleOffset = innerRatio + (1 - innerRatio) * 0.5;

        final sections = <PieChartSectionData>[];
        for (var i = 0; i < pieSlices.length; i++) {
          final slice = pieSlices[i];
          final color = colorFor(slice, i);
          final percent = slice.amountCents / totalCents * 100;
          final showLabel =
              pieSlices.length == 1 || percent >= 5;
          sections.add(
            PieChartSectionData(
              value: slice.amountCents.toDouble(),
              color: color,
              radius: outerRadius,
              showTitle: showLabel,
              title: '${percent.round()}%',
              titlePositionPercentageOffset: titleOffset,
              titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: percent >= 15 ? 11 : 9,
                    shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
              borderSide: BorderSide(
                color: context.financePieSectionBorder,
                width: 2,
              ),
            ),
          );
        }

        return ClipOval(
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: centerSpaceRadius,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                  ),
                ),
                SizedBox(
                  width: centerSpaceRadius * 1.75,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Gastos',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: context.financeMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          MoneyFormat.format(totalCents, currencyCode: currencyCode),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.expense,
                                fontSize: 13,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendList extends StatelessWidget {
  const _LegendList({
    required this.slices,
    required this.currencyCode,
    required this.colorFor,
    required this.compact,
  });

  final List<CategoryExpenseSlice> slices;
  final String currencyCode;
  final Color Function(CategoryExpenseSlice slice, int index) colorFor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visibleCount = compact ? slices.length.clamp(0, 5) : slices.length;
    final hidden = slices.length - visibleCount;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < visibleCount; index++) ...[
          if (index > 0) const SizedBox(height: 6),
          _LegendRow(
            slice: slices[index],
            total: slices.fold<int>(0, (sum, s) => sum + s.amountCents),
            currencyCode: currencyCode,
            color: colorFor(slices[index], index),
          ),
        ],
        if (hidden > 0) ...[
          const SizedBox(height: 6),
          Text(
            '+ $hidden categorías más',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.financeMuted,
                ),
          ),
        ],
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.total,
    required this.currencyCode,
    required this.color,
  });

  final CategoryExpenseSlice slice;
  final int total;
  final String currencyCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final onSurface = context.financeOnSurface;
    final percent = total > 0 ? slice.amountCents / total * 100 : 0.0;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: context.financeBorder),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            slice.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
          ),
        ),
        Text(
          '${percent.round()}%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.financeMuted,
              ),
        ),
        const SizedBox(width: 6),
        Flexible(
          flex: 2,
          child: Text(
            MoneyFormat.format(slice.amountCents, currencyCode: currencyCode),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
          ),
        ),
      ],
    );
  }
}
