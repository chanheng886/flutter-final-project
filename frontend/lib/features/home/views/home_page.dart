import 'package:flutter/material.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/home/views/widgets/home_header.dart';
import 'package:frontend/features/home/views/widgets/my_folder_section.dart';
import 'package:frontend/features/home/views/widgets/recent_file_container.dart';
import 'package:frontend/features/home/views/widgets/upload_button.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WorkspaceProvider>().loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<WorkspaceProvider>().loadDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              HomeHeader(),
              Transform.translate(
                offset: Offset(0, -24),
                child: MyFolderSection(),
              ),
              UploadButton(),
              RecentFileContainer(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
