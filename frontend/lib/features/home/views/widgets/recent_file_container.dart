import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/features/home/models/document_model.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/home/views/document_detail_page.dart';
import 'package:frontend/features/home/views/widgets/recent_file_tile.dart';
import 'package:frontend/features/recent/views/recent_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecentFileContainer extends StatelessWidget {
  const RecentFileContainer({super.key});

  String _formatDate(DateTime? dt, String language) {
    if (dt == null) return 'Language: ${language.toUpperCase()}';
    final local = dt.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}  •  ${language.toUpperCase()}';
  }

  void _showDocumentActions(BuildContext context, DocumentModel doc) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.document_scanner_outlined),
                title: const Text('Open & Scan OCR'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => DocumentDetailPage(document: doc),
                        ),
                      )
                      .then((_) {
                        if (context.mounted) {
                          context.read<WorkspaceProvider>().loadDashboard();
                        }
                      });
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename document'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final controller = TextEditingController(text: doc.docName);
                  final newName = await showDialog<String>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Rename Document'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter new document name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(dCtx, controller.text.trim()),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                  if (newName != null &&
                      newName.isNotEmpty &&
                      context.mounted) {
                    await context
                        .read<WorkspaceProvider>()
                        .renameDocument(doc.id, newName);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Move to Trash',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    await context
                        .read<WorkspaceProvider>()
                        .moveDocumentToTrash(doc.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Document "${doc.docName}" moved to trash'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red.shade700,
                          content: Text('Failed to move to trash: $e'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();
    final docs = workspace.recentDocuments;

    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 22, bottom: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently added',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RecentPage(showBackButton: true),
                            ),
                          )
                          .then((_) {
                            if (context.mounted) {
                              context.read<WorkspaceProvider>().loadDashboard();
                            }
                          });
                    },
                    child: const Text(
                      'View all >',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.link,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (workspace.loading && docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (docs.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  itemCount: min(3, docs.length),
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 0.4,
                    indent: 8,
                    endIndent: 8,
                  ),
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    return RecentFileTile(
                      title: d.docName,
                      subTitle: _formatDate(d.createdAt, d.language),
                      colorIndex: index,
                      action: () => _showDocumentActions(context, d),
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DocumentDetailPage(document: d),
                              ),
                            )
                            .then((_) {
                              if (context.mounted) {
                                context
                                    .read<WorkspaceProvider>()
                                    .loadDashboard();
                              }
                            });
                      },
                    );
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No recently added documents',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload an image to scan and see it here',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColor.textGrey,
                          ),
                        ),
                      ],
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
