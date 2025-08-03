/// Mock 签名哈希提供者，用于测试
class MockSignatureHashProvider {
  final String _mockHash;
  final bool _shouldFail;
  final Duration _delay;
  
  /// 创建 Mock 签名哈希提供者
  /// 
  /// [mockHash] 模拟返回的哈希值，默认为 'mock_signature_hash'
  /// [shouldFail] 是否应该失败，默认为 false
  /// [delay] 模拟延迟，默认为 100ms
  const MockSignatureHashProvider({
    String? mockHash,
    bool? shouldFail,
    Duration? delay,
  }) : _mockHash = mockHash ?? 'mock_signature_hash',
       _shouldFail = shouldFail ?? false,
       _delay = delay ?? const Duration(milliseconds: 100);
  
  /// 获取签名哈希的 Future 函数
  Future<String> Function() get provider => () async {
    await Future.delayed(_delay);
    
    if (_shouldFail) {
      throw Exception('Mock signature provider failed');
    }
    
    return _mockHash;
  };
  
  /// 创建成功的签名提供者
  static MockSignatureHashProvider success([String? hash]) {
    return MockSignatureHashProvider(mockHash: hash);
  }
  
  /// 创建失败的签名提供者
  static MockSignatureHashProvider failure() {
    return const MockSignatureHashProvider(shouldFail: true);
  }
  
  /// 创建带延迟的签名提供者
  static MockSignatureHashProvider withDelay(Duration delay, [String? hash]) {
    return MockSignatureHashProvider(mockHash: hash, delay: delay);
  }
}
