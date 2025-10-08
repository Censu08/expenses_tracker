import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../functions/income_page_functions.dart';
import '../pages/income_page.dart';
import '../widgets/income_source_filter.dart';
import '../widgets/income_summary_card.dart';
import '../widgets/income_source_breakdown_card.dart';
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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            ResponsiveUtils.getPagePadding(context).left,
            ResponsiveUtils.getPagePadding(context).top,
            ResponsiveUtils.getPagePadding(context).right,
            ResponsiveUtils.getSpacing(context),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 1, child: PeriodSelector(pageState: pageState)),
                  Expanded(flex: 3, child: IncomeSourceAnalyticsButton(pageState: pageState)),
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
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getPagePadding(context).left,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        IncomeSummaryCard(
                          key: ValueKey('summary_${pageState.selectedSource?.toString() ?? 'all'}'),
                          pageState: pageState,
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        SizedBox(
                          height: 500,
                          child: RecentIncomeCard(
                            key: ValueKey('recent_${pageState.selectedSource?.toString() ?? 'all'}'),
                            pageState: pageState,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context) * 1.5),
                Expanded(
                  flex: 4,
                  child: IncomeSourceBreakdownCard(
                    key: ValueKey('breakdown_${pageState.selectedSource?.toString() ?? 'all'}'),
                    pageState: pageState,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}