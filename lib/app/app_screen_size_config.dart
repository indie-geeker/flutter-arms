import 'dart:ui';

import 'package:screen_size_adapter/screen_size_adapter.dart';

/// 全局屏幕适配配置。
///
/// 派生项目应按设计稿修改 [ScreenSizeAdapterConfig.designSize]；桌面端默认
/// 保持 Flutter 原生逻辑像素，避免窗口放大时界面整体被等比放大。
const appScreenSizeAdapterConfig = ScreenSizeAdapterConfig(
  designSize: Size(360, 690),
  scaleAxis: ScaleAxis.width,
  enableDesktopScaling: false,
);
