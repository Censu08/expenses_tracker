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

class IncomePageTablet extends StatelessWidget {
  final IncomePageState pageState;

  const IncomePageTablet({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

          // Prima riga: Summary + Breakdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: IncomeSummaryCard(pageState: pageState),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                flex: 1,
                child: IncomeBreakdownCard(pageState: pageState),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          // ⬅️ NUOVO: Bottone Analisi Fonti (apre dialog)
          IncomeSourceAnalyticsButton(pageState: pageState),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          // Lista entrate recenti
          SizedBox(
            height: 500,
            child: RecentIncomeCard(pageState: pageState),
          ),
        ],
      ),
    );
  }
}