import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

class FolderCard extends StatelessWidget {
  const new({
    super.key,
    required this.name,
    required this.itemCount,
    required this.onTap,
  });
  final String name;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.primary, Colors.white],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                FontAwesomeIcons.solidFolder,
                color: const Color.fromARGB(255, 109, 185, 255),
                size: 90,
              ),
              const Spacer(),
              Text(
                '$itemCount items',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColor.textGrey,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColor.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
