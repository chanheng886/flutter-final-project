import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/core/widgets/header.dart';
import 'package:frontend/features/home/models/document_model.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/home/views/document_detail_page.dart';
import 'package:frontend/features/recent/widgets/recent_document_tile.dart';
import 'package:frontend/features/recent/widgets/recent_filter_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecentPage extends StatefulWidget {
  final bool showBackButton;

  const RecentPage({super.key, this.showBackButton = false});

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RecentSortOption _sortBy = RecentSortOption.newest;
  String _languageFilter = 'all';
  String? _selectedDocId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadRecentDocuments();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentDocuments() async {
    setState(() => _loading = true);
    await context.read<WorkspaceProvider>().fetchRecentDocuments();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  List<DocumentModel> _getFilteredDocuments(List<DocumentModel> source) {
    final query = _searchQuery.trim().toLowerCase();
    final list = source.where((d) {
      if (_languageFilter != 'all' && d.language != _languageFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return d.docName.toLowerCase().contains(query) ||
          (d.content ?? '').toLowerCase().contains(query);
    }).toList();

    switch (_sortBy) {
      case RecentSortOption.newest:
        list.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        break;
      case RecentSortOption.oldest:
        list.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });
        break;
      case RecentSortOption.alphabetical:
        list.sort(
          (a, b) =>
              a.docName.toLowerCase().compareTo(b.docName.toLowerCase()),
        );
        break;
    }
    return list;
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

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return RecentFilterSheet(
          selectedSort: _sortBy,
          selectedLanguage: _languageFilter,
          onSortChanged: (val) => setState(() => _sortBy = val),
          onLanguageChanged: (val) => setState(() => _languageFilter = val),
        );
      },
    );
  }

  void _openDocument(DocumentModel doc) {
    setState(() => _selectedDocId = doc.id);
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => DocumentDetailPage(document: doc),
          ),
        )
        .then((_) {
          if (mounted) {
            _loadRecentDocuments();
          }
        });
  }

  void _showDocumentActions(DocumentModel doc) {
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
                  _openDocument(doc);
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
                  if (newName != null && newName.isNotEmpty && mounted) {
                    await context
                        .read<WorkspaceProvider>()
                        .renameDocument(doc.id, newName);
                    _loadRecentDocuments();
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
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Document "${doc.docName}" moved to trash'),
                        ),
                      );
                      _loadRecentDocuments();
                    }
                  } catch (e) {
                    if (mounted) {
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
    final docs = _getFilteredDocuments(workspace.recentDocuments);
    final activeId =
        _selectedDocId ?? (docs.isNotEmpty ? docs.first.id : null);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: Column(
        children: [
          Header(
            icon: widget.showBackButton ? FontAwesomeIcons.angleLeft : null,
            title: 'Recent Files',
            subTitle: '${docs.length} documents',
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'refresh') {
                  _loadRecentDocuments();
                } else if (value == 'filter') {
                  _showFilterSheet();
                }
              },
              itemBuilder: (_) => const [
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
                PopupMenuItem(
                  value: 'filter',
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 20),
                      SizedBox(width: 10),
                      Text('Sort & Filter'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Search & Filter Row matching mockup layout
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
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const SizedBox(
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
                        if (_languageFilter != 'all' ||
                            _sortBy != RecentSortOption.newest)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColor.link,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Document List
          Expanded(
            child: _loading && workspace.recentDocuments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadRecentDocuments,
                    child: docs.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Icon(
                                Icons.history_rounded,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? (_languageFilter == 'all'
                                          ? 'No recent documents yet'
                                          : 'No documents match this filter')
                                      : 'No documents match "$_searchQuery"',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    color: AppColor.textGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Uploaded and scanned documents will appear here.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: AppColor.textGrey,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: docs.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final d = docs[index];
                              final isHighlighted = d.id == activeId;
                              return RecentDocumentTile(
                                document: d,
                                colorIndex: index,
                                subTitle: _formatDate(d.createdAt, d.language),
                                isHighlighted: isHighlighted,
                                onTap: () => _openDocument(d),
                                onMoreTap: () => _showDocumentActions(d),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

