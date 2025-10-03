import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_model.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../widgets/bloc_state_widgets.dart';
import '../view_models/income_page_mobile.dart';
import '../view_models/income_page_tablet.dart';
import '../view_models/income_page_desktop.dart';
import '../functions/income_page_functions.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => IncomePageState();
}

class IncomePageState extends State<IncomePage> {
  // State variables
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

  Widget _buildResponsiveBody() {
    if (ResponsiveUtils.isMobile(context)) {
      return IncomePageMobile(pageState: this);
    } else if (ResponsiveUtils.isTablet(context)) {
      return IncomePageTablet(pageState: this);
    } else {
      return IncomePageDesktop(pageState: this);
    }
  }
}