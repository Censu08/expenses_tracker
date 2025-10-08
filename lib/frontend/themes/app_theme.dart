import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _modernSlateColorScheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme.data,
      floatingActionButtonTheme: _fabTheme,
      chipTheme: _chipTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      dividerTheme: _dividerTheme,
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _modernSlateDarkColorScheme,
      appBarTheme: _appBarThemeDark,
      cardTheme: _cardThemeDark.data,
      floatingActionButtonTheme: _fabThemeDark,
      chipTheme: _chipThemeDark,
      elevatedButtonTheme: _elevatedButtonThemeDark,
      textButtonTheme: _textButtonThemeDark,
      outlinedButtonTheme: _outlinedButtonThemeDark,
      inputDecorationTheme: _inputDecorationThemeDark,
      dividerTheme: _dividerThemeDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }

  static final ColorScheme _modernSlateColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.accent,
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimary,
    onBackground: AppColors.textPrimary,
    onError: Colors.white,
  );

  static final ColorScheme _modernSlateDarkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
    tertiary: AppColors.accentDark,
    surface: AppColors.surfaceDark,
    background: AppColors.backgroundDark,
    error: AppColors.errorDark,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimaryDark,
    onBackground: AppColors.textPrimaryDark,
    onError: Colors.white,
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
  );

  static const AppBarTheme _appBarThemeDark = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimaryDark,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
  );

  static final CardTheme _cardTheme = CardTheme(
    elevation: AppElevations.card,
    shadowColor: AppColors.primary.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
    ),
    color: Colors.white,
  );

  static final CardTheme _cardThemeDark = CardTheme(
    elevation: AppElevations.card,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
    ),
    color: AppColors.surfaceDark,
  );

  static final FloatingActionButtonThemeData _fabTheme = FloatingActionButtonThemeData(
    elevation: AppElevations.fab,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
    ),
  );

  static final FloatingActionButtonThemeData _fabThemeDark = FloatingActionButtonThemeData(
    elevation: AppElevations.fab,
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
    ),
  );

  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.primary,
    deleteIconColor: AppColors.textSecondary,
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.small),
    ),
  );

  static final ChipThemeData _chipThemeDark = ChipThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedColor: AppColors.primaryDark,
    deleteIconColor: AppColors.textSecondaryDark,
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.small),
    ),
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: AppElevations.button,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );

  static final ElevatedButtonThemeData _elevatedButtonThemeDark = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: AppElevations.button,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );

  static final TextButtonThemeData _textButtonThemeDark = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonThemeDark = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryDark,
      side: BorderSide(color: AppColors.primaryDark, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  static final InputDecorationTheme _inputDecorationThemeDark = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      borderSide: BorderSide(color: AppColors.textSecondaryDark.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      borderSide: BorderSide(color: AppColors.textSecondaryDark.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      borderSide: BorderSide(color: AppColors.errorDark, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  static final DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.textSecondary.withOpacity(0.15),
    thickness: 1,
    space: 1,
  );

  static final DividerThemeData _dividerThemeDark = DividerThemeData(
    color: AppColors.textSecondaryDark.withOpacity(0.15),
    thickness: 1,
    space: 1,
  );
}

class AppColors {
  static const Color primary = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFF43F5E);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF8B5CF6);
  static const Color accentDark = Color(0xFFA78BFA);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color successDark = Color(0xFF34D399);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color errorDark = Color(0xFFFB7185);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF22C55E)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F9FF)],
  );

  static final LinearGradient hoverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.secondary.withOpacity(0.08),
      AppColors.accent.withOpacity(0.05),
    ],
  );
}

class AppElevations {
  static const double none = 0;
  static const double card = 2;
  static const double cardHover = 6;
  static const double button = 2;
  static const double buttonHover = 4;
  static const double fab = 4;
  static const double fabHover = 8;
  static const double dialog = 8;
  static const double drawer = 16;
}

class AppBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xLarge = 20.0;
  static const double circle = 999.0;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xLarge = 24.0;
  static const double xxLarge = 32.0;
  static const double xxxLarge = 48.0;
}

