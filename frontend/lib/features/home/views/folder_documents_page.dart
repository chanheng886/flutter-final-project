import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/core/utils/image_file_picker.dart';
import 'package:frontend/core/widgets/header.dart';
import 'package:frontend/features/home/models/document_model.dart';
import 'package:frontend/features/home/models/folder_model.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/home/views/document_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FolderDocumentsPage extends StatefulWidget {
  final FolderModel folder;

  const FolderDocumentsPage({super.key, required this.folder});

  @override
  State<FolderDocumentsPage> createState() => _FolderDocumentsPageState();
}

class _FolderDocumentsPageState extends State<FolderDocumentsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentModel> _documents = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _languageFilter = 'all';
  String? _selectedDocId;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final docs = await context
          .read<WorkspaceProvider>()
          .fetchDocumentsInFolder(widget.folder.id);
      if (mounted) {
        setState(() {
          _documents = docs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<DocumentModel> get _filteredDocuments {
    final q = _searchQuery.trim().toLowerCase();
    return _documents.where((d) {
      if (_languageFilter != 'all' && d.language != _languageFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return d.docName.toLowerCase().contains(q) ||
          (d.content ?? '').toLowerCase().contains(q);
    }).toList();
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

  Future<void> _pickAndUploadImage() async {
    final pickedPath = await ImageFilePicker.pickImageFile(context);
    if (pickedPath == null || !mounted) return;

    final defaultName = pickedPath.split('/').last;
    final nameController = TextEditingController(text: defaultName);
    String selectedLanguage = 'km';
    bool autoScan = true;

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
                        height: 150,
                        width: 260,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image_outlined,
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: autoScan,
                      title: const Text('Scan with OCR immediately'),
                      onChanged: (val) {
                        setDialogState(() => autoScan = val ?? true);
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
                  child: const Text('Import'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final docName = nameController.text.trim().isEmpty
        ? defaultName
        : nameController.text.trim();

    setState(() => _loading = true);
    try {
      final provider = context.read<WorkspaceProvider>();
      final uploaded = await provider.uploadDocument(
        folderId: widget.folder.id,
        filePath: pickedPath,
        docName: docName,
        language: selectedLanguage,
      );
      await _loadDocuments();
      if (mounted && uploaded != null) {
        setState(() => _selectedDocId = uploaded.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                DocumentDetailPage(document: uploaded, autoScan: autoScan),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Upload failed: $e'),
          ),
        );
      }
    }
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
                      'Filter by Language',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              for (final entry in const [
                ('all', 'All Languages'),
                ('km', 'Khmer (KM)'),
                ('en', 'English (EN)'),
                ('km+en', 'Khmer + English (KM+EN)'),
              ])
                ListTile(
                  title: Text(entry.$2),
                  trailing: _languageFilter == entry.$1
                      ? const Icon(Icons.check, color: AppColor.link)
                      : null,
                  onTap: () {
                    setState(() => _languageFilter = entry.$1);
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        );
      },
    );
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
                    await _loadDocuments();
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
                      await _loadDocuments();
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

  void _openDocument(DocumentModel doc) {
    setState(() => _selectedDocId = doc.id);
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => DocumentDetailPage(document: doc),
          ),
        )
        .then((_) => _loadDocuments());
  }

  @override
  Widget build(BuildContext context) {
    final docs = _filteredDocuments;
    final activeId =
        _selectedDocId ?? (docs.isNotEmpty ? docs.first.id : null);

    return Scaffold(
      backgroundColor: AppColor.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUploadImage,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textDark,
        icon: const FaIcon(FontAwesomeIcons.upload, size: 16),
        label: Text(
          'Upload Image',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Header(
            icon: FontAwesomeIcons.angleLeft,
            title: widget.folder.folderName,
            subTitle: '${_documents.length} items',
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'upload') {
                  _pickAndUploadImage();
                } else if (value == 'refresh') {
                  _loadDocuments();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'upload',
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, size: 20),
                      SizedBox(width: 10),
                      Text('Upload Image'),
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
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    : docs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_open_rounded,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'No documents in "${widget.folder.folderName}" yet'
                                      : 'No matching documents found',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    color: AppColor.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_searchQuery.isEmpty)
                                  Text(
                                    'Tap "Upload Image" below to choose an image from your device.',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: AppColor.textGrey,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDocuments,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                              itemCount: docs.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final d = docs[index];
                                final isHighlighted = d.id == activeId;
                                return _DocumentRowTile(
                                  document: d,
                                  colorIndex: index,
                                  subTitle: _formatDate(
                                    d.createdAt,
                                    d.language,
                                  ),
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

class _DocumentRowTile extends StatelessWidget {
  final DocumentModel document;
  final int colorIndex;
  final String subTitle;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _DocumentRowTile({
    required this.document,
    required this.colorIndex,
    required this.subTitle,
    required this.isHighlighted,
    required this.onTap,
    required this.onMoreTap,
  });

  static const List<Color> _docIconColors = [
    Color(0xFF38BDF8), // light blue
    Color(0xFFEF4444), // red
    Color(0xFF22C55E), // green
  ];

  @override
  Widget build(BuildContext context) {
    final iconColor = _docIconColors[colorIndex % _docIconColors.length];

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
                FaIcon(
                  FontAwesomeIcons.solidFileLines,
                  color: iconColor,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.docName,
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
                        subTitle,
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
