import 'package:expenses_tracker/frontend/pages/pagine_placeholder.dart';
import 'package:flutter/material.dart';

class ProjectsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(

      title: 'Progetti',
      icon: Icons.work,
      description: 'Organizza le tue finanze per progetti specifici, '
          'come vacanze, ristrutturazioni, acquisti importanti o obiettivi di risparmio.',
      features: [
        'Creazione di budget per progetti specifici',
        'Monitoraggio dei progressi verso gli obiettivi',
        'Allocazione automatica dei fondi',
        'Timeline e scadenze dei progetti',
        'Report di avanzamento e analisi costi',
      ],
    );
  }
}