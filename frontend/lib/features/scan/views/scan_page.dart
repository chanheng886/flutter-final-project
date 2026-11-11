import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_color.dart';
import 'package:frontend/features/home/providers/workspace_provider.dart';
import 'package:frontend/features/home/views/document_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? _imagePath;
  bool _isUploading = false;
  final _nameController = TextEditingController();
  String _selectedLanguage = 'km';

  @override
  void initState() {
    super.initState();
    // Auto-open camera when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCamera());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1800,
      maxHeight: 1800,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (picked == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() {
      _imagePath = picked.path;
      _nameController.text =
          'Scan_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  Future<void> _retake() async {
    setState(() => _imagePath = null);
    await _openCamera();
  }

  Future<void> _upload() async {
    if (_imagePath == null) return;
    final provider = context.read<WorkspaceProvider>();

    if (provider.folders.isEmpty) {
      await provider.createFolder('My Scans');
    }
    if (!mounted || provider.folders.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      final docName = _nameController.text.trim().isEmpty
          ? 'Scan_${DateTime.now().millisecondsSinceEpoch}'
          : _nameController.text.trim();

      final uploaded = await provider.uploadDocument(
        folderId: provider.folders.first.id,
        filePath: _imagePath!,
        docName: docName,
        language: _selectedLanguage,
      );

      if (uploaded != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                DocumentDetailPage(document: uploaded, autoScan: true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
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
    return Scaffold(
      backgroundColor: const Color(0xFF10141D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Scan Document',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: _imagePath == null
          ? const Center(child: CircularProgressIndicator(color: AppColor.primary))
          : _buildPreviewBody(),
    );
  }

  Widget _buildPreviewBody() {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(_imagePath!),
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ),

        // Bottom panel
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B2230),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding:
              const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document name
              Text(
                'Document Name',
                style: GoogleFonts.dmSans(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: GoogleFonts.dmSans(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF252D3D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Enter document name',
                  hintStyle: GoogleFonts.dmSans(color: Colors.white38),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 16),

              // OCR Language
              Text(
                'OCR Language',
                style: GoogleFonts.dmSans(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                dropdownColor: const Color(0xFF252D3D),
                style: GoogleFonts.dmSans(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF252D3D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'km', child: Text('Khmer (km)')),
                  DropdownMenuItem(
                      value: 'en', child: Text('English (en)')),
                  DropdownMenuItem(
                      value: 'km+en',
                      child: Text('Khmer + English (km+en)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  // Retake button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _retake,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColor.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const FaIcon(
                        FontAwesomeIcons.cameraRotate,
                        size: 16,
                        color: AppColor.primary,
                      ),
                      label: Text(
                        'Retake',
                        style: GoogleFonts.dmSans(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Generate button
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isUploading ? null : _upload,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.black),
                            )
                          : const FaIcon(
                              FontAwesomeIcons.wandMagicSparkles,
                              size: 16,
                            ),
                      label: Text(
                        _isUploading ? 'Generating...' : 'Generate Text',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

