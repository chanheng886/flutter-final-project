import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

Widget showConfirmLogout(
  BuildContext context, {
  required Future<void> Function() onTap,
}) {
  return AlertDialog(
    backgroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
    titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),

    // Logout icon
    title: Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0EE),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.rightFromBracket,
              size: 28,
              color: Color(0xFFFF796F),
            ),
          ),
        ),
        const SizedBox(height: 18),

        Text(
          'Confirm Logout',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColor.textDark,
          ),
        ),
      ],
    ),

    // Description
    content: Text(
      'Are you sure you want to log out of your account? You will need to sign in again to continue.',
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        height: 1.6,
        color: AppColor.textGrey,
      ),
    ),

    // Action buttons
    actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
    actions: [
      Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.textDark,
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.25)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Logout button
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await onTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF796F),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
