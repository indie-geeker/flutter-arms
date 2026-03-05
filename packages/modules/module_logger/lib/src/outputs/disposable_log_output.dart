/// Disposable log output interface.
abstract interface class DisposableLogOutput {
  Future<void> dispose();
}
