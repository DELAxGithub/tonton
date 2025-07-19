class UserProfile {
  final String? displayName;
  final double? weight;
  final String? gender; // 'male' or 'female' - DEPRECATED
  final String? ageGroup; // 'young', 'middle', 'senior' - DEPRECATED
  final String? dietGoal; // 'weight_loss', 'muscle_gain', 'maintain'
  final double? targetWeight;
  final int? targetDays;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.displayName,
    this.weight,
    this.gender,
    this.ageGroup,
    this.dietGoal,
    this.targetWeight,
    this.targetDays,
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? displayName,
    double? weight,
    String? gender,
    String? ageGroup,
    String? dietGoal,
    double? targetWeight,
    int? targetDays,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      dietGoal: dietGoal ?? this.dietGoal,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDays: targetDays ?? this.targetDays,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'weight': weight,
      'gender': gender,
      'ageGroup': ageGroup,
      'dietGoal': dietGoal,
      'targetWeight': targetWeight,
      'targetDays': targetDays,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['displayName'] as String?,
      weight: json['weight'] as double?,
      gender: json['gender'] as String?,
      ageGroup: json['ageGroup'] as String?,
      dietGoal: json['dietGoal'] as String?,
      targetWeight: json['targetWeight'] as double?,
      targetDays: json['targetDays'] as int?,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }
}
