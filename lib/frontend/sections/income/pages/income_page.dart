import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_model.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../widgets/bloc_state_widgets.dart';
import '../view_models/income_page_mobile.dart';
import '../view_models/income_page_tablet.dart';
import '../view_models/income_page_desktop.dart';
import '../functions/income_page_functions.dart';
import '../widgets/income_export_dialog.dart';
import '../widgets/batch_recategorize_income_page.dart';
import '../widgets/income_tools_menu.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => IncomePageState();
}

class IncomePageState extends State<IncomePage> {
  String selectedPeriod = 'Quest\'Anno';
  IncomeSource? selectedSource;
  final List<String> periods = [
    'Questa Settimana',
    'Questo Mese',
    'Ultimi 3 Mesi',
    'Quest\'Anno',
    'Tutto',
  ];

  bool hasInitialized = false;
  List<IncomeModel> cachedIncomes = [];
  Map<String, double> cachedStats = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasInitialized) {
      hasInitialized = true;
      IncomePageFunctions.loadIncomeData(context, this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshableWidget(
        onRefresh: () async {
          IncomePageFunctions.loadIncomeData(context, this);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: _buildResponsiveBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => IncomePageFunctions.showAddIncomeDialog(context, this),
        icon: const Icon(Icons.add),
        label: const Text('Nuova Entrata'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Entrate'),
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _showExportDialog(),
          tooltip: 'Esporta Dati',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'tools',
              child: Row(
                children: [
                  Icon(Icons.build, size: 20),
                  SizedBox(width: 12),
                  Text('Strumenti'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.file_download, size: 20),
                  SizedBox(width: 12),
                  Text('Esporta'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'recategorize',
              child: Row(
                children: [
                  Icon(Icons.edit_note, size: 20),
                  SizedBox(width: 12),
                  Text('Re-categorizzazione'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveBody() {
    if (ResponsiveUtils.isMobile(context)) {
      return IncomePageMobile(pageState: this);
    } else if (ResponsiveUtils.isTablet(context)) {
      return IncomePageTablet(pageState: this);
    } else {
      return IncomePageDesktop(pageState: this);
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'tools':
        _navigateToTools();
        break;
      case 'export':
        _showExportDialog();
        break;
      case 'recategorize':
        _navigateToRecategorize();
        break;
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => const IncomeExportDialog(),
    );
  }

  void _navigateToTools() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IncomeToolsMenu(),
      ),
    );
  }

  void _navigateToRecategorize() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BatchRecategorizeIncomePage(),
      ),
    );
  }
}