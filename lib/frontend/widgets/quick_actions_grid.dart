import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_shopping_cart,
        label: 'Spesa',
        color: Colors.blue,
        onTap: () {
          // TODO: Aggiungi spesa
        },
      ),
      _QuickAction(
        icon: Icons.local_gas_station,
        label: 'Carburante',
        color: Colors.orange,
        onTap: () {
          // TODO: Aggiungi carburante
        },
      ),
      _QuickAction(
        icon: Icons.restaurant,
        label: 'Ristorante',
        color: Colors.red,
        onTap: () {
          // TODO: Aggiungi ristorante
        },
      ),
      _QuickAction(
        icon: Icons.medical_services,
        label: 'Salute',
        color: Colors.green,
        onTap: () {
          // TODO: Aggiungi spesa medica
        },
      ),
      _QuickAction(
        icon: Icons.school,
        label: 'Istruzione',
        color: Colors.purple,
        onTap: () {
          // TODO: Aggiungi spesa istruzione
        },
      ),
      _QuickAction(
        icon: Icons.more_horiz,
        label: 'Altro',
        color: Colors.grey,
        onTap: () {
          // TODO: Mostra tutte le categorie
        },
      ),
    ];

    return Card(
      child: Padding(
        padding: _getCardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Azioni Rapide',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: _getTitleFontSize(context),
              ),
            ),
            SizedBox(height: _getTitleSpacing(context)),
            _buildResponsiveGrid(context, actions),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, List<_QuickAction> actions) {
    if (ResponsiveUtils.isMobile(context)) {
      return _buildMobileGrid(context, actions);
    } else if (ResponsiveUtils.isTablet(context)) {
      return _buildTabletGrid(context, actions);
    } else {
      return _buildDesktopGrid(context, actions);
    }
  }

  Widget _buildMobileGrid(BuildContext context, List<_QuickAction> actions) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.9, // Aumentato per dare più spazio verticale
      children: actions.map((action) => _buildActionTile(context, action)).toList(),
    );
  }

  Widget _buildTabletGrid(BuildContext context, List<_QuickAction> actions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _buildActionTile(context, actions[index]),
    );
  }

  Widget _buildDesktopGrid(BuildContext context, List<_QuickAction> actions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _buildActionTile(context, actions[index]),
    );
  }

  Widget _buildActionTile(BuildContext context, _QuickAction action) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Material(
      color: action.color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: _getTilePadding(context),
          child: isDesktop
              ? _buildDesktopTile(context, action)
              : _buildMobileTile(context, action),
        ),
      ),
    );
  }

  Widget _buildDesktopTile(BuildContext context, _QuickAction action) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: action.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            action.icon,
            color: action.color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            action.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTile(BuildContext context, _QuickAction action) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Chiave: usa solo lo spazio necessario
      children: [
        Flexible(
          child: Icon(
            action.icon,
            color: action.color,
            size: isMobile ? 16 : 20, // Ulteriormente ridotte le icone
          ),
        ),
        const SizedBox(height: 3), // Spaziatura fissa minima
        Flexible(
          child: Text(
            action.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: isMobile ? 9 : 11, // Font più piccolo
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  EdgeInsets _getCardPadding(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) return const EdgeInsets.all(16.0);
    if (ResponsiveUtils.isTablet(context)) return const EdgeInsets.all(20.0);
    return const EdgeInsets.all(24.0);
  }

  EdgeInsets _getTilePadding(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) return const EdgeInsets.all(6.0); // Aumentato leggermente
    if (ResponsiveUtils.isTablet(context)) return const EdgeInsets.all(10.0);
    return const EdgeInsets.all(12.0);
  }

  double _getTitleFontSize(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) return 16;
    if (ResponsiveUtils.isTablet(context)) return 18;
    return 20;
  }

  double _getTitleSpacing(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) return 12;
    if (ResponsiveUtils.isTablet(context)) return 16;
    return 20;
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}