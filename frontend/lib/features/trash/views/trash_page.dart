import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/core/widgets/header.dart';
import 'package:frontend/features/home/models/document_model.dart';
import 'package:frontend/features/home/models/folder_model.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/trash/widgets/trashed_item_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum _TrashTab { folders, documents }

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  final TextEditingController _searchController = TextEditingController();
  _TrashTab _currentTab = _TrashTab.folders;
  String _searchQuery = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTrash();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrash() async {
    setState(() => _loading = true);
    final workspace = context.read<WorkspaceProvider>();
    await Future.wait([
      workspace.fetchTrashedFolders(),
      workspace.fetchTrashedDocuments(),
    ]);
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  List<FolderModel> _filteredFolders(List<FolderModel> source) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((f) => f.folderName.toLowerCase().contains(q)).toList();
  }

  List<DocumentModel> _filteredDocuments(List<DocumentModel> source) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((d) => d.docName.toLowerCase().contains(q)).toList();
  }

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

  Future<void> _restoreFolder(FolderModel folder) async {
    final workspace = context.read<WorkspaceProvider>();
    final success = await workspace.restoreFolder(folder.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Folder "${folder.folderName}" restored')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(workspace.error ?? 'Failed to restore folder'),
        ),
      );
    }
  }

  Future<void> _deleteFolderForever(FolderModel folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: Text(
          'Are you sure you want to permanently delete "${folder.folderName}" and all its contents? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dCtx, true),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final workspace = context.read<WorkspaceProvider>();
      final success = await workspace.deleteFolderForever(folder.id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Folder "${folder.folderName}" deleted permanently')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(workspace.error ?? 'Failed to delete folder permanently'),
          ),
        );
      }
    }
  }

  Future<void> _restoreDocument(DocumentModel doc) async {
    final workspace = context.read<WorkspaceProvider>();
    final success = await workspace.restoreDocument(doc.id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document "${doc.docName}" restored')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(workspace.error ?? 'Failed to restore document'),
        ),
      );
    }
  }

  Future<void> _deleteDocumentForever(DocumentModel doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: Text(
          'Are you sure you want to permanently delete "${doc.docName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dCtx, true),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final workspace = context.read<WorkspaceProvider>();
      final success = await workspace.deleteDocumentForever(doc.id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document "${doc.docName}" deleted permanently')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(workspace.error ?? 'Failed to delete document permanently'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceProvider>();
    final trashedFolders = _filteredFolders(workspace.trashedFolders);
    final trashedDocs = _filteredDocuments(workspace.trashedDocuments);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          Header(
            icon: FontAwesomeIcons.angleLeft,
            title: 'Trash',
            subTitle:
                '${workspace.trashedFolders.length} folders, ${workspace.trashedDocuments.length} files in trash',
            trailing: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh',
              onPressed: _loadTrash,
            ),
          ),

          // Custom Segmented Pill Tab Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _currentTab = _TrashTab.folders),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _currentTab == _TrashTab.folders
                              ? AppColor.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Folders (${workspace.trashedFolders.length})',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: _currentTab == _TrashTab.folders
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _currentTab == _TrashTab.folders
                                  ? AppColor.textDark
                                  : AppColor.textGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _currentTab = _TrashTab.documents),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _currentTab == _TrashTab.documents
                              ? AppColor.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Documents (${workspace.trashedDocuments.length})',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: _currentTab == _TrashTab.documents
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _currentTab == _TrashTab.documents
                                  ? AppColor.textDark
                                  : AppColor.textGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.dmSans(fontSize: 13),
                decoration: InputDecoration(
                  hintText: _currentTab == _TrashTab.folders
                      ? 'Search deleted folders'
                      : 'Search deleted documents',
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Content List
          Expanded(
            child: _loading &&
                    workspace.trashedFolders.isEmpty &&
                    workspace.trashedDocuments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadTrash,
                    child: _currentTab == _TrashTab.folders
                        ? (trashedFolders.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 70),
                                  Icon(
                                    Icons.folder_delete_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      _searchQuery.isEmpty
                                          ? 'No deleted folders in trash'
                                          : 'No folders match "$_searchQuery"',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        color: AppColor.textGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                                itemCount: trashedFolders.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final folder = trashedFolders[index];
                                  return TrashedItemTile(
                                    title: folder.folderName,
                                    subTitle: '${folder.docCount} items in folder',
                                    isFolder: true,
                                    onRestore: () => _restoreFolder(folder),
                                    onDeleteForever: () =>
                                        _deleteFolderForever(folder),
                                  );
                                },
                              ))
                        : (trashedDocs.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 70),
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      _searchQuery.isEmpty
                                          ? 'No deleted documents in trash'
                                          : 'No documents match "$_searchQuery"',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        color: AppColor.textGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                                itemCount: trashedDocs.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final doc = trashedDocs[index];
                                  return TrashedItemTile(
                                    title: doc.docName,
                                    subTitle:
                                        _formatDate(doc.createdAt, doc.language),
                                    isFolder: false,
                                    onRestore: () => _restoreDocument(doc),
                                    onDeleteForever: () =>
                                        _deleteDocumentForever(doc),
                                  );
                                },
                              )),
                  ),
          ),
        ],
      ),
    );
  }
}

