import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/core/widgets/header.dart';
import 'package:frontend/features/home/models/document_model.dart';
import 'package:frontend/features/home/models/ocr_result_model.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/scan/views/scan_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DocumentDetailPage extends StatefulWidget {
  final DocumentModel document;
  final bool autoScan;

  const DocumentDetailPage({
    super.key,
    required this.document,
    this.autoScan = false,
  });

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  OcrResultModel? _ocrResult;
  bool _loading = true;
  bool _scanning = false;
  bool _exporting = false;
  bool _showRawText = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.autoScan) {
      _loading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scanNow();
      });
    } else {
      _loadOcr();
    }
  }

  Future<void> _loadOcr() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await context
          .read<WorkspaceProvider>()
          .getOcrResult(widget.document.id);
      if (mounted) {
        setState(() {
          _ocrResult = res;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // A 404 / "not found" simply means the document has not been scanned yet.
        // It is not an application error.
        final msg = e.toString().toLowerCase();
        final isNotFound = msg.contains('not found') || msg.contains('404');
        setState(() {
          _ocrResult = null;
          _error = isNotFound ? null : e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _scanNow() async {
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      final res = await context
          .read<WorkspaceProvider>()
          .scanDocument(widget.document.id);
      if (mounted) {
        setState(() {
          _ocrResult = res;
          _scanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OCR scan completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _scanning = false;
        });
      }
    }
  }

  Future<void> _exportFile(String ext) async {
    setState(() => _exporting = true);
    try {
      final provider = context.read<WorkspaceProvider>();
      final bytes = ext == 'docx'
          ? await provider.exportDocxBytes(widget.document.id)
          : await provider.exportPdfBytes(widget.document.id);

      final safeName = widget.document.docName
          .replaceAll(RegExp(r'[^\w\u1780-\u17FF\- ]'), '_')
          .trim();
      final downloadsDir = Directory(
        '${Platform.environment['HOME'] ?? Directory.systemTemp.path}/Downloads',
      );
      final targetDir =
          await downloadsDir.exists() ? downloadsDir : Directory.systemTemp;
      final outPath =
          '${targetDir.path}/${safeName.isEmpty ? widget.document.id : safeName}.$ext';

      final file = File(outPath);
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $outPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Export failed: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAiText = _ocrResult?.aiCorrectedText != null &&
        _ocrResult!.aiCorrectedText!.trim().isNotEmpty;
    final text = (_showRawText && _ocrResult != null)
        ? _ocrResult!.rawText
        : (_ocrResult?.displayText ?? widget.document.content ?? '');

    return Scaffold(
      body: Column(
        children: [
          Header(
            icon: FontAwesomeIcons.angleLeft,
            title: widget.document.docName,
            subTitle:
                'Language: ${widget.document.language.toUpperCase()}${_ocrResult != null ? '  •  Confidence: ${_ocrResult!.confidenceScore.toStringAsFixed(1)}%' : ''}',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _scanning ? null : _scanNow,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _scanning
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const FaIcon(
                                  FontAwesomeIcons.wandMagicSparkles,
                                  size: 16,
                                ),
                          label: Text(
                            _scanning
                                ? 'Scanning...'
                                : (text.isEmpty ? 'Run OCR Scan' : 'Re-scan'),
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed:
                            (text.isEmpty || _exporting)
                                ? null
                                : () => _exportFile('docx'),
                        icon: const FaIcon(FontAwesomeIcons.fileWord, size: 16),
                        label: const Text('DOCX'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed:
                            (text.isEmpty || _exporting)
                                ? null
                                : () => _exportFile('pdf'),
                        icon: const FaIcon(FontAwesomeIcons.filePdf, size: 16),
                        label: const Text('PDF'),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _error!.replaceAll('ApiException: ', ''),
                            style: const TextStyle(color: Color(0xFFB91C1C)),
                          ),
                          if (_error!.contains('not found on disk') ||
                              _error!.contains('restarted')) ...[
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const ScanPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: const Text('Scan New Document'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    constraints: const BoxConstraints(minHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : text.isEmpty
                            ? Center(
                                child: Text(
                                  'No OCR text yet.\nClick "Run OCR Scan" above to extract text.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    color: AppColor.textGrey,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Extracted Text',
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: hasAiText
                                                  ? const Color(0xFFDCFCE7)
                                                  : const Color(0xFFFEF3C7),
                                              borderRadius:
                                                  BorderRadius.circular(99),
                                            ),
                                            child: Text(
                                              hasAiText
                                                  ? 'AI Corrected'
                                                  : 'Tesseract Only (Set GEMINI_API_KEY)',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: hasAiText
                                                    ? const Color(0xFF166534)
                                                    : const Color(0xFF92400E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (hasAiText)
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _showRawText = !_showRawText;
                                                });
                                              },
                                              child: Text(
                                                _showRawText
                                                    ? 'Show AI Text'
                                                    : 'Show Raw OCR',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          IconButton(
                                            tooltip: 'Copy text',
                                            icon: const Icon(
                                              Icons.copy,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              Clipboard.setData(
                                                ClipboardData(text: text),
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Copied to clipboard',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  SelectableText(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.7,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

