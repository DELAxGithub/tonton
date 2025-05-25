import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ai_estimation_provider.dart';
import '../../routes/router.dart';
import '../../models/estimated_meal_nutrition.dart';

/// Step 2: Screen showing analysis progress.
class AIMealLoggingStep2Analyzing extends ConsumerStatefulWidget {
  final File imageFile;
  const AIMealLoggingStep2Analyzing({super.key, required this.imageFile});

  @override
  ConsumerState<AIMealLoggingStep2Analyzing> createState() => _State();
}

class _State extends ConsumerState<AIMealLoggingStep2Analyzing> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(aiEstimationProvider.notifier)
          .estimateNutritionFromImageFile(widget.imageFile);
    });
    ref.listen<AsyncValue<EstimatedMealNutrition?>>(aiEstimationProvider,
        (previous, next) {
      next.whenData((value) {
        if (value != null && mounted) {
          context.go(TontonRoutes.aiMealConfirm, extra: {
            'image': widget.imageFile.path,
            'nutrition': value,
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final estimation = ref.watch(aiEstimationProvider);

    return Scaffold(
      body: Center(
        child: estimation.when(
          data: (_) => const Text('処理結果を取得中...'),
          loading: () {
            _progress += 0.02;
            if (_progress > 1) _progress = 1;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('おいしさを解析中...'),
                const SizedBox(height: 16),
                CircularProgressIndicator(value: _progress),
              ],
            );
          },
          error: (e, st) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('解析に失敗しました'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(TontonRoutes.aiMealCamera),
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
