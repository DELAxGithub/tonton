import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/models/user_goals.dart';

void main() {
  group('UserGoals startingBodyWeight serialization', () {
    test('roundtrips startingBodyWeightKg and startingBodyWeightDate', () {
      final date = DateTime.utc(2026, 5, 1);
      final goals = const UserGoals().copyWith(
        startingBodyWeightKg: 72.5,
        startingBodyWeightDate: DateTime.utc(2026, 5, 1),
      );

      final json = goals.toJson();
      expect(json['startingBodyWeightKg'], 72.5);
      expect(json['startingBodyWeightDate'], date.toIso8601String());

      final restored = UserGoals.fromJson(json);
      expect(restored.startingBodyWeightKg, 72.5);
      expect(restored.startingBodyWeightDate, date);
    });

    test('omitting starting weight stays null after roundtrip', () {
      final goals = const UserGoals();
      final restored = UserGoals.fromJson(goals.toJson());
      expect(restored.startingBodyWeightKg, isNull);
      expect(restored.startingBodyWeightDate, isNull);
    });
  });
}
