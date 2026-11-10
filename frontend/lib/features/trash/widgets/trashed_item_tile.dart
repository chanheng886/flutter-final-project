import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

class TrashedItemTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool isFolder;
  final VoidCallback onRestore;
  final VoidCallback onDeleteForever;

  const TrashedItemTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.isFolder,
    required this.onRestore,
    required this.onDeleteForever,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor =
        isFolder ? const Color(0xFF6DB9FF) : const Color(0xFF38BDF8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: FaIcon(
                  isFolder
                      ? FontAwesomeIcons.solidFolder
                      : FontAwesomeIcons.solidFileLines,
                  color: themeColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColor.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Restore action button
            Material(
              color: const Color(0xFFDCFCE7),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRestore,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      Icons.restore_from_trash_rounded,
                      color: Color(0xFF166534),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Delete forever button
            Material(
              color: const Color(0xFFFEF2F2),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onDeleteForever,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFB91C1C),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

