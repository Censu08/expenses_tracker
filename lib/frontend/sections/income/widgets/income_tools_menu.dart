import 'package:flutter/material.dart';
import 'batch_recategorize_income_page.dart';
import 'income_export_dialog.dart';

class IncomeToolsMenu extends StatelessWidget {
  const IncomeToolsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strumenti Entrate'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Export & Analisi'),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: Icons.file_download,
            iconColor: Colors.blue,
            title: 'Esporta Dati',
            description: 'Esporta le tue entrate in CSV, JSON o report testuale',
            onTap: () => _showExportDialog(context),
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: Icons.analytics,
            iconColor: Colors.purple,
            title: 'Report Analisi Fonti',
            description: 'Genera un report completo sulla diversificazione',
            onTap: () => _showExportDialog(context, preselectedReport: true),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Gestione Dati'),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: Icons.edit_note,
            iconColor: Colors.orange,
            title: 'Re-categorizzazione Batch',
            description: 'Aggiorna la fonte di multiple entrate contemporaneamente',
            onTap: () => _navigateToRecategorize(context),
            badge: 'Consigliato',
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: Icons.auto_fix_high,
            iconColor: Colors.green,
            title: 'Suggerimenti Automatici',
            description: 'Ricevi suggerimenti intelligenti per categorizzare le entrate',
            onTap: () => _showComingSoon(context),
            badge: 'Presto',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildToolCard(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String description,
        required VoidCallback onTap,
        String? badge,
      }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: iconColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, {bool preselectedReport = false}) {
    showDialog(
      context: context,
      builder: (context) => const IncomeExportDialog(),
    );
  }

  void _navigateToRecategorize(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BatchRecategorizeIncomePage(),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prossimamente'),
        content: const Text(
          'Questa funzionalità sarà disponibile nella prossima versione!\n\n'
              'I suggerimenti automatici analizzeranno le descrizioni delle entrate '
              'e ti proporranno la fonte più appropriata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}