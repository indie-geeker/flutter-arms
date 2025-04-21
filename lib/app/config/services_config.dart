/// 第三方服务配置类
class ServicesConfig {
  // 音乐服务 API
  final String musicApiKey;
  
  // 社交登录
  final String? googleClientId;
  final String? facebookAppId;
  
  // 分析服务
  final String? firebaseProjectId;
  final bool enableAnalytics;
  
  // 支付服务
  final String? stripePublishableKey;
  final String? alipayPartnerId;
  
  ServicesConfig({
    required this.musicApiKey,
    this.googleClientId,
    this.facebookAppId,
    this.firebaseProjectId,
    this.enableAnalytics = true,
    this.stripePublishableKey,
    this.alipayPartnerId,
  });
}
