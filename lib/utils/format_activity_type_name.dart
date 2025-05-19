String formatActivityTypeName(String enumName) {
  if (enumName.isEmpty) return "不明";
  return enumName.split('_').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
} 