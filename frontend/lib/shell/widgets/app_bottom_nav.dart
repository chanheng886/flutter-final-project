import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/shell/widgets/nav_item.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onScan,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: SafeArea(
        child: SizedBox(
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Nav bar background
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NavItem(
                        icon: FontAwesomeIcons.solidHouse,
                        label: 'Home',
                        selected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      NavItem(
                        icon: FontAwesomeIcons.solidFolder,
                        label: 'Folders',
                        selected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                      const SizedBox(width: 56),
                      NavItem(
                        icon: FontAwesomeIcons.history,
                        label: 'Recent',
                        selected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                      NavItem(
                        icon: FontAwesomeIcons.gear,
                        label: 'Settings',
                        selected: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                    ],
                  ),
                ),
              ),

              // Center scan FAB (floats above the bar)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onScan,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
