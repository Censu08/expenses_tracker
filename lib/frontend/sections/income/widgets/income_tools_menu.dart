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
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.02),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('Export & Analisi', Icons.download),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              icon: Icons.file_download,
              iconColor: Colors.blue,
              title: 'Esporta Dati',
              description: 'Esporta le tue entrate in CSV, JSON o report testuale',
              onTap: () => _showExportDialog(context),
            ),
            const SizedBox(height: 14),
            _buildToolCard(
              context,
              icon: Icons.analytics,
              iconColor: Colors.purple,
              title: 'Report Analisi Fonti',
              description: 'Genera un report completo sulla diversificazione',
              onTap: () => _showExportDialog(context, preselectedReport: true),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Gestione Dati', Icons.settings),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              icon: Icons.edit_note,
              iconColor: Colors.orange,
              title: 'Re-categorizzazione Batch',
              description: 'Aggiorna la fonte di multiple entrate contemporaneamente',
              onTap: () => _navigateToRecategorize(context),
              badge: 'Consigliato',
              badgeColor: Colors.orange,
            ),
            const SizedBox(height: 14),
            _buildToolCard(
              context,
              icon: Icons.auto_fix_high,
              iconColor: Colors.green,
              title: 'Suggerimenti Automatici',
              description: 'Ricevi suggerimenti intelligenti per categorizzare le entrate',
              onTap: () => _showComingSoon(context),
              badge: 'Presto',
              badgeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 1,
          ),
        ),
      ],
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
        Color? badgeColor,
      }) {
    return Card(
      elevation: 3,
      shadowColor: iconColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                iconColor.withOpacity(0.03),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor,
                        iconColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (badgeColor ?? iconColor).withOpacity(0.2),
                                    (badgeColor ?? iconColor).withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (badgeColor ?? iconColor).withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor ?? iconColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text('Prossimamente'),
          ],
        ),
        content: Text(
          'Questa funzionalità sarà disponibile nella prossima versione!\n\n'
              'I suggerimenti automatici analizzeranno le descrizioni delle entrate '
              'e ti proporranno la fonte più appropriata.',
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}