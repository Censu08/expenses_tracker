import 'package:expenses_tracker/frontend/pages/pagine_placeholder.dart';
import 'package:flutter/material.dart';

class RecurringExpensesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(

      title: 'Spese Ricorrenti',
      icon: Icons.repeat,
      description: 'Gestisci le tue spese ricorrenti come abbonamenti, bollette, '
          'affitti e altre spese fisse che si ripetono periodicamente.',
      features: [
        'Configurazione di spese ricorrenti automatiche',
        'Promemoria per scadenze imminenti',
        'Analisi dell\'impatto sul budget mensile',
        'Gestione di abbonamenti e servizi',
        'Previsioni di spesa future',
      ],
    );
  }
}