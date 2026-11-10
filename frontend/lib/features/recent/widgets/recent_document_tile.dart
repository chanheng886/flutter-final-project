import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/features/home/models/document_model.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentDocumentTile extends StatelessWidget {
  final DocumentModel document;
  final int colorIndex;
  final String subTitle;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const RecentDocumentTile({
    super.key,
    required this.document,
    required this.colorIndex,
    required this.subTitle,
    this.isHighlighted = false,
    required this.onTap,
    required this.onMoreTap,
  });

  static const List<Color> _docIconColors = [
    Color(0xFF38BDF8), // Light Blue
    Color(0xFFEF4444), // Coral Red
    Color(0xFF22C55E), // Emerald Green
    Color(0xFFF59E0B), // Warm Amber
    Color(0xFF8B5CF6), // Purple
  ];

  @override
  Widget build(BuildContext context) {
    final iconColor = _docIconColors[colorIndex % _docIconColors.length];

    return Container(
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.white, AppColor.primary],
              )
            : null,
        color: isHighlighted ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(color: AppColor.primary, width: 1.4)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidFileLines,
                      color: iconColor,
                      size: 24,
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
                        document.docName,
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
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColor.textDark,
                ),
                const SizedBox(width: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onMoreTap,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: AppColor.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

