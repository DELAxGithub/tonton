import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/providers.dart';
import '../../../routes/router.dart';

/// Step 2: Screen showing analysis progress.
class AIMealLoggingStep2Analyzing extends ConsumerStatefulWidget {
  final File imageFile;
  const AIMealLoggingStep2Analyzing({super.key, required this.imageFile});

  @override
  ConsumerState<AIMealLoggingStep2Analyzing> createState() => _State();
}

class _State extends ConsumerState<AIMealLoggingStep2Analyzing> {
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final result = await ref
            .read(aiEstimationProvider.notifier)
            .estimateNutritionFromImageFile(widget.imageFile)
            .timeout(const Duration(seconds: 30));
        if (result != null && mounted) {
          context.go(
            TontonRoutes.aiMealConfirm,
            extra: {'image': widget.imageFile.path, 'nutrition': result},
          );
        } else if (mounted) {
          setState(() => _error = '解析結果が空でした');
        }
      } on TimeoutException {
        if (mounted) {
          setState(() => _error = 'タイムアウトしました（30秒）');
        }
      } catch (e) {
        if (mounted) {
          final message = e.toString();
          if (message.contains('API key')) {
            setState(() => _error = 'APIキーが設定されていません\n.envにGEMINI_API_KEYを追加してください');
          } else if (message.contains('SocketException') || message.contains('ClientException')) {
            setState(() => _error = 'ネットワークエラー\nインターネット接続を確認してください');
          } else {
            setState(() => _error = '解析に失敗しました\n$message');
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final estimation = ref.watch(aiEstimationProvider);

    Widget content;
    if (_error != null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(TontonRoutes.aiMealCamera),
              child: const Text('やり直す'),
            ),
          ],
        ),
      );
    } else {
      content = estimation.when(
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
        error:
            (e, st) => Column(
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
      );
    }

    return Scaffold(body: Center(child: content));
  }
}
