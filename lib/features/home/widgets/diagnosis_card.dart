import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/diagnosis_logic.dart';
import '../../../core/providers/diagnosis_provider.dart';
import '../../../design_system/atoms/tonton_card_base.dart';
import '../../../routes/router.dart';
import '../../../theme/app_theme.dart' as app_theme;
import '../../../theme/colors.dart';

/// Home-screen card that surfaces the top diagnosis for the user's
/// current state (e.g. "目標が小さすぎます", "記録と実態がずれている可能性").
class DiagnosisCard extends ConsumerWidget {
  const DiagnosisCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(diagnosisProvider);
    if (result == null) return const SizedBox.shrink();
    if (result.kind == DiagnosisKind.unknown) return const SizedBox.shrink();

    final palette = _paletteFor(result.kind);

    return TontonCardBase(
      backgroundColor: palette.background,
      borderColor: palette.border,
      borderWidth: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(palette.icon, color: palette.accent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.headline,
                  style: TextStyle(
                    color: app_theme.TontonColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...result.body.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: TextStyle(
                  color: app_theme.TontonColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (_showCta(result.kind)) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(TontonRoutes.profile),
                style: TextButton.styleFrom(
                  foregroundColor: palette.accent,
                ),
                child: Text(_ctaLabelFor(result.kind)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _showCta(DiagnosisKind kind) {
    return kind == DiagnosisKind.goalTooSmall ||
        kind == DiagnosisKind.trackingMismatch;
  }

  String _ctaLabelFor(DiagnosisKind kind) {
    switch (kind) {
      case DiagnosisKind.goalTooSmall:
        return '目標ペースを見直す →';
      case DiagnosisKind.trackingMismatch:
        return '設定を確認する →';
      default:
        return '設定 →';
    }
  }

  _Palette _paletteFor(DiagnosisKind kind) {
    switch (kind) {
      case DiagnosisKind.goalTooSmall:
        return _Palette(
          icon: Icons.tune_rounded,
          accent: TontonColors.pigPink,
          background: const Color(0xFFFFF4F5),
          border: const Color(0xFFFBC6CC),
        );
      case DiagnosisKind.trackingMismatch:
        return _Palette(
          icon: Icons.troubleshoot_rounded,
          accent: const Color(0xFFB8651B),
          background: const Color(0xFFFFF7E8),
          border: const Color(0xFFF4D3A1),
        );
      case DiagnosisKind.tooShort:
        return _Palette(
          icon: Icons.hourglass_bottom_rounded,
          accent: const Color(0xFF3D6BB0),
          background: const Color(0xFFEEF4FC),
          border: const Color(0xFFBFD4EE),
        );
      case DiagnosisKind.bodyComp:
        return _Palette(
          icon: Icons.fitness_center_rounded,
          accent: const Color(0xFF1F7A5A),
          background: const Color(0xFFE8F5EE),
          border: const Color(0xFFB0DDC3),
        );
      case DiagnosisKind.onTrack:
        return _Palette(
          icon: Icons.check_circle_rounded,
          accent: const Color(0xFF1F7A5A),
          background: const Color(0xFFE8F5EE),
          border: const Color(0xFFB0DDC3),
        );
      case DiagnosisKind.unknown:
        return _Palette(
          icon: Icons.help_outline_rounded,
          accent: app_theme.TontonColors.textSecondary,
          background: Colors.white,
          border: const Color(0xFFEAEAEA),
        );
    }
  }
}

class _Palette {
  final IconData icon;
  final Color accent;
  final Color background;
  final Color border;
  _Palette({
    required this.icon,
    required this.accent,
    required this.background,
    required this.border,
  });
}
