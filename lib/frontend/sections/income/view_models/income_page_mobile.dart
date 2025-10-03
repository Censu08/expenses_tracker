import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../pages/income_page.dart';
import '../widgets/income_summary_card.dart';
import '../widgets/income_breakdown_card.dart';
import '../widgets/recent_income_card.dart';
import '../widgets/period_selector.dart';

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
          IncomeSummaryCard(pageState: pageState),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          IncomeBreakdownCard(pageState: pageState),
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