import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../themes/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/gradient_button.dart';

/// Screen for uploading a selfie or full-body photo for AI analysis
class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  File? _selectedImage;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Text('Analyze Your Look',
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Photo preview / upload area
                      GestureDetector(
                        onTap: () => _showPickerSheet(context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 320,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _selectedImage != null
                                  ? AppTheme.primaryGold
                                  : AppTheme.borderGlass,
                              width: _selectedImage != null ? 2 : 1,
                            ),
                            color: AppTheme.cardBg,
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.primaryGold
                                            .withOpacity(0.1),
                                        border: Border.all(
                                          color: AppTheme.primaryGold
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo_outlined,
                                        color: AppTheme.primaryGold,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Upload Your Photo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Selfie or full-body photo for best results',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOut),

                      const SizedBox(height: 28),

                      // Tips
                      if (_selectedImage == null) ...[
                        _buildTipCard(context),
                        const SizedBox(height: 24),
                      ],

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildOptionButton(
                              context,
                              icon: Icons.photo_library_outlined,
                              label: 'Gallery',
                              onTap: () => _pickImage(ImageSource.gallery),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOptionButton(
                              context,
                              icon: Icons.camera_alt_outlined,
                              label: 'Camera',
                              onTap: () => _pickImage(ImageSource.camera),
                            ),
                          ),
                        ],
                      ),

                      if (_selectedImage != null) ...[
                        const SizedBox(height: 24),
                        GradientButton(
                          onPressed: () {
                            context.push(
                              AppRoutes.aiAnalysis,
                              extra: _selectedImage!.path,
                            );
                          },
                          text: 'ANALYZE WITH AI  ✨',
                          gradient: AppTheme.goldGradient,
                          textColor: Colors.black,
                        ).animate().slideY(begin: 0.3, duration: 400.ms),
                      ],
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

  Widget _buildTipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: AppTheme.primaryGold, size: 18),
              const SizedBox(width: 8),
              Text('Tips for best results',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryGold,
                      )),
            ],
          ),
          const SizedBox(height: 12),
          for (final tip in [
            '📸 Good lighting (natural light works best)',
            '👤 Face clearly visible for face shape analysis',
            '👗 Wear your outfit clearly for style analysis',
            '📐 Stand straight for body type detection',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(tip,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                      )),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryGold, size: 22),
            const SizedBox(width: 10),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderGlass,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Choose Photo Source',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryGold),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryGold),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
