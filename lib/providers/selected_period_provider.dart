enum SelectedPeriod {
  week,
  month,
  quarter,
  all,
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPeriodProvider =
    StateProvider<SelectedPeriod>((ref) => SelectedPeriod.week);

