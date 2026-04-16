/// 时间扩展。
extension DateTimeExt on DateTime {
  /// 格式化为 yyyy-MM-dd。
  String get ymd {
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
