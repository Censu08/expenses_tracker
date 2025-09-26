import 'package:expenses_tracker/frontend/pages/pagine_placeholder.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: 'Transazioni',
      icon: Icons.swap_horiz,
      description: 'Qui potrai visualizzare e gestire tutte le tue transazioni, '
          'filtrarle per categoria, data e importo, e analizzare i tuoi movimenti finanziari.',
      features: [
        'Visualizzazione cronologica delle transazioni',
        'Filtri avanzati per categoria e periodo',
        'Ricerca per descrizione o importo',
        'Esportazione dei dati in Excel/PDF',
        'Grafici di analisi dei movimenti',
      ],
    );
  }
}