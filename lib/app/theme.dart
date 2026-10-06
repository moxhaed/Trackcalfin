import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

// Design tokens and ThemeData for the "quiet kitchen ledger" look.
// Source of truth: docs/design/DESIGN_SYSTEM.md (section numbers in comments).

/// Spacing scale, base 4 (§3.1).
abstract final class AppSpace {
  static const x1 = 4.0, x2 = 8.0, x3 = 12.0, x4 = 16.0, x5 = 20.0, x6 = 24.0, x8 = 32.0, x10 = 40.0, x12 = 48.0;
  static const screen = 16.0,
      sheet = 20.0,
      card = 16.0,
      hero = 20.0,
      cardGap = 12.0,
      section = 28.0,
      headerGap = 8.0,
      block = 16.0,
      inline = 8.0,
      tight = 4.0;
  static const maxContentWidth = 600.0;
}

/// Corner radii (§5).
abstract final class AppRadius {
  static const card = 20.0,
      sheet = 28.0,
      dialog = 24.0,
      tile = 16.0,
      input = 14.0,
      menu = 14.0,
      segmentTrack = 12.0,
      segmentThumb = 9.0,
      chip = 10.0,
      tag = 6.0;
}

/// Durations and curves (§9).
abstract final class AppMotion {
  static const quick = Duration(milliseconds: 120),
      short = Duration(milliseconds: 200),
      medium = Duration(milliseconds: 280),
      long = Duration(milliseconds: 450),
      ring = Duration(milliseconds: 600);
  static const sheetIn = Duration(milliseconds: 300), sheetOut = Duration(milliseconds: 220);
  static const standard = Curves.easeOutCubic, move = Curves.easeInOutCubic, emphasized = Cubic(0.2, 0, 0, 1);
}

/// Inter at an absolute line height, optically centered (§2.1).
TextStyle _inter(double size, double lh, FontWeight w, double tracking, Color color, {bool tnum = false}) => TextStyle(
  fontFamily: 'Inter',
  fontSize: size,
  height: lh / size,
  fontWeight: w,
  letterSpacing: tracking,
  color: color,
  leadingDistribution: TextLeadingDistribution.even,
  fontFeatures: tnum ? const [FontFeature.tabularFigures()] : null,
);

/// Semantic colors for data and status (§4.3).
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
    required this.fill,
    required this.fillStrong,
    required this.separator,
    required this.textTertiary,
    required this.goodInk,
    required this.warningInk,
    required this.criticalInk,
  });

  /// Energy series (kcal bars and dots).
  final Color kcal;

  /// Protein series.
  final Color protein;

  /// Status fills and icons.
  final Color good;
  final Color warning;
  final Color serious;
  final Color critical;

  /// Progress and ring tracks.
  final Color track;

  /// Dashed chart target line.
  final Color gridLine;

  /// Neutral fill for inputs, chips, steppers, segmented tracks and tonal buttons.
  final Color fill;

  /// Pressed fill and skeleton blocks.
  final Color fillStrong;

  /// Hairlines.
  final Color separator;

  /// Placeholders and chevrons only, never essential text.
  final Color textTertiary;

  /// Status text colors (contrast-safe on surfaces).
  final Color goodInk;
  final Color warningInk;
  final Color criticalInk;

  static const light = AppColors(
    kcal: Color(0xFF3A6BD6),
    protein: Color(0xFFA04AB4),
    good: Color(0xFF24845A),
    warning: Color(0xFFBD7F00),
    serious: Color(0xFFD2691A),
    critical: Color(0xFFCC3A31),
    track: Color(0xFFEAE9E3),
    gridLine: Color(0xFFD6D5CF),
    fill: Color(0x0F191A18),
    fillStrong: Color(0x1A191A18),
    separator: Color(0xFFE4E3DD),
    textTertiary: Color(0xFF787A74),
    goodInk: Color(0xFF24845A),
    warningInk: Color(0xFF8F6200),
    criticalInk: Color(0xFFB42E26),
  );

  static const dark = AppColors(
    kcal: Color(0xFF7DA0F0),
    protein: Color(0xFFCC86DA),
    good: Color(0xFF74C99E),
    warning: Color(0xFFEBB33A),
    serious: Color(0xFFF0924C),
    critical: Color(0xFFEE7468),
    track: Color(0xFF2D2F2B),
    gridLine: Color(0xFF3B3D38),
    fill: Color(0x14FFFFFF),
    fillStrong: Color(0x24FFFFFF),
    separator: Color(0xFF30322E),
    textTertiary: Color(0xFF7C7F78),
    goodInk: Color(0xFF74C99E),
    warningInk: Color(0xFFEBB33A),
    criticalInk: Color(0xFFF28B80),
  );

  /// Status fill for a pace ratio (spent / expected-so-far).
  Color forPace(double? pace) {
    if (pace == null) return good;
    if (pace <= 1.0) return good;
    if (pace <= 1.15) return warning;
    if (pace <= 1.3) return serious;
    return critical;
  }

  /// Status text color for a pace ratio. Serious uses [warningInk]: orange text is too light.
  Color inkForPace(double? pace) {
    if (pace == null) return goodInk;
    if (pace <= 1.0) return goodInk;
    if (pace <= 1.3) return warningInk;
    return criticalInk;
  }

  @override
  AppColors copyWith({
    Color? kcal,
    Color? protein,
    Color? good,
    Color? warning,
    Color? serious,
    Color? critical,
    Color? track,
    Color? gridLine,
    Color? fill,
    Color? fillStrong,
    Color? separator,
    Color? textTertiary,
    Color? goodInk,
    Color? warningInk,
    Color? criticalInk,
  }) => AppColors(
    kcal: kcal ?? this.kcal,
    protein: protein ?? this.protein,
    good: good ?? this.good,
    warning: warning ?? this.warning,
    serious: serious ?? this.serious,
    critical: critical ?? this.critical,
    track: track ?? this.track,
    gridLine: gridLine ?? this.gridLine,
    fill: fill ?? this.fill,
    fillStrong: fillStrong ?? this.fillStrong,
    separator: separator ?? this.separator,
    textTertiary: textTertiary ?? this.textTertiary,
    goodInk: goodInk ?? this.goodInk,
    warningInk: warningInk ?? this.warningInk,
    criticalInk: criticalInk ?? this.criticalInk,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      kcal: l(kcal, other.kcal),
      protein: l(protein, other.protein),
      good: l(good, other.good),
      warning: l(warning, other.warning),
      serious: l(serious, other.serious),
      critical: l(critical, other.critical),
      track: l(track, other.track),
      gridLine: l(gridLine, other.gridLine),
      fill: l(fill, other.fill),
      fillStrong: l(fillStrong, other.fillStrong),
      separator: l(separator, other.separator),
      textTertiary: l(textTertiary, other.textTertiary),
      goodInk: l(goodInk, other.goodInk),
      warningInk: l(warningInk, other.warningInk),
      criticalInk: l(criticalInk, other.criticalInk),
    );
  }
}

/// Numeric text styles: tabular Inter figures (§2.3). Read them with `context.nums`.
@immutable
class AppNumbers extends ThemeExtension<AppNumbers> {
  const AppNumbers({
    required this.hero,
    required this.large,
    required this.medium,
    required this.title,
    required this.body,
    required this.small,
  });

  /// The scale in [ink] (normally `onSurface`).
  factory AppNumbers.of(Color ink) => AppNumbers(
    hero: _inter(44, 48, FontWeight.w600, -0.98, ink, tnum: true),
    large: _inter(28, 32, FontWeight.w600, -0.59, ink, tnum: true),
    medium: _inter(20, 24, FontWeight.w600, -0.33, ink, tnum: true),
    title: _inter(17, 22, FontWeight.w600, -0.22, ink, tnum: true),
    body: _inter(16, 22, FontWeight.w500, -0.18, ink, tnum: true),
    small: _inter(13, 18, FontWeight.w500, -0.04, ink, tnum: true),
  );

  /// 44/48 w600: expense amount, on-hand quantity in the item sheet.
  final TextStyle hero;

  /// 28/32 w600: Today kcal and protein values.
  final TextStyle large;

  /// 20/24 w600: food-spend values, metric values, review total.
  final TextStyle medium;

  /// 17/22 w600: secondary figures in a card footer, stepper value.
  final TextStyle title;

  /// 16/22 w500: trailing row values.
  final TextStyle body;

  /// 13/18 w500: numbers inside meta lines that must align.
  final TextStyle small;

  @override
  AppNumbers copyWith({
    TextStyle? hero,
    TextStyle? large,
    TextStyle? medium,
    TextStyle? title,
    TextStyle? body,
    TextStyle? small,
  }) => AppNumbers(
    hero: hero ?? this.hero,
    large: large ?? this.large,
    medium: medium ?? this.medium,
    title: title ?? this.title,
    body: body ?? this.body,
    small: small ?? this.small,
  );

  @override
  AppNumbers lerp(ThemeExtension<AppNumbers>? other, double t) {
    if (other is! AppNumbers) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppNumbers(
      hero: l(hero, other.hero),
      large: l(large, other.large),
      medium: l(medium, other.medium),
      title: l(title, other.title),
      body: l(body, other.body),
      small: l(small, other.small),
    );
  }
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppNumbers get nums => Theme.of(this).extension<AppNumbers>()!;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

class AppTheme {
  const AppTheme._();

  /// The brand green of the app icon. The UI accent is [ColorScheme.primary].
  static const seed = Color(0xFF2E7D5B);

  /// Explicit color schemes (§4.1, §4.2, §4.4): no `fromSeed`, so nothing tints by accident.
  static ColorScheme scheme(Brightness b) => b == Brightness.light ? _light : _dark;

  static const _light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1D6A4A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE1EEE6),
    onPrimaryContainer: Color(0xFF0F4A32),
    secondary: Color(0xFF62645F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEFEEE9),
    onSecondaryContainer: Color(0xFF191A18),
    tertiary: Color(0xFF1D6A4A),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE1EEE6),
    onTertiaryContainer: Color(0xFF0F4A32),
    error: Color(0xFFC2362E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFBE9E7),
    onErrorContainer: Color(0xFF7A1A14),
    surface: Color(0xFFF4F3EF),
    onSurface: Color(0xFF191A18),
    surfaceDim: Color(0xFFE9E8E3),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerHigh: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFFE9E8E3),
    onSurfaceVariant: Color(0xFF62645F),
    outline: Color(0xFF787A74),
    outlineVariant: Color(0xFFE4E3DD),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2A2B29),
    onInverseSurface: Color(0xFFF1F1EE),
    inversePrimary: Color(0xFF86D6AC),
    surfaceTint: Colors.transparent,
  );

  static const _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF74C99E),
    onPrimary: Color(0xFF04281A),
    primaryContainer: Color(0xFF1A3A2B),
    onPrimaryContainer: Color(0xFFB9E7CE),
    secondary: Color(0xFFA9ABA5),
    onSecondary: Color(0xFF0E0F0E),
    secondaryContainer: Color(0xFF2E2F2C),
    onSecondaryContainer: Color(0xFFF1F1EE),
    tertiary: Color(0xFF74C99E),
    onTertiary: Color(0xFF04281A),
    tertiaryContainer: Color(0xFF1A3A2B),
    onTertiaryContainer: Color(0xFFB9E7CE),
    error: Color(0xFFF08A80),
    onError: Color(0xFF3D0905),
    errorContainer: Color(0xFF3A1714),
    onErrorContainer: Color(0xFFFFD9D4),
    surface: Color(0xFF0E0F0E),
    onSurface: Color(0xFFF1F1EE),
    surfaceDim: Color(0xFF0E0F0E),
    surfaceBright: Color(0xFF2E2F2C),
    surfaceContainerLowest: Color(0xFF0A0B0A),
    surfaceContainerLow: Color(0xFF1C1D1B),
    surfaceContainer: Color(0xFF242523),
    surfaceContainerHigh: Color(0xFF242523),
    surfaceContainerHighest: Color(0xFF2E2F2C),
    onSurfaceVariant: Color(0xFFA9ABA5),
    outline: Color(0xFF7C7F78),
    outlineVariant: Color(0xFF30322E),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFEDEDEA),
    onInverseSurface: Color(0xFF1A1B19),
    inversePrimary: Color(0xFF1D6A4A),
    surfaceTint: Colors.transparent,
  );

  /// The type scale (§2.2). Footnotes default to the secondary text color.
  static TextTheme textTheme(ColorScheme s) {
    final ink = s.onSurface;
    return TextTheme(
      displayLarge: _inter(56, 60, FontWeight.w600, -1.25, ink),
      displayMedium: _inter(44, 48, FontWeight.w600, -0.98, ink, tnum: true),
      displaySmall: _inter(34, 40, FontWeight.w700, -0.74, ink),
      headlineLarge: _inter(30, 36, FontWeight.w700, -0.64, ink),
      headlineMedium: _inter(26, 32, FontWeight.w700, -0.53, ink),
      headlineSmall: _inter(22, 28, FontWeight.w600, -0.40, ink),
      titleLarge: _inter(20, 26, FontWeight.w600, -0.33, ink),
      titleMedium: _inter(17, 22, FontWeight.w600, -0.22, ink),
      titleSmall: _inter(15, 20, FontWeight.w600, -0.13, ink),
      bodyLarge: _inter(16, 22, FontWeight.w400, -0.18, ink),
      bodyMedium: _inter(15, 21, FontWeight.w400, -0.13, ink),
      bodySmall: _inter(13, 18, FontWeight.w400, -0.04, s.onSurfaceVariant),
      labelLarge: _inter(15, 20, FontWeight.w600, -0.13, ink),
      labelMedium: _inter(13, 16, FontWeight.w500, -0.04, ink),
      labelSmall: _inter(11, 13, FontWeight.w500, 0.05, ink),
    );
  }

  /// Large capsule button (L 52): the one commit of a region, e.g. "I cooked this" (§7.1).
  static final ButtonStyle largeButton = FilledButton.styleFrom(
    minimumSize: const Size(64, 52),
    padding: const EdgeInsets.symmetric(horizontal: 24),
  );

  /// The secondary (tonal) button (§7.1): neutral fill, accent w600 label, capsule, M 44 or
  /// S 36. Pass it as `FilledButton.tonal(style: AppTheme.tonalButton(context))`: the filled
  /// button theme can't tell the tonal variant apart, so it's set per button.
  static ButtonStyle tonalButton(BuildContext context, {bool small = false}) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final c = theme.extension<AppColors>()!;
    return FilledButton.styleFrom(
      backgroundColor: c.fill,
      foregroundColor: s.primary,
      iconColor: s.primary,
      disabledBackgroundColor: c.fill.withValues(alpha: c.fill.a * 0.5),
      disabledForegroundColor: s.onSurface.withValues(alpha: 0.38),
      minimumSize: Size(small ? 48 : 64, small ? 36 : 44),
      padding: EdgeInsets.symmetric(horizontal: small ? 16 : 20),
      textStyle: theme.textTheme.labelLarge,
      shape: const StadiumBorder(),
      elevation: 0,
    );
  }

  static ThemeData build(Brightness b) {
    final dark = b == Brightness.dark;
    final s = scheme(b);
    final c = dark ? AppColors.dark : AppColors.light;
    final t = textTheme(s);
    final nums = AppNumbers.of(s.onSurface);
    final barrier = Colors.black.withValues(alpha: dark ? 0.56 : 0.32);
    final secondary = s.onSurfaceVariant;
    final disabledInk = s.onSurface.withValues(alpha: 0.38);
    final halfFill = c.fill.withValues(alpha: c.fill.a * 0.5);
    const capsule = StadiumBorder();
    WidgetStateProperty<Color?> overlay(Color color, double pressed) => WidgetStateProperty.resolveWith((st) {
      if (st.contains(WidgetState.pressed)) return color.withValues(alpha: pressed);
      if (st.contains(WidgetState.hovered)) return color.withValues(alpha: dark ? 0.06 : 0.04);
      if (st.contains(WidgetState.focused)) return color.withValues(alpha: 0.10);
      return null;
    });
    WidgetStateProperty<Color?> enabled(Color color) =>
        WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.disabled) ? disabledInk : color);
    // Flat, borderless fill for every input state (§7.7). Underline borders keep the label inside.
    final noBorder = UnderlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide.none,
    );
    // A floating label is drawn at 75 % of its style: this renders it at 13/18.
    final floatingLabel = t.bodySmall!.copyWith(fontSize: 13 / 0.75);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: s,
      fontFamily: 'Inter',
      textTheme: t,
      extensions: [c, nums],
      scaffoldBackgroundColor: s.surface,
      canvasColor: s.surface,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: c.fillStrong,
      hoverColor: s.onSurface.withValues(alpha: dark ? 0.06 : 0.04),
      focusColor: s.primary.withValues(alpha: 0.12),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      dividerColor: c.separator,
      iconTheme: IconThemeData(color: s.onSurface, size: 24),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: s.primary,
        selectionColor: s.primary.withValues(alpha: 0.25),
        selectionHandleColor: s.primary,
      ),

      // §7.5: the default bar is the compact pushed-screen bar; tab roots use `TabHeader`.
      appBarTheme: AppBarTheme(
        backgroundColor: s.surface,
        foregroundColor: s.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 52,
        titleTextStyle: t.titleMedium,
        iconTheme: IconThemeData(color: s.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: s.onSurface, size: 24),
        actionsPadding: const EdgeInsets.only(right: AppSpace.x2),
      ),

      // §7.2
      cardTheme: CardThemeData(
        elevation: 0,
        color: s.surfaceContainerLow,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),

      // §7.3
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
        minLeadingWidth: 24,
        horizontalTitleGap: 12,
        iconColor: secondary,
        titleTextStyle: t.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: t.bodySmall,
        leadingAndTrailingTextStyle: nums.body,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: secondary,
        collapsedIconColor: c.textTertiary,
        textColor: s.onSurface,
        collapsedTextColor: s.onSurface,
      ),

      // §7.1. FilledButton's theme also styles FilledButton.tonal, so enabled colors stay at the
      // scheme defaults (primary / the neutral secondaryContainer) and only geometry is set here.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(capsule),
          minimumSize: const WidgetStatePropertyAll(Size(64, 44)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          textStyle: WidgetStatePropertyAll(t.labelLarge),
          iconSize: const WidgetStatePropertyAll(20),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.disabled) ? s.onSurface.withValues(alpha: 0.10) : null,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.disabled) ? disabledInk : null,
          ),
        ),
      ),
      // OutlinedButton isn't part of the system: it renders as the tonal (secondary) button.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(capsule),
          side: const WidgetStatePropertyAll(BorderSide.none),
          minimumSize: const WidgetStatePropertyAll(Size(64, 44)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          textStyle: WidgetStatePropertyAll(t.labelLarge),
          iconSize: const WidgetStatePropertyAll(20),
          backgroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.disabled) ? halfFill : c.fill,
          ),
          foregroundColor: enabled(s.primary),
          iconColor: enabled(s.primary),
          overlayColor: overlay(s.primary, 0.10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(capsule),
          minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
          textStyle: WidgetStatePropertyAll(t.labelLarge),
          iconSize: const WidgetStatePropertyAll(20),
          foregroundColor: enabled(s.primary),
          iconColor: enabled(s.primary),
          overlayColor: overlay(s.primary, 0.10),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(44, 44)), iconSize: WidgetStatePropertyAll(24)),
      ),

      // §7.7
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: WidgetStateColor.resolveWith((st) {
          if (st.contains(WidgetState.disabled)) return halfFill;
          if (st.contains(WidgetState.error)) return c.critical.withValues(alpha: 0.08);
          if (st.contains(WidgetState.focused)) return c.fillStrong;
          return c.fill;
        }),
        hoverColor: Colors.transparent,
        border: noBorder,
        enabledBorder: noBorder,
        focusedBorder: noBorder,
        errorBorder: noBorder,
        focusedErrorBorder: noBorder,
        disabledBorder: noBorder,
        // Material 3 adds a 4 gap (`_kInputExtraPadding`) beside the text of a filled field, on top
        // of this padding. 12 + 4 puts the text 16 from the field's edge (§7.7).
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        labelStyle: t.bodyLarge!.copyWith(color: secondary),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (st) => floatingLabel.copyWith(
            color: st.contains(WidgetState.error)
                ? c.criticalInk
                : (st.contains(WidgetState.focused) ? s.primary : secondary),
          ),
        ),
        hintStyle: t.bodyLarge!.copyWith(color: c.textTertiary),
        prefixStyle: t.bodyLarge!.copyWith(color: secondary),
        suffixStyle: t.bodyLarge!.copyWith(color: secondary),
        helperStyle: t.bodySmall,
        errorStyle: t.bodySmall!.copyWith(color: c.criticalInk),
        prefixIconColor: secondary,
        suffixIconColor: secondary,
      ),

      // §7.8. One theme for every chip variant: neutral fill, accent when selected.
      chipTheme: ChipThemeData(
        color: WidgetStateProperty.resolveWith((st) {
          if (st.contains(WidgetState.disabled)) return halfFill;
          if (st.contains(WidgetState.selected)) return s.primary;
          return c.fill;
        }),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.chip)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        labelStyle: t.labelMedium!.copyWith(
          color: WidgetStateColor.resolveWith((st) {
            if (st.contains(WidgetState.disabled)) return disabledInk;
            if (st.contains(WidgetState.selected)) return s.onPrimary;
            return s.onSurface;
          }),
        ),
        iconTheme: IconThemeData(color: secondary, size: 16),
        checkmarkColor: s.onPrimary,
        deleteIconColor: secondary,
        elevation: 0,
        pressElevation: 0,
        shadowColor: Colors.transparent,
        selectedShadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // Until AppSegmented replaces it (§7.6): neutral track, white selected segment.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: c.separator)),
          textStyle: WidgetStatePropertyAll(t.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.selected) ? s.surfaceContainerLow : c.fill,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.selected) ? s.onSurface : secondary,
          ),
        ),
      ),

      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((st) {
          if (st.contains(WidgetState.selected)) return s.primary;
          return dark ? const Color(0xFF3A3C38) : const Color(0xFFD9D8D2);
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        // The thumb is white when on (§12): a dark thumb on the light dark-mode track read as a hole.
        thumbColor: WidgetStateProperty.resolveWith((st) {
          if (st.contains(WidgetState.selected)) return dark ? const Color(0xFFF1F1EE) : const Color(0xFFFFFFFF);
          return dark ? const Color(0xFFC9CBC5) : const Color(0xFFFFFFFF);
        }),
        thumbIcon: const WidgetStatePropertyAll(Icon(Icons.circle, color: Colors.transparent)),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? s.primary : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(s.onPrimary),
        side: WidgetStateBorderSide.resolveWith(
          (st) => st.contains(WidgetState.selected) ? BorderSide.none : BorderSide(color: c.textTertiary, width: 1.5),
        ),
      ),

      // §7.14
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.surfaceContainer,
        modalBackgroundColor: s.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
        showDragHandle: true,
        dragHandleColor: s.onSurface.withValues(alpha: 0.18),
        dragHandleSize: const Size(36, 4),
        modalBarrierColor: barrier,
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints(maxWidth: 640),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: barrier,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        titleTextStyle: t.titleLarge,
        contentTextStyle: t.bodyMedium!.copyWith(color: secondary),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: s.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.menu),
          side: dark ? BorderSide(color: c.separator, width: 0.5) : BorderSide.none,
        ),
        textStyle: t.bodyLarge,
        labelTextStyle: WidgetStatePropertyAll(t.bodyLarge),
        iconColor: secondary,
        iconSize: 20,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: s.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        elevation: 0,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: s.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        elevation: 0,
      ),

      // §7.15
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: s.inverseSurface,
        contentTextStyle: t.bodyMedium!.copyWith(fontWeight: FontWeight.w500, color: s.onInverseSurface),
        actionTextColor: s.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.menu)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        elevation: 6,
      ),

      // §7.16
      badgeTheme: BadgeThemeData(
        backgroundColor: c.critical,
        textColor: dark ? const Color(0xFF2A0B07) : const Color(0xFFFFFFFF),
        smallSize: 8,
        largeSize: 16,
        textStyle: t.labelSmall!.copyWith(
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        offset: const Offset(6, -4),
      ),

      dividerTheme: DividerThemeData(thickness: 0.5, color: c.separator, space: 0.5),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: s.primary,
        linearTrackColor: c.track,
        linearMinHeight: 4,
        circularTrackColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: s.inverseSurface, borderRadius: BorderRadius.circular(8)),
        textStyle: t.bodySmall!.copyWith(color: s.onInverseSurface),
      ),
    );
  }
}