class IncomeTheme {
  static BoxDecoration getSummaryCardDecoration(BuildContext context, {bool isHovered = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      gradient: isDark
          ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surfaceDark,
          AppColors.primaryDark.withOpacity(0.1),
        ],
      )
          : AppGradients.cardGradient,
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : AppColors.primary).withOpacity(isHovered ? 0.15 : 0.08),
          blurRadius: isHovered ? 12 : 8,
          offset: Offset(0, isHovered ? 6 : 3),
        ),
      ],
    );
  }

  static BoxDecoration getBreakdownCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      gradient: isDark
          ? LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.surfaceDark,
          AppColors.accentDark.withOpacity(0.08),
        ],
      )
          : const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFF0F9FF)],
      ),
    );
  }

  static BoxDecoration getRecentIncomeCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      gradient: isDark
          ? LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.surfaceDark,
          AppColors.secondaryDark.withOpacity(0.05),
        ],
      )
          : AppGradients.cardGradient,
    );
  }

  static BoxDecoration getIncomeListTileDecoration(
      BuildContext context,
      Color sourceColor,
      {bool isHovered = false}
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isHovered
          ? sourceColor.withOpacity(isDark ? 0.15 : 0.08)
          : (isDark ? AppColors.surfaceDark : Colors.white).withOpacity(0.5),
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
      border: Border.all(
        color: isHovered
            ? sourceColor.withOpacity(0.3)
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.15),
        width: isHovered ? 2 : 1,
      ),
      boxShadow: isHovered
          ? [
        BoxShadow(
          color: sourceColor.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ]
          : null,
    );
  }

  static BoxDecoration getPeriodSelectorDecoration(BuildContext context, {bool isHovered = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
      gradient: isDark
          ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surfaceDark,
          AppColors.primaryDark.withOpacity(0.05),
        ],
      )
          : const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : AppColors.primary).withOpacity(isHovered ? 0.2 : 0.1),
          blurRadius: isHovered ? 8 : 6,
          offset: Offset(0, isHovered ? 4 : 2),
        ),
      ],
    );
  }

  static BoxDecoration getIconContainerDecoration(Color color) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withOpacity(0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  static BoxDecoration getSourceBadgeDecoration(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(AppBorderRadius.small),
    );
  }

  static BoxDecoration getFilterChipDecoration(Color color, {bool isSelected = false}) {
    return BoxDecoration(
      gradient: isSelected
          ? LinearGradient(
        colors: [color, color.withOpacity(0.8)],
      )
          : null,
      color: isSelected ? null : color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppBorderRadius.circle),
      border: Border.all(
        color: color,
        width: isSelected ? 0 : 1.5,
      ),
      boxShadow: isSelected
          ? [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ]
          : null,
    );
  }

  static TextStyle getAmountTextStyle(BuildContext context, {bool isLarge = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextStyle(
      fontSize: isLarge ? 32 : 24,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.successDark : AppColors.success,
      letterSpacing: -0.5,
    );
  }

  static TextStyle getLabelTextStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      letterSpacing: 0.2,
    );
  }

  static TextStyle getCardTitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      letterSpacing: -0.3,
    );
  }

  static BoxShadow getCardShadow(BuildContext context, {bool isHovered = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxShadow(
      color: (isDark ? Colors.black : AppColors.primary).withOpacity(isHovered ? 0.15 : 0.08),
      blurRadius: isHovered ? 12 : 8,
      offset: Offset(0, isHovered ? 6 : 3),
    );
  }
}

class ExpenseTheme {
  static BoxDecoration getExpenseCardDecoration(BuildContext context, {bool isHovered = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      gradient: isDark
          ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surfaceDark,
          AppColors.errorDark.withOpacity(0.1),
        ],
      )
          : LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFFFF),
          AppColors.error.withOpacity(0.03),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : AppColors.error).withOpacity(isHovered ? 0.15 : 0.08),
          blurRadius: isHovered ? 12 : 8,
          offset: Offset(0, isHovered ? 6 : 3),
        ),
      ],
    );
  }

  static TextStyle getExpenseAmountTextStyle(BuildContext context, {bool isLarge = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextStyle(
      fontSize: isLarge ? 32 : 24,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.errorDark : AppColors.error,
      letterSpacing: -0.5,
    );
  }
}

class DashboardTheme {
  static BoxDecoration getQuickActionDecoration(BuildContext context, {bool isHovered = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppBorderRadius.large),
      gradient: isHovered
          ? AppGradients.hoverGradient
          : (isDark
          ? LinearGradient(
        colors: [
          AppColors.surfaceDark,
          AppColors.surfaceDark,
        ],
      )
          : const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
      )),
      border: Border.all(
        color: isHovered
            ? AppColors.secondary.withOpacity(0.3)
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.15),
        width: isHovered ? 2 : 1,
      ),
      boxShadow: isHovered
          ? [
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ]
          : null,
    );
  }
}