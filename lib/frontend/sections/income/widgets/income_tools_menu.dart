import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import 'batch_recategorize_income_page.dart';
import 'income_export_dialog.dart';

class IncomeToolsMenu extends StatelessWidget {
  const IncomeToolsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              isDark ? AppColors.backgroundDark : AppColors.background,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.large),
          children: [
            _buildSectionHeader(context, 'Export & Analisi', Icons.download),
            const SizedBox(height: AppSpacing.large),
            _buildToolCard(
              context,
              icon: Icons.file_download,
              iconColor: isDark ? AppColors.secondaryDark : AppColors.secondary,
              title: 'Esporta Dati',
              description: 'Esporta le tue entrate in CSV, JSON o report testuale',
              onTap: () => _showExportDialog(context),
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildToolCard(
              context,
              icon: Icons.analytics,
              iconColor: isDark ? AppColors.accentDark : AppColors.accent,
              title: 'Report Analisi Fonti',
              description: 'Genera un report completo sulla diversificazione',
              onTap: () => _showExportDialog(context, preselectedReport: true),
            ),
            const SizedBox(height: AppSpacing.xxxLarge),
            _buildSectionHeader(context, 'Gestione Dati', Icons.settings),
            const SizedBox(height: AppSpacing.large),
            _buildToolCard(
              context,
              icon: Icons.edit_note,
              iconColor: isDark ? AppColors.warningDark : AppColors.warning,
              title: 'Re-categorizzazione Batch',
              description: 'Aggiorna la fonte di multiple entrate contemporaneamente',
              onTap: () => _navigateToRecategorize(context),
              badge: 'Consigliato',
              badgeColor: isDark ? AppColors.warningDark : AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildToolCard(
              context,
              icon: Icons.auto_fix_high,
              iconColor: isDark ? AppColors.successDark : AppColors.success,
              title: 'Suggerimenti Automatici',
              description: 'Ricevi suggerimenti intelligenti per categorizzare le entrate',
              onTap: () => _showComingSoon(context),
              badge: 'Presto',
              badgeColor: isDark ? AppColors.successDark : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: AppElevations.card,
      shadowColor: iconColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.surfaceDark : Colors.white,
                iconColor.withOpacity(0.03),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: IncomeTheme.getIconContainerDecoration(iconColor),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: AppSpacing.large),
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
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.small,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (badgeColor ?? iconColor).withOpacity(0.2),
                                    (badgeColor ?? iconColor).withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
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
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? AppColors.textSecondaryDark.withOpacity(0.4) : AppColors.textSecondary.withOpacity(0.4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Icon(
                Icons.info_outline,
                color: isDark ? AppColors.secondaryDark : AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            const Text('Prossimamente'),
          ],
        ),
        content: Text(
          'Questa funzionalità sarà disponibile nella prossima versione!\n\n'
              'I suggerimenti automatici analizzeranno le descrizioni delle entrate '
              'e ti proporranno la fonte più appropriata.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xLarge,
                vertical: AppSpacing.medium,
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}