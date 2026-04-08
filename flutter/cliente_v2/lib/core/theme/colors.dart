import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFFC1121F);
const Color kPrimaryColorDeep = Color(0xFF8A0F18);
const Color kSecondaryColor = Color(0xFF238A57);
const Color kSuccessColor = Color(0xFF238A57);
const Color kWarningColor = Color(0xFFC68500);
const Color kDangerColor = Color(0xFFD32F2F);
const Color kInfoColor = Color(0xFF4459E6);
const Color kEditorialBlush = Color(0xFFE6B7BC);
const Color kDustRose = Color(0xFFC84F5B);
const Color kWarmGold = Color(0xFFD4A63C);
const Color kGraphiteWine = Color(0xFF2D1619);
const Color kCocoaSmoke = Color(0xFF74666D);
const Color kBackgroundDark = Color(0xFF100E14);
const Color kBackgroundLight = Color(0xFFF6F2ED);
const Color kSurfaceColor = Color(0xFF17131B);
const Color kTextPrimary = Color(0xFFF5F1EB);
const Color kTextSecondary = Color(0xFFC7C0CC);
const Color kTextMuted = Color(0xFF948B98);

@immutable
class DutyThemeTokens extends ThemeExtension<DutyThemeTokens> {
  const DutyThemeTokens({
    required this.primary,
    required this.primaryDeep,
    required this.primarySurface,
    required this.primaryGlow,
    required this.onPrimary,
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceMuted,
    required this.navBarSurface,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.shadow,
  });

  final Color primary;
  final Color primaryDeep;
  final Color primarySurface;
  final Color primaryGlow;
  final Color onPrimary;
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceMuted;
  final Color navBarSurface;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color shadow;

  static const DutyThemeTokens dark = DutyThemeTokens(
    primary: kPrimaryColor,
    primaryDeep: kPrimaryColorDeep,
    primarySurface: Color(0xFF321217),
    primaryGlow: kDustRose,
    onPrimary: Color(0xFFFDF7F3),
    background: kBackgroundDark,
    backgroundAlt: Color(0xFF18131A),
    surface: Color(0xFF17131B),
    surfaceAlt: Color(0xFF211922),
    surfaceMuted: Color(0xFF2A202A),
    navBarSurface: Color(0xFF17131A),
    border: Color(0xFF312936),
    borderStrong: Color(0xFF463A45),
    textPrimary: Color(0xFFF5F1EB),
    textSecondary: Color(0xFFC7C0CC),
    textMuted: Color(0xFF948B98),
    success: kSuccessColor,
    warning: kWarningColor,
    danger: kDangerColor,
    info: kInfoColor,
    heroGradientStart: kGraphiteWine,
    heroGradientEnd: Color(0xFF100E14),
    shadow: Color(0xFF050306),
  );

  static const DutyThemeTokens light = DutyThemeTokens(
    primary: kPrimaryColor,
    primaryDeep: kPrimaryColorDeep,
    primarySurface: Color(0xFFF6DFE0),
    primaryGlow: kDustRose,
    onPrimary: Color(0xFFFFFBF8),
    background: kBackgroundLight,
    backgroundAlt: Color(0xFFEFE8E1),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF3ECE5),
    surfaceMuted: Color(0xFFE7DED7),
    navBarSurface: Color(0xFFF9F4EE),
    border: Color(0xFFE4DCD8),
    borderStrong: Color(0xFFD4C6BF),
    textPrimary: Color(0xFF16121A),
    textSecondary: Color(0xFF5D5564),
    textMuted: Color(0xFF8C8391),
    success: kSuccessColor,
    warning: kWarningColor,
    danger: kDangerColor,
    info: kInfoColor,
    heroGradientStart: Color(0xFFF8E7E8),
    heroGradientEnd: Color(0xFFF6F2ED),
    shadow: Color(0xFF170F14),
  );

  @override
  DutyThemeTokens copyWith({
    Color? primary,
    Color? primaryDeep,
    Color? primarySurface,
    Color? primaryGlow,
    Color? onPrimary,
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceMuted,
    Color? navBarSurface,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? shadow,
  }) {
    return DutyThemeTokens(
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      primarySurface: primarySurface ?? this.primarySurface,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      navBarSurface: navBarSurface ?? this.navBarSurface,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ThemeExtension<DutyThemeTokens> lerp(
    covariant ThemeExtension<DutyThemeTokens>? other,
    double t,
  ) {
    if (other is! DutyThemeTokens) {
      return this;
    }

    return DutyThemeTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      navBarSurface: Color.lerp(navBarSurface, other.navBarSurface, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      heroGradientStart: Color.lerp(
        heroGradientStart,
        other.heroGradientStart,
        t,
      )!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension DutyThemeContext on BuildContext {
  DutyThemeTokens get dutyTheme =>
      Theme.of(this).extension<DutyThemeTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? DutyThemeTokens.dark
          : DutyThemeTokens.light);
}
