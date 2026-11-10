import 'package:flutter/material.dart';
import 'package:frontend/features/folder/views/folders_page.dart';
import 'package:frontend/features/home/views/home_page.dart';
import 'package:frontend/features/recent/views/recent_page.dart';
import 'package:frontend/features/setting/views/setting_page.dart';
import 'package:frontend/shell/widgets/app_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final List<Widget> _pages = const [
    HomePage(),
    FoldersPage(),
    RecentPage(),
    SettingPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        onScan: () {},
      ),
    );
  }
}
