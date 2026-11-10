import 'dart:io';

import 'package:flutter/material.dart';

class ImageFilePicker {
  static String _defaultImagesDir() {
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      final pictures = Directory('$home/Pictures');
      if (pictures.existsSync()) {
        return '${pictures.path}/';
      }
      return '$home/';
    }
    return '${Directory.current.path}/';
  }

  /// Automatically opens the native OS file chooser in the user's Pictures folder
  /// and returns the selected image file path (or null if cancelled).
  static Future<String?> pickImageFile(BuildContext context) async {
    final startDir = _defaultImagesDir();

    if (Platform.isLinux) {
      try {
        final result = await Process.run('zenity', [
          '--file-selection',
          '--title=Select an image',
          '--filename=$startDir',
          '--file-filter=Images (*.png *.jpg *.jpeg *.webp *.bmp *.tif *.tiff) | *.png *.jpg *.jpeg *.webp *.bmp *.tif *.tiff *.PNG *.JPG *.JPEG',
          '--file-filter=All files | *',
        ]);
        if (result.exitCode == 0) {
          final selected = result.stdout.toString().trim();
          if (selected.isNotEmpty && File(selected).existsSync()) {
            return selected;
          }
        } else {
          // User cancelled the native dialog
          return null;
        }
      } catch (_) {
        // Fallback to in-app image browser below if zenity is unavailable
      }
    }

    if (!context.mounted) return null;
    return _showFallbackBrowserDialog(context, startDir);
  }

  static Future<String?> _showFallbackBrowserDialog(
    BuildContext context,
    String initialDir,
  ) async {
    Directory currentDir = Directory(initialDir);
    if (!currentDir.existsSync()) {
      currentDir = Directory.current;
    }

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final entries = <FileSystemEntity>[];
            try {
              entries.addAll(
                currentDir.listSync().where((e) {
                  final name = e.path.split('/').last;
                  if (name.startsWith('.')) return false;
                  if (e is Directory) return true;
                  final lower = name.toLowerCase();
                  return lower.endsWith('.png') ||
                      lower.endsWith('.jpg') ||
                      lower.endsWith('.jpeg') ||
                      lower.endsWith('.webp') ||
                      lower.endsWith('.bmp') ||
                      lower.endsWith('.tif') ||
                      lower.endsWith('.tiff');
                }),
              );
              entries.sort((a, b) {
                if (a is Directory && b is! Directory) return -1;
                if (a is! Directory && b is Directory) return 1;
                return a.path.compareTo(b.path);
              });
            } catch (_) {}

            return AlertDialog(
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    tooltip: 'Parent folder',
                    onPressed: () {
                      setDialogState(() {
                        currentDir = currentDir.parent;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      currentDir.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                height: 360,
                child: entries.isEmpty
                    ? const Center(child: Text('No images in this folder'))
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entity = entries[index];
                          final name = entity.path.split('/').last;
                          final isDir = entity is Directory;
                          return ListTile(
                            leading: Icon(
                              isDir ? Icons.folder : Icons.image_outlined,
                              color: isDir ? Colors.amber : Colors.blue,
                            ),
                            title: Text(name),
                            onTap: () {
                              if (isDir) {
                                setDialogState(() {
                                  currentDir = Directory(entity.path);
                                });
                              } else {
                                Navigator.of(dialogContext).pop(entity.path);
                              }
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
