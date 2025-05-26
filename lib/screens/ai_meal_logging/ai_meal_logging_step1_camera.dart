import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../routes/router.dart';

/// Step 1: Screen for capturing or selecting a meal photo.
class AIMealLoggingStep1Camera extends ConsumerWidget {
  const AIMealLoggingStep1Camera({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 100,
    );
    if (file != null && context.mounted) {
      context.go(TontonRoutes.aiMealAnalyzing, extra: file.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // Placeholder for camera preview
          Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const Text(
              'Camera preview not available',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.go(TontonRoutes.home),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 32,
            child: IconButton(
              icon: const Icon(Icons.photo_library, color: Colors.white),
              iconSize: 32,
              onPressed: () => _pickImage(context, ImageSource.gallery),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            left: 16,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.circle, color: Colors.white, size: 72),
                onPressed: () => _pickImage(context, ImageSource.camera),
              ),
            ),
          ),
          const Positioned(
            bottom: 96,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'お皿全体が写るように撮影してね！',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
