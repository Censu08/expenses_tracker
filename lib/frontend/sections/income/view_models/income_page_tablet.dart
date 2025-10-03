import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../pages/income_page.dart';
import '../widgets/income_summary_card.dart';
import '../widgets/income_breakdown_card.dart';
import '../widgets/recent_income_card.dart';
import '../widgets/period_selector.dart';

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
          PeriodSelector(pageState: pageState),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
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
          // Usa SizedBox con altezza fissa invece di Expanded
          SizedBox(
            height: 500,
            child: RecentIncomeCard(pageState: pageState),
          ),
        ],
      ),
    );
  }
}