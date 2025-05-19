class WeightRecord {
  final double weight;
  final double? bodyFatPercentage;
  final DateTime date;

  WeightRecord({
    required this.weight, 
    required this.date,
    this.bodyFatPercentage,
  });
  
  bool get hasBodyFat => bodyFatPercentage != null;
  
  String get formattedWeight => '${weight.toStringAsFixed(1)} kg';
  
  String get formattedBodyFat => 
      bodyFatPercentage != null ? '${(bodyFatPercentage! * 100).toStringAsFixed(1)} %' : 'データなし';
      
  @override
  String toString() {
    return 'WeightRecord(weight: $weight, date: $date, bodyFatPercentage: $bodyFatPercentage)';
  }
}