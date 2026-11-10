import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/features/setting/views/theme_page.dart';
import 'package:frontend/features/setting/widgets/setting_list_tile.dart';
import 'package:frontend/features/trash/views/trash_page.dart';

class AppSection extends StatelessWidget {
  const AppSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 17),
          child: Column(
            children: [
              SettingListTile(
                icon: FontAwesomeIcons.earthAsia,
                color: AppColor.primary,
                title: "Languages",
                subTitle: "Change language",
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Divider(thickness: 0.3),
              ),
              SettingListTile(
                icon: FontAwesomeIcons.lightbulb,
                color: AppColor.primary,
                title: 'Theme',
                subTitle: 'Choose dark or light',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ThemePage(),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Divider(thickness: 0.3),
              ),
              SettingListTile(
                icon: FontAwesomeIcons.bell,
                color: AppColor.primary,
                title: 'Notification',
                subTitle: 'Get notification to disturbed you',
                onTap: () {},
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Divider(thickness: 0.3),
              ),
              SettingListTile(
                icon: FontAwesomeIcons.trashCan,
                color: AppColor.primary,
                title: 'Delete file & folder',
                subTitle: 'File and folder that deleted',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TrashPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
