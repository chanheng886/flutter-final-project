import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/features/setting/widgets/setting_list_tile.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0, 2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingListTile(
              icon: FontAwesomeIcons.solidUser,
              color: AppColor.primary,
              title: 'Profile',
              subTitle: 'View and edit your profile',
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Divider(color: Colors.grey, height: 12, thickness: 0.3),
            ),
            SettingListTile(
              icon: FontAwesomeIcons.key,
              color: AppColor.primary,
              title: 'Change password',
              subTitle: 'Update your password',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
