class UserProfile {
  final String? displayName;
  final double? weight;
  final String? gender; // 'male' or 'female'
  final String? ageGroup; // 'young', 'middle', 'senior'
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.displayName,
    this.weight,
    this.gender,
    this.ageGroup,
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? displayName,
    double? weight,
    String? gender,
    String? ageGroup,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
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
