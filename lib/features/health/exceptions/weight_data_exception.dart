/// Exception for weight data related errors
class WeightDataException implements Exception {
  final String message;
  final WeightDataErrorType type;
  
  WeightDataException({required this.message, required this.type});
  
  factory WeightDataException.permissionDenied() {
    return WeightDataException(
      message: 'HealthKitの権限が必要です',
      type: WeightDataErrorType.permissionDenied,
    );
  }
  
  factory WeightDataException.dataUnavailable() {
    return WeightDataException(
      message: '体重データがありません',
      type: WeightDataErrorType.dataUnavailable,
    );
  }
  
  factory WeightDataException.unknown(dynamic error) {
    return WeightDataException(
      message: 'データ取得に失敗しました: $error',
      type: WeightDataErrorType.unknown,
    );
  }
  
  @override
  String toString() => message;
}

enum WeightDataErrorType {
  permissionDenied,
  dataUnavailable,
  unknown,
}