import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../design_system/atoms/tonton_button.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../providers/providers.dart';
import '../../../utils/icon_mapper.dart';
import '../models/reward_suggestion.dart';
import '../services/reward_suggestion_service.dart';

class UseSavingsScreen extends ConsumerStatefulWidget {
  const UseSavingsScreen({super.key});

  @override
  ConsumerState<UseSavingsScreen> createState() => _UseSavingsScreenState();
}

class _UseSavingsScreenState extends ConsumerState<UseSavingsScreen> {
  DateTime _selectedDate = DateTime.now();
  double _amountToUse = 0;

  bool _suggestionsLoading = false;
  String? _suggestionsError;
  List<RewardSuggestion> _suggestions = const [];
  RewardSuggestion? _pickedSuggestion;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _confirm() async {
    await ref
        .read(savingsBalanceProvider.notifier)
        .deduct(_amountToUse.roundToDouble());
    if (!mounted) return;
    final pickedName = _pickedSuggestion?.name;
    final msg = pickedName != null
        ? '${_amountToUse.round()} kcal を使いました ($pickedName)'
        : '${_amountToUse.round()} kcal を使いました';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    context.pop();
  }

  Future<void> _fetchSuggestions() async {
    setState(() {
      _suggestionsLoading = true;
      _suggestionsError = null;
      _suggestions = const [];
      _pickedSuggestion = null;
    });
    try {
      final budget = _amountToUse.round();
      final budgetKcal = budget > 0 ? budget : 500; // フォールバック
      final result = await RewardSuggestionService.suggest(
        budgetKcal: budgetKcal,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = result;
        _suggestionsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _suggestionsError = 'AI 提案の取得に失敗しました: $e';
        _suggestionsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ご褒美設定')),
      body: StandardPageLayout(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final balance = ref.watch(savingsBalanceProvider).round();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '使える貯金',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$balance kcal',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(TontonIcons.calendar),
            title: const Text('いつのご褒美にする？'),
            subtitle: Text(DateFormat.yMd().format(_selectedDate)),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          Text('いくら使う？ (${_amountToUse.round()} kcal)'),
          Slider(
            value: _amountToUse,
            onChanged: (v) => setState(() => _amountToUse = v),
            min: 0,
            max: 1000,
            divisions: 20,
          ),
          const SizedBox(height: 16),

          // ----- AI suggestions section -----
          _buildSuggestionsSection(context),

          const SizedBox(height: 24),
          TontonButton.primary(
            label: 'この内容でご褒美を設定！',
            icon: TontonIcons.present,
            onPressed: _amountToUse > 0 ? _confirm : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    final lavenderBorder = const Color(0xFFDCC9F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5EDFF), Color(0xFFFFF0F5)],
        ),
        border: Border.all(color: lavenderBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB08AFF), Color(0xFF7EAAFF)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ご褒美フードの候補',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              if (_suggestionsLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed:
                      _amountToUse > 0 ? _fetchSuggestions : null,
                  icon: const Icon(Icons.refresh, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (_suggestions.isEmpty &&
              !_suggestionsLoading &&
              _suggestionsError == null) ...[
            Text(
              '使う kcal を決めて「↻」で AI 候補を取得します。',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _amountToUse > 0 ? _fetchSuggestions : null,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('AI に提案してもらう'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB08AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],

          if (_suggestionsError != null) ...[
            const SizedBox(height: 4),
            Text(
              _suggestionsError!,
              style: TextStyle(fontSize: 11, color: Colors.red.shade700),
            ),
          ],

          for (final s in _suggestions) ...[
            const SizedBox(height: 8),
            _RewardSuggestionTile(
              suggestion: s,
              selected: identical(s, _pickedSuggestion),
              onTap: () {
                setState(() {
                  _pickedSuggestion = s;
                  _amountToUse = s.kcal.toDouble().clamp(0, 1000);
                });
              },
            ),
          ],

          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '※ 一般情報の提示です。医療判断は専門家にご相談ください。',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardSuggestionTile extends StatelessWidget {
  final RewardSuggestion suggestion;
  final bool selected;
  final VoidCallback onTap;

  const _RewardSuggestionTile({
    required this.suggestion,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF0EE)
              : Colors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF9AA2)
                : const Color(0xFFEFE6F2),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(suggestion.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          suggestion.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${suggestion.kcal} kcal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (suggestion.reason.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.reason,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
