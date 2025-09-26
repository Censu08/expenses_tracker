import 'package:expenses_tracker/frontend/pages/pagine_placeholder.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(

      title: 'Calendario',
      icon: Icons.calendar_today,
      description: 'Visualizza le tue transazioni, scadenze e obiettivi finanziari '
          'in una comoda vista calendario per una migliore pianificazione.',
      features: [
        'Vista calendario con transazioni pianificate',
        'Promemoria per scadenze di pagamenti',
        'Pianificazione di entrate e uscite future',
        'Integrazione con spese ricorrenti',
        'Vista mensile, settimanale e giornaliera',
      ],
    );
  }
}