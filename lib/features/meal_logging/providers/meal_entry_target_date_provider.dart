import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 食事入力フロー (aiMealCamera → aiMealAnalyzing → aiMealConfirm / textMealInput) が
/// どの日の記録を作ろうとしているかを保持する。
///
/// - null: 通常フロー（今日の日付で記録する）
/// - 日付: 日別履歴などから日付付きで入ったフロー（その日をデフォルトにする）
///
/// 入口 (FAB など) で明示的にセットし、確認画面の initState で読み出してクリアする。
final mealEntryTargetDateProvider = StateProvider<DateTime?>((ref) => null);
