import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/utils/image_file_picker.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/home/views/document_detail_page.dart';
import 'package:frontend/features/home/views/widgets/upload_action_card.dart';
import 'package:provider/provider.dart';

class UploadButton extends StatelessWidget {
  const new({super.key});

  Future<void> _pickAndImport(BuildContext context) async {
    // 1. Open image folder immediately
    final pickedPath = await ImageFilePicker.pickImageFile(context);
    if (pickedPath == null || !context.mounted) return;

    final provider = context.read<WorkspaceProvider>();
    if (provider.folders.isEmpty) {
      await provider.createFolder('My Scans');
    }
    if (!context.mounted || provider.folders.isEmpty) return;

    final defaultName = pickedPath.split('/').last;
    final nameController = TextEditingController(text: defaultName);
    String selectedFolderId = provider.folders.first.id;
    String selectedLanguage = 'km';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Import Image'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(pickedPath),
                        height: 140,
                        width: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedFolderId,
                      decoration: const InputDecoration(
                        labelText: 'Folder',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final f in provider.folders)
                          DropdownMenuItem(
                            value: f.id,
                            child: Text(f.folderName),
                          ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedFolderId = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Document name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'OCR Language',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'km', child: Text('Khmer (km)')),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English (en)'),
                        ),
                        DropdownMenuItem(
                          value: 'km+en',
                          child: Text('Khmer + English (km+en)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedLanguage = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Import & Scan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final docName = nameController.text.trim().isEmpty
        ? defaultName
        : nameController.text.trim();

    try {
      final uploaded = await provider.uploadDocument(
        folderId: selectedFolderId,
        filePath: pickedPath,
        docName: docName,
        language: selectedLanguage,
      );
      if (uploaded != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                DocumentDetailPage(document: uploaded, autoScan: true),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Upload failed: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: UploadActionCard(
              icon: FontAwesomeIcons.cloud,
              iconColor: const Color(0xffffd60a),
              title: 'Upload file',
              subTitle: 'Upload from device',
              onTap: () => _pickAndImport(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: UploadActionCard(
              icon: FontAwesomeIcons.solidImage,
              iconColor: Colors.green.shade400,
              title: 'Upload image',
              subTitle: 'From gallery or camera',
              onTap: () => _pickAndImport(context),
            ),
          ),
        ],
      ),
    );
  }
}
