import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';
import 'package:frontend/features/home/views/widgets/circle_icon_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final displayName = user?.email.split('@').firstOrNull;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: "https://i.pinimg.com/736x/26/2b/57/262b57cbbf2244513e1aad7e56698090.jpg",
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $displayName",
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Today 18 Sep',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColor.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CircleIconButton(icon: FontAwesomeIcons.bell, onTap: () {}),
              SizedBox(width: 12),
              CircleIconButton(
                icon: FontAwesomeIcons.magnifyingGlass,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
