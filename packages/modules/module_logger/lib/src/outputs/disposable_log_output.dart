/// 可释放的日志输出接口
abstract interface class DisposableLogOutput {
  Future<void> dispose();
}
