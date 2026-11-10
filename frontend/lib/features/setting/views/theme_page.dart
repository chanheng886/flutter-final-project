import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/core/widgets/header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Header(
            icon: FontAwesomeIcons.angleLeft,
            title: 'Theme Mode',
            subTitle: 'Personalize your app appearance',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle Switch Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              size: 24,
                              color: isDark
                                  ? const Color(0xFF818CF8)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColor.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isDark
                                    ? 'Dark theme is currently active'
                                    : 'Light theme is currently active',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: AppColor.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: isDark,
                          activeTrackColor: AppColor.primary,
                          onChanged: (val) => themeProvider.toggleTheme(val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'PREVIEW & CHOOSE',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColor.textGrey,
                      ),
                    ),
                  ),

                  // Visual Mode Selection Cards
                  Row(
                    children: [
                      // Light Mode Card
                      Expanded(
                        child: _ThemePreviewCard(
                          title: 'Light',
                          subTitle: 'Clean & clear',
                          icon: Icons.light_mode,
                          iconColor: const Color(0xFFF59E0B),
                          isSelected: !isDark,
                          previewColor: const Color(0xFFF8FAFC),
                          borderColor:
                              !isDark ? AppColor.primary : Colors.transparent,
                          onTap: () =>
                              themeProvider.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Dark Mode Card
                      Expanded(
                        child: _ThemePreviewCard(
                          title: 'Dark',
                          subTitle: 'Easy on eyes',
                          icon: Icons.dark_mode,
                          iconColor: const Color(0xFF818CF8),
                          isSelected: isDark,
                          previewColor: const Color(0xFF1B2230),
                          borderColor:
                              isDark ? AppColor.primary : Colors.transparent,
                          onTap: () =>
                              themeProvider.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Helpful Note Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2638)
                          : const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E3A52)
                            : const Color(0xFFD6E8FF),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : AppColor.link,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your theme choice is saved automatically and will be remembered the next time you open the app.',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              height: 1.5,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final Color previewColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.previewColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkContext = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? borderColor
                  : Colors.grey.withValues(alpha: 0.15),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColor.primary.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mockup Window Area
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: previewColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 28),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDarkContext
                                ? Colors.white
                                : AppColor.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subTitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColor.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColor.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primary
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
