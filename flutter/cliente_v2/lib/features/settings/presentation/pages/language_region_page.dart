import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/colors.dart';

class LanguageRegionPage extends ConsumerStatefulWidget {
  const LanguageRegionPage({super.key});

  @override
  ConsumerState<LanguageRegionPage> createState() => _LanguageRegionPageState();
}

class _LanguageRegionPageState extends ConsumerState<LanguageRegionPage> {
  DutyThemeTokens get _palette => context.dutyTheme;

  String _selectedLanguage = 'English (US)';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background.withValues(alpha: 0.92),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: palette.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Language & Region',
          style: GoogleFonts.manrope(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sync with Device',
                      style: GoogleFonts.manrope(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Follow global iOS preferences',
                      style: GoogleFonts.manrope(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: true,
                  activeThumbColor: palette.primary,
                  onChanged: (val) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('APP LANGUAGE', trailing: 'Search'),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildLanguageItem(
                'English (US)',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDsZ72GEZjfWru8PiPFD18ixZcLKbgHabr_wpX1U-IfwABy1QTq6jxMySB4TOc1wH6Y8NHwLFFuDcD9kS8sSUVrK3ox9V2zwj2y0rG2UQuAZEqg9aLQrpJthoZT672E2go1QUW2RXz3QjCs_RqnYI_czfI4KrCvwAgc_oNZHH6RY5QS4BCKsgEfmXWWVnAtb6Tzq-6F8-novkWMA5eClIg8GaEtQMRQqDM0xojuhljQFtOKEeVvcVTRGUkYmZ8sVjtowZR0yLd5YtU7',
              ),
              const SizedBox(height: 12),
              _buildLanguageItem(
                'English (UK)',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuADJG79fiVypsGA8jfKhAc2wbfZh2Q9GpS45H2CyYhnYCnBmW6LK9_DJhH8KykZnYHmSp_XqzW39X1EYNr_FAncTz2xtIQMM1tBIlDtMH5gguTncprhcv0qYBqZVqB0oMQp6GNUhu4gRVTN2QKvTCUnZ5TXGITy5mFrEEHER8DTM1J3is3vYpyGRZe-mwJAkoSzzream50bWdOCnj8ekTWHvsePE4bPq8oZTeDJjdPzk5tNwmerqHzjfJhAL55L7MlrE0tZsWZP3eeS',
              ),
              const SizedBox(height: 12),
              _buildLanguageItem(
                'French',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAQFTJDGcWXc1iGtE29d4IQCZ3r6OQhgRgMbNxR2XYRXpvGoWWCfhcbSFz5l53CXcOdKjR06K03ES6egBFMZ8U1yE4J51mCqEd_ab3B9NLl5iSjXre3m0UbtmvrmjnaeW9b224p_m2lSdqLrTD6P4vmItAQb9bhDFEK9pVwGUTg4xNqdCpqHrQfEQp5G83g9PHiENbd5HkgUn5XqIzseyKB4pfEraadGDZ5R5c4Lu7A1U0pvGz4OH1znvYznjhLQ1z6R0IyDa51KssX',
              ),
              const SizedBox(height: 12),
              _buildLanguageItem(
                'German',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuASi3zq6O8eWnZk0aqqjRRBzOqkhYJdfCmAQv6bLkjD7fXGtsK3r-_Be1Ge8VLuTZOlgbYxYM2tlZHSHdXL30XTZa80NmhiQO_6xjqB4yUnftlA748y7KsSzQbxyjhVf_XClVIySra_UDwwmL957gHq8sW4DAYH8kg1FLnUnP6rCo2D4L3O89AZJNjJ6qMu4hnBhqUph4hT1g3ZnTo2B86xl2Rg4JrbGnm_uFupbh4JASayQ5glPXRuuBZDvJfarOQA4_Ea4dnJC6x3',
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('DEFAULT CURRENCY'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _palette.border),
            ),
            child: Row(
              children: [
                _buildCurrencyTab('USD (\$)'),
                const SizedBox(width: 8),
                _buildCurrencyTab('EUR (€)'),
                const SizedBox(width: 8),
                _buildCurrencyTab('Local'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Currency updates affect wallet displays and event ticket pricing.',
            style: GoogleFonts.manrope(
              color: palette.textSecondary,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('REGIONAL SETTINGS'),
          const SizedBox(height: 12),
          _buildRegionTile(
            Icons.schedule_rounded,
            'Time Zone',
            '(GMT+01:00) Central Europe',
          ),
          const SizedBox(height: 12),
          _buildRegionTile(
            Icons.calendar_today_rounded,
            'Date Format',
            'DD/MM/YYYY',
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: palette.primaryGlow.withValues(alpha: 0.24),
              ),
              onPressed: () => context.pop(),
              child: Text(
                'Save Changes',
                style: GoogleFonts.manrope(
                  color: palette.onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? trailing}) {
    final palette = _palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            color: palette.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: GoogleFonts.manrope(
              color: palette.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildLanguageItem(String language, String flagUrl) {
    final palette = _palette;
    final isSelected = _selectedLanguage == language;

    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = language),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? palette.primarySurface : palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? palette.borderStrong : palette.border,
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: flagUrl,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Icon(Icons.flag, size: 24, color: palette.textMuted),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: GoogleFonts.manrope(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: palette.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 16, color: palette.onPrimary),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.textMuted.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTab(String label) {
    final palette = _palette;
    final code = label.split(' ').first;
    final isSelected =
        _selectedCurrency == code ||
        (label == 'Local' && _selectedCurrency == 'Local');

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(
          () => _selectedCurrency = label == 'Local' ? 'Local' : code,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? palette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: palette.primaryGlow.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: isSelected ? palette.onPrimary : palette.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionTile(IconData icon, String label, String value) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: palette.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: palette.textMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.textMuted),
        ],
      ),
    );
  }
}
