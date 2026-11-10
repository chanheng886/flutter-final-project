import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

enum RecentSortOption { newest, oldest, alphabetical }

class RecentFilterSheet extends StatelessWidget {
  final RecentSortOption selectedSort;
  final String selectedLanguage;
  final ValueChanged<RecentSortOption> onSortChanged;
  final ValueChanged<String> onLanguageChanged;

  const RecentFilterSheet({
    super.key,
    required this.selectedSort,
    required this.selectedLanguage,
    required this.onSortChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort & Filter',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onSortChanged(RecentSortOption.newest);
                      onLanguageChanged('all');
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Reset',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColor.link,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Text(
                'SORT BY',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColor.textGrey,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.access_time_filled_rounded,
                color: selectedSort == RecentSortOption.newest
                    ? AppColor.link
                    : AppColor.textGrey,
              ),
              title: const Text('Newest first (Default)'),
              trailing: selectedSort == RecentSortOption.newest
                  ? const Icon(Icons.check, color: AppColor.link)
                  : null,
              onTap: () {
                onSortChanged(RecentSortOption.newest);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.history_toggle_off_rounded,
                color: selectedSort == RecentSortOption.oldest
                    ? AppColor.link
                    : AppColor.textGrey,
              ),
              title: const Text('Oldest first'),
              trailing: selectedSort == RecentSortOption.oldest
                  ? const Icon(Icons.check, color: AppColor.link)
                  : null,
              onTap: () {
                onSortChanged(RecentSortOption.oldest);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.sort_by_alpha_rounded,
                color: selectedSort == RecentSortOption.alphabetical
                    ? AppColor.link
                    : AppColor.textGrey,
              ),
              title: const Text('Document name (A–Z)'),
              trailing: selectedSort == RecentSortOption.alphabetical
                  ? const Icon(Icons.check, color: AppColor.link)
                  : null,
              onTap: () {
                onSortChanged(RecentSortOption.alphabetical);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Text(
                'FILTER BY LANGUAGE',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColor.textGrey,
                ),
              ),
            ),
            for (final entry in const [
              ('all', 'All Languages', Icons.language_rounded),
              ('km', 'Khmer (KM)', Icons.translate_rounded),
              ('en', 'English (EN)', Icons.text_fields_rounded),
              ('km+en', 'Khmer + English (KM+EN)', Icons.library_books_rounded),
            ])
              ListTile(
                leading: Icon(
                  entry.$3,
                  color: selectedLanguage == entry.$1
                      ? AppColor.link
                      : AppColor.textGrey,
                ),
                title: Text(entry.$2),
                trailing: selectedLanguage == entry.$1
                    ? const Icon(Icons.check, color: AppColor.link)
                    : null,
                onTap: () {
                  onLanguageChanged(entry.$1);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

