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

class IncomePageMobile extends StatelessWidget {
  final IncomePageState pageState;

  const IncomePageMobile({
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
          PeriodSelector(pageState: pageState),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          IncomeSourceAnalyticsButton(pageState: pageState),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

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

          IncomeSummaryCard(pageState: pageState),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          SizedBox(
            height: 350,
            child: IncomeBreakdownCard(pageState: pageState),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          SizedBox(
            height: 400,
            child: RecentIncomeCard(pageState: pageState),
          ),
        ],
      ),
    );
  }
}