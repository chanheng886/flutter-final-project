import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/features/folder/views/folders_page.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/home/views/folder_documents_page.dart';
import 'package:frontend/features/home/views/widgets/folder_card.dart';
import 'package:frontend/features/home/views/widgets/new_folder_card.dart';
import 'package:provider/provider.dart';

class MyFolderSection extends StatelessWidget {
  const MyFolderSection({super.key});

  // ==========================================
  // CREATE FOLDER DIALOG
  // ==========================================

  Future<void> _showCreateFolderDialog(BuildContext context) async {
    final controller = TextEditingController();

    final createdName = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColor.link.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.create_new_folder_outlined,
                    color: AppColor.link,
                    size: 27,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Create New Folder',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202533),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Organize your documents by creating a new folder.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF8A91A0),
                  ),
                ),

                const SizedBox(height: 22),

                // Folder name label
                const Text(
                  'Folder name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424958),
                  ),
                ),

                const SizedBox(height: 9),

                // Text field
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.of(dialogContext).pop(value.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. Personal Documents',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB0B6C2),
                    ),
                    prefixIcon: const Icon(
                      Icons.folder_outlined,
                      color: Color(0xFF9299A8),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF6F7F9),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: Color(0xFFEAECF0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(color: AppColor.link, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF626B7A),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final name = controller.text.trim();

                          if (name.isNotEmpty) {
                            Navigator.of(dialogContext).pop(name);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColor.link,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Folder',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();

    // ==========================================
    // CREATE FOLDER API
    // ==========================================

    if (createdName == null || createdName.isEmpty || !context.mounted) {
      return;
    }

    final workspace = context.read<WorkspaceProvider>();

    final created = await workspace.createFolder(createdName);

    if (!context.mounted) return;

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF21865B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text('Folder "${created.folderName}" created successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(workspace.error ?? 'Failed to create folder'),
        ),
      );
    }
  }

  // ==========================================
  // VIEW ALL FOLDERS
  // ==========================================

  void _viewAllFolders(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => const FoldersPage(showBackButton: true),
          ),
        )
        .then((_) {
          if (context.mounted) {
            context.read<WorkspaceProvider>().loadDashboard();
          }
        });
  }

  // ==========================================
  // OPEN FOLDER DOCUMENTS
  // ==========================================

  void _openFolder(BuildContext context, dynamic folder) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => FolderDocumentsPage(folder: folder),
          ),
        )
        .then((_) {
          if (context.mounted) {
            context.read<WorkspaceProvider>().loadDashboard();
          }
        });
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();

    final visibleFolders = workspace.folders.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEF0F4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================
          // HEADER
          // ======================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColor.link.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.folder_copy_outlined,
                  color: AppColor.link,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Folders',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202533),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${workspace.folders.length} folders available',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9299A8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // View all button
              InkWell(
                onTap: () => _viewAllFolders(context),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.link,
                        ),
                      ),

                      const SizedBox(width: 3),

                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColor.link,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ======================================
          // FOLDER GRID
          // ======================================
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleFolders.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              // New folder card
              if (index == visibleFolders.length) {
                return NewFolderCard(
                  onTap: () => _showCreateFolderDialog(context),
                );
              }

              // Existing folder card
              final folder = visibleFolders[index];

              return FolderCard(
                name: folder.folderName,
                itemCount: folder.docCount,
                onTap: () => _openFolder(context, folder),
              );
            },
          ),
        ],
      ),
    );
  }
}
