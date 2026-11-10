import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentFileTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final int colorIndex;
  final VoidCallback action;
  final VoidCallback onTap;

  const RecentFileTile({
    super.key,
    required this.title,
    required this.subTitle,
    this.colorIndex = 0,
    required this.action,
    required this.onTap,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                IconButton(
                  tooltip: 'Options',
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: action,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
