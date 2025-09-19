import 'package:flutter/material.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/quick_actions_grid.dart';
import '../../core/utils/responsive_utils.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildResponsiveBody(context),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Gestione Spese'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Mostra notifiche
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // TODO: Vai alle impostazioni
          },
        ),
        if (ResponsiveUtils.isDesktop(context))
          const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildResponsiveBody(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return _buildMobileLayout(context);
    } else if (ResponsiveUtils.isTablet(context)) {
      return _buildTabletLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpenseSummaryCard(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          QuickActionsGrid(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildSectionTitle(context, 'Transazioni Recenti'),
          const SizedBox(height: 12),
          RecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
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
          _buildSectionTitle(context, 'Transazioni Recenti'),
          const SizedBox(height: 12),
          RecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonna sinistra - Riepilogo e Azioni Rapide con scroll
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
                _buildSectionTitle(context, 'Transazioni Recenti'),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: ResponsiveUtils.isMobile(context) ? 20 : 24,
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return FloatingActionButton(
        onPressed: () {
          // TODO: Aggiungi nuova spesa
        },
        child: const Icon(Icons.add),
        tooltip: 'Nuova Spesa',
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () {
          // TODO: Aggiungi nuova spesa
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuova Spesa'),
      );
    }
  }
}