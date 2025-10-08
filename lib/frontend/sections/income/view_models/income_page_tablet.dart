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
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PeriodSelector(pageState: pageState),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                flex: 3,
                child: IncomeSourceAnalyticsButton(pageState: pageState),
              ),
            ],
          ),
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

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: IncomeSummaryCard(pageState: pageState),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 400,
                  child: IncomeBreakdownCard(pageState: pageState),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          SizedBox(
            height: 500,
            child: RecentIncomeCard(pageState: pageState),
          ),
        ],
      ),
    );
  }
}