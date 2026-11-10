import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/core/widgets/header.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/setting/widgets/account_section.dart';
import 'package:frontend/features/setting/widgets/app_section.dart';
import 'package:frontend/features/setting/widgets/show_confirm_logout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final _authprovider = context.watch<AuthProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              icon: FontAwesomeIcons.angleLeft,
              title: "Setting",
              subTitle: "Manage your account",
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                "Account",
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textDark,
                ),
              ),
            ),
            SizedBox(height: 12),
            AccountSection(),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                "App",
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textDark,
                ),
              ),
            ),
            SizedBox(height: 12),
            AppSection(),
            // Log out button
            SizedBox(height: 22),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Material(
                  color: const Color(0xFFFFF4F2),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),

                    // Open the logout confirmation dialog
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) => showConfirmLogout(
                          dialogContext,
                          onTap: _authprovider.logOut,
                        ),
                      );
                    },

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFDDD8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF796F)
                                .withValues(alpha: 0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Logout icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF796F),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.rightFromBracket,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Title and subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logout',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFB93830),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Switch to another account',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF986C68),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Arrow indicator
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE5E1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.angleRight,
                                size: 14,
                                color: Color(0xFFB93830),
                              ),
                            ),
                          ),
                        ],
                      ),
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
