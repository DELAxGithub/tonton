import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SelectedPeriod { week, month, quarter, all }

final selectedPeriodProvider = StateProvider<SelectedPeriod>(
  (ref) => SelectedPeriod.week,
);
