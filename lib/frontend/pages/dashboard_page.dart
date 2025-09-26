import 'package:flutter/material.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/quick_actions_grid.dart';
import '../../core/utils/responsive_utils.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return _buildResponsiveBody();
  }

  Widget _buildResponsiveBody() {
    if (ResponsiveUtils.isMobile(context)) {
      return _buildMobileLayout();
    } else if (ResponsiveUtils.isTablet(context)) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpenseSummaryCard(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          QuickActionsGrid(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildSectionTitle('Transazioni Recenti'),
          const SizedBox(height: 12),
          RecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ExpenseSummaryCard(),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                flex: 1,
                child: QuickActionsGrid(),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildSectionTitle('Transazioni Recenti'),
          const SizedBox(height: 12),
          RecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonna sinistra - Riepilogo e Azioni Rapide
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExpenseSummaryCard(),
                  SizedBox(height: ResponsiveUtils.getSpacing(context)),
                  QuickActionsGrid(),
                ],
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context)),
          // Colonna destra - Transazioni Recenti
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Transazioni Recenti'),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: RecentTransactionsList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: ResponsiveUtils.isMobile(context) ? 20 : 24,
      ),
    );
  }
}