import 'package:flutter/material.dart';

/// Semantic colors for data and status (dataviz reference palette).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.kcal,
    required this.protein,
    required this.good,
    required this.warning,
    required this.serious,
    required this.critical,
    required this.track,
    required this.gridLine,
    required this.eaten,
    required this.spent,
  });

  final Color kcal;
  final Color protein;
  final Color good;
  final Color warning;
  final Color serious;
  final Color critical;
  final Color track;
  final Color gridLine;

  /// Food history series: categorical slots 1 and 2, so the pair stays apart for
  /// color-blind readers too. Always with a legend.
  final Color eaten;
  final Color spent;

  static const light = AppColors(
    kcal: Color(0xFF2A78D6),
    protein: Color(0xFFEB6834),
    good: Color(0xFF0CA30C),
    warning: Color(0xFFFAB219),
    serious: Color(0xFFEC835A),
    critical: Color(0xFFD03B3B),
    track: Color(0xFFE9E8E4),
    gridLine: Color(0xFFD9D8D3),
    eaten: Color(0xFF2A78D6),
    spent: Color(0xFFEB6834),
  );

  static const dark = AppColors(
    kcal: Color(0xFF3987E5),
    protein: Color(0xFFD95926),
    good: Color(0xFF0CA30C),
    warning: Color(0xFFFAB219),
    serious: Color(0xFFEC835A),
    critical: Color(0xFFD03B3B),
    track: Color(0xFF34342F),
    gridLine: Color(0xFF45453F),
    eaten: Color(0xFF3987E5),
    spent: Color(0xFFD95926),
  );

  /// Status for a pace ratio (spent / expected-so-far).
  Color forPace(double? pace) {
    if (pace == null) return good;
    if (pace <= 1.0) return good;
    if (pace <= 1.15) return warning;
    if (pace <= 1.3) return serious;
    return critical;
  }

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) => t < 0.5 ? this : (other as AppColors? ?? this);
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

class AppTheme {
  const AppTheme._();

  static const seed = Color(0xFF2E7D5B);

  static ThemeData build(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: b);
    final text = base.textTheme;
    return base.copyWith(
      extensions: [b == Brightness.light ? AppColors.light : AppColors.dark],
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: base.chipTheme.copyWith(shape: const StadiumBorder()),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
    );
  }
}
