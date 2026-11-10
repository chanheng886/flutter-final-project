import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/core/widgets/header.dart';
import 'package:frontend/features/home/models/folder_model.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/home/views/folder_documents_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum _FolderSort { newest, mostItems, alphabetical }

class FoldersPage extends StatefulWidget {
  final bool showBackButton;

  const FoldersPage({super.key, this.showBackButton = false});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _FolderSort _sortBy = _FolderSort.newest;
  String? _selectedFolderId;

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FolderModel> _filteredFolders(List<FolderModel> source) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = source.where((f) {
      if (query.isEmpty) return true;
      return f.folderName.toLowerCase().contains(query);
    }).toList();

    switch (_sortBy) {
      case _FolderSort.mostItems:
        filtered.sort((a, b) => b.docCount.compareTo(a.docCount));
        break;
      case _FolderSort.alphabetical:
        filtered.sort(
          (a, b) =>
              a.folderName.toLowerCase().compareTo(b.folderName.toLowerCase()),
        );
        break;
      case _FolderSort.newest:
        break;
    }
    return filtered;
  }

  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();
    final createdName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Folder'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter folder name',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (val) => Navigator.of(dialogContext).pop(val.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (createdName != null && createdName.isNotEmpty && mounted) {
      final workspace = context.read<WorkspaceProvider>();
      final created = await workspace.createFolder(createdName);
      if (!mounted) return;
      if (created != null) {
        setState(() => _selectedFolderId = created.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "${created.folderName}" created')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(workspace.error ?? 'Failed to create folder'),
          ),
        );
      }
    }
  }

  void _showFolderActions(FolderModel folder) {
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
                leading: const Icon(Icons.folder_open_rounded),
                title: const Text('Open folder'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openFolder(folder);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename folder'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final controller =
                      TextEditingController(text: folder.folderName);
                  final newName = await showDialog<String>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Rename Folder'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
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
                  if (newName != null && newName.isNotEmpty && mounted) {
                    await context
                        .read<WorkspaceProvider>()
                        .renameFolder(folder.id, newName);
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
                  await context
                      .read<WorkspaceProvider>()
                      .moveFolderToTrash(folder.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Sort Folders By',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: _sortBy == _FolderSort.newest
                      ? AppColor.link
                      : AppColor.textGrey,
                ),
                title: const Text('Default (Newest)'),
                trailing: _sortBy == _FolderSort.newest
                    ? const Icon(Icons.check, color: AppColor.link)
                    : null,
                onTap: () {
                  setState(() => _sortBy = _FolderSort.newest);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.layers_outlined,
                  color: _sortBy == _FolderSort.mostItems
                      ? AppColor.link
                      : AppColor.textGrey,
                ),
                title: const Text('Most items'),
                trailing: _sortBy == _FolderSort.mostItems
                    ? const Icon(Icons.check, color: AppColor.link)
                    : null,
                onTap: () {
                  setState(() => _sortBy = _FolderSort.mostItems);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.sort_by_alpha,
                  color: _sortBy == _FolderSort.alphabetical
                      ? AppColor.link
                      : AppColor.textGrey,
                ),
                title: const Text('Folder name (A–Z)'),
                trailing: _sortBy == _FolderSort.alphabetical
                    ? const Icon(Icons.check, color: AppColor.link)
                    : null,
                onTap: () {
                  setState(() => _sortBy = _FolderSort.alphabetical);
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openFolder(FolderModel folder) {
    setState(() => _selectedFolderId = folder.id);
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => FolderDocumentsPage(folder: folder),
          ),
        )
        .then((_) {
          if (mounted) {
            context.read<WorkspaceProvider>().loadDashboard();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();
    final folders = _filteredFolders(workspace.folders);
    final activeId =
        _selectedFolderId ?? (folders.isNotEmpty ? folders.first.id : null);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          Header(
            icon: widget.showBackButton ? FontAwesomeIcons.angleLeft : null,
            title: 'My Folders',
            subTitle: '${workspace.folders.length} folders',
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'new') {
                  _showCreateFolderDialog();
                } else if (value == 'refresh') {
                  context.read<WorkspaceProvider>().loadDashboard();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'new',
                  child: Row(
                    children: [
                      Icon(Icons.create_new_folder_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('New Folder'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 10),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Search & Filter Row matching mockup
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.dmSans(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Find document',
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColor.textGrey,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColor.textDark,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _showFilterSheet,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Icon(
                          Icons.filter_alt_outlined,
                          size: 22,
                          color: AppColor.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Folder List
          Expanded(
            child: workspace.loading && workspace.folders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () =>
                        context.read<WorkspaceProvider>().loadDashboard(),
                    child: folders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Icon(
                                Icons.folder_open_rounded,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'No folders yet'
                                      : 'No matching folders found',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    color: AppColor.textGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_searchQuery.isEmpty)
                                Center(
                                  child: FilledButton.icon(
                                    onPressed: _showCreateFolderDialog,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColor.primary,
                                      foregroundColor: AppColor.textDark,
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Folder'),
                                  ),
                                ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: folders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final folder = folders[index];
                              final isHighlighted = folder.id == activeId;
                              return _FolderRowTile(
                                folder: folder,
                                isHighlighted: isHighlighted,
                                onTap: () => _openFolder(folder),
                                onMoreTap: () => _showFolderActions(folder),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFolderDialog,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textDark,
        tooltip: 'New Folder',
        child: const Icon(Icons.create_new_folder_rounded),
      ),
    );
  }
}

class _FolderRowTile extends StatelessWidget {
  final FolderModel folder;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _FolderRowTile({
    required this.folder,
    required this.isHighlighted,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.white, AppColor.primary],
              )
            : null,
        color: isHighlighted ? null : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isHighlighted
            ? Border.all(color: AppColor.primary, width: 1.3)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Folder Icon with detail line matching mockup
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.solidFolder,
                      color: Color(0xFF6DB9FF),
                      size: 34,
                    ),
                    Positioned(
                      left: 5,
                      top: 9,
                      child: Container(
                        width: 14,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Folder Name & Item Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.folderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${folder.docCount} items',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColor.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColor.textDark,
                ),
                const SizedBox(width: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onMoreTap,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: AppColor.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
