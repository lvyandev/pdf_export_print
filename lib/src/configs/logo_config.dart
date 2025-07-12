import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/module_config.dart';
import 'package:pdf_export_print/src/constants/constants.dart';

/// Logo模块配置
class LogoConfig {
  /// 默认宽度
  final double defaultWidth;

  /// 默认高度
  final double defaultHeight;

  /// 对齐方式
  final pw.Alignment alignment;

  /// 底部间距
  final double bottomSpacing;

  /// 模块配置
  final ModuleConfig moduleConfig;

  /// 是否启用缓存
  final bool enableCache;

  /// 请求超时时间（秒）
  final int timeoutSeconds;

  /// 请求头
  final Map<String, String> requestHeaders;

  LogoConfig({
    this.defaultWidth = LogoConstants.smallWidth,
    this.defaultHeight = LogoConstants.smallHeight,
    this.alignment = pw.Alignment.topLeft,
    this.bottomSpacing = LogoConstants.defaultBottomSpacing,
    ModuleConfig? moduleConfig,
    this.enableCache = true,
    this.timeoutSeconds = LogoConstants.defaultTimeoutSeconds,
    this.requestHeaders = const {},
  }) : moduleConfig = moduleConfig ?? ModuleConfig(priority: 10);

  /// 创建默认配置
  static LogoConfig defaultConfig() => LogoConfig();

  /// 创建居中配置
  static LogoConfig centerConfig() =>
      LogoConfig(alignment: pw.Alignment.topCenter);

  /// 创建右对齐配置
  static LogoConfig rightConfig() =>
      LogoConfig(alignment: pw.Alignment.topRight);
}
