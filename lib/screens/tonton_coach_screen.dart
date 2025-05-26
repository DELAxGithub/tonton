import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TontonCoachScreen extends StatelessWidget {
  const TontonCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('トントンコーチ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('この機能は現在開発中です。'),
      ),
    );
  }
}
