import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/router.dart';
import '../../../utils/icon_mapper.dart';

class GraphsScreen extends StatelessWidget {
  const GraphsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('グラフ')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.push(TontonRoutes.savingsTrend),
              icon: Icon(TontonIcons.trend),
              label: const Text('貯金ダイアリー'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push(TontonRoutes.progressAchievements),
              icon: Icon(TontonIcons.weight),
              label: const Text('体重ジャーニー'),
            ),
          ],
        ),
      ),
    );
  }
}
