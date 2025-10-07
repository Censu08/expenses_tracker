import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../functions/income_page_functions.dart';
import '../pages/income_page.dart';
import '../widgets/income_source_filter.dart';
import '../widgets/income_summary_card.dart';
import '../widgets/income_breakdown_card.dart';
import '../widgets/recent_income_card.dart';
import '../widgets/period_selector.dart';
import '../widgets/income_source_analytics_button.dart';

class IncomePageDesktop extends StatelessWidget {
  final IncomePageState pageState;

  const IncomePageDesktop({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selettore periodo
          PeriodSelector(pageState: pageState),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          // Filtro fonti
          IncomeSourceFilter(
            selectedSource: pageState.selectedSource,
            onSourceSelected: (source) {
              pageState.setState(() {
                pageState.selectedSource = source;
              });
              IncomePageFunctions.loadIncomeData(context, pageState);
            },
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          // Layout principale espandibile
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonna sinistra: Summary + Breakdown
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      IncomeSummaryCard(pageState: pageState),
                      SizedBox(height: ResponsiveUtils.getSpacing(context)),

                      // ⬅️ NUOVO: Bottone Analisi Fonti (apre dialog)
                      IncomeSourceAnalyticsButton(pageState: pageState),
                      SizedBox(height: ResponsiveUtils.getSpacing(context)),

                      Expanded(
                        child: IncomeBreakdownCard(pageState: pageState),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context)),

                // Colonna destra: Lista entrate
                Expanded(
                  flex: 2,
                  child: RecentIncomeCard(pageState: pageState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}