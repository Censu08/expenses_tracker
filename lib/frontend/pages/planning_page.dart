import 'package:expenses_tracker/frontend/pages/pagine_placeholder.dart';
import 'package:flutter/material.dart';

class PlanningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Progettazione',
      icon: Icons.architecture,
      description: 'Strumenti avanzati per la pianificazione finanziaria, '
          'simulazioni di budget e analisi predittive per ottimizzare le tue finanze.',
      features: [
        'Simulazioni di scenari finanziari',
        'Pianificazione budget multi-periodo',
        'Analisi predittive e proiezioni',
        'Ottimizzazione automatica del budget',
        'Report personalizzati e dashboard avanzate',
      ],
    );
  }
}