import 'package:expenses_tracker/frontend/sections/income/pages/income_page.dart';
import 'package:expenses_tracker/frontend/sections/income/widgets/income_export_dialog.dart';
import 'package:expenses_tracker/frontend/sections/income/widgets/batch_recategorize_income_page.dart';
import 'package:expenses_tracker/frontend/sections/income/widgets/income_tools_menu.dart';
import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../pages/dashboard_page.dart';
import '../pages/transactions_page.dart';
import '../pages/recurring_expenses_page.dart';
import '../pages/projects_page.dart';
import '../pages/calendar_page.dart';
import '../pages/planning_page.dart';

class MainLayout extends StatefulWidget {
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isRailExtended = true;

  List<NavigationItem> get _navigationItems => [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      page: DashboardPage(),
    ),
    NavigationItem(
      icon: Icons.trending_up,
      label: 'Entrate',
      page: IncomePage(),
      appBarActions: (context) => [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _showIncomeExportDialog(context),
          tooltip: 'Esporta Dati',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (action) => _handleIncomeMenuAction(context, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'tools',
              child: Row(children: [Icon(Icons.build, size: 20), SizedBox(width: 12), Text('Strumenti')]),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [Icon(Icons.file_download, size: 20), SizedBox(width: 12), Text('Esporta')],
              ),
            ),
            const PopupMenuItem(
              value: 'recategorize',
              child: Row(
                children: [Icon(Icons.edit_note, size: 20), SizedBox(width: 12), Text('Re-categorizzazione')],
              ),
            ),
          ],
        ),
      ],
    ),
    NavigationItem(
      icon: Icons.swap_horiz,
      label: 'Transazioni',
      page: TransactionsPage(),
    ),
    NavigationItem(
      icon: Icons.repeat,
      label: 'Spese Ricorrenti',
      page: RecurringExpensesPage(),
    ),
    NavigationItem(
      icon: Icons.work,
      label: 'Progetti',
      page: ProjectsPage(),
    ),
    NavigationItem(
      icon: Icons.calendar_today,
      label: 'Calendario',
      page: CalendarPage(),
    ),
    NavigationItem(
      icon: Icons.architecture,
      label: 'Progettazione',
      page: PlanningPage(),
    ),
  ];

  void _showIncomeExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const IncomeExportDialog(),
    );
  }

  void _handleIncomeMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'tools':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IncomeToolsMenu()),
        );
        break;
      case 'export':
        _showIncomeExportDialog(context);
        break;
      case 'recategorize':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BatchRecategorizeIncomePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return _buildMobileLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    final currentItem = _navigationItems[_selectedIndex];
    final customActions = currentItem.appBarActions?.call(context) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem.label),
        centerTitle: true,
        actions: [
          ...customActions,
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: currentItem.page,
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(),
          Expanded(
            child: Column(
              children: [
                _buildDesktopAppBar(),
                Expanded(child: _navigationItems[_selectedIndex].page),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return NavigationDrawer(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Expenses Tracker',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        ..._navigationItems.map((item) => NavigationDrawerDestination(
          icon: Icon(item.icon),
          label: Text(item.label),
        )),
      ],
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      extended: _isRailExtended,
      minExtendedWidth: 200,
      destinations: _navigationItems
          .map((item) => NavigationRailDestination(
        icon: Icon(item.icon),
        label: Text(item.label),
      ))
          .toList(),
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      leading: Column(
        children: [
          const SizedBox(height: 20),
          if (_isRailExtended) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expenses Tracker',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ] else ...[
            Icon(
              Icons.account_balance_wallet,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ],
          const SizedBox(height: 20),
          IconButton(
            icon: Icon(_isRailExtended ? Icons.menu_open : Icons.menu),
            onPressed: () {
              setState(() => _isRailExtended = !_isRailExtended);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Divider(),
            const SizedBox(height: 10),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
              tooltip: 'Impostazioni',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopAppBar() {
    final currentItem = _navigationItems[_selectedIndex];
    final customActions = currentItem.appBarActions?.call(context) ?? [];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                currentItem.label,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            children: [
              ...customActions,
              if (customActions.isNotEmpty) const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                tooltip: 'Notifiche',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
                tooltip: 'Impostazioni',
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;
  final List<Widget> Function(BuildContext)? appBarActions;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
    this.appBarActions,
  });
}