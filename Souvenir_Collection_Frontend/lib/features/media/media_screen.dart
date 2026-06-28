import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gold_button.dart';
import '../../services/media_service.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  String? _uploadedUrl;
  bool _isUploading = false;
  File? _previewFile;

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final xFile =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);
    if (xFile == null) return;

    final file = File(xFile.path);
    setState(() {
      _previewFile = file;
      _isUploading = true;
      _uploadedUrl = null;
    });

    try {
      final mediaService = context.read<MediaService>();
      final url = await mediaService.uploadMedia(file.path);
      if (mounted) {
        setState(() {
          _uploadedUrl = url;
          _isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _copyUrl() {
    if (_uploadedUrl == null) return;
    Clipboard.setData(ClipboardData(text: _uploadedUrl!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: AppBar(
        backgroundColor: HColors.surface,
        title: Text('Media Upload',
            style: HText.headlineMd.copyWith(color: HColors.primary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload area
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUpload,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: HColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: HColors.outlineVariant.withValues(alpha: 0.5),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: _previewFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _previewFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              size: 48,
                              color: HColors.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text('Tap to select an image',
                              style: HText.bodyLg
                                  .copyWith(color: HColors.outline)),
                          const SizedBox(height: 4),
                          Text('JPG, PNG — Max 10 MB',
                              style: HText.labelSm
                                  .copyWith(color: HColors.outline)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            if (_isUploading) ...[
              const LinearProgressIndicator(color: HColors.primary),
              const SizedBox(height: 8),
              Text('Uploading...',
                  style: HText.bodyMd.copyWith(color: HColors.outline),
                  textAlign: TextAlign.center),
            ] else if (_previewFile != null)
              GoldButton(
                text: 'Upload Image',
                onPressed: _pickAndUpload,
                icon: Icons.upload,
              ),

            if (_uploadedUrl != null) ...[
              const SizedBox(height: 20),
              // Success banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: HColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: HColors.success, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Upload successful!',
                          style: TextStyle(color: HColors.success)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // URL display with copy
              Text('Image URL',
                  style: HText.labelSm.copyWith(color: HColors.outline)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: HColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _uploadedUrl!,
                        style: HText.bodyMd
                            .copyWith(color: HColors.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _copyUrl,
                      icon: const Icon(Icons.copy, color: HColors.primary),
                      tooltip: 'Copy URL',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Preview of uploaded image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  _uploadedUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color:
                        HColors.primaryContainer.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(Icons.broken_image,
                          color:
                              HColors.primary.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
