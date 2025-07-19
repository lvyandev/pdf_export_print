import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/base_module_config.dart';
import 'package:pdf_export_print/src/constants/constants.dart';

/// Logo模块配置
class LogoConfig extends BaseModuleConfig {
  /// 默认宽度
  final double defaultWidth;

  /// 默认高度
  final double defaultHeight;

  /// 对齐方式
  final pw.Alignment alignment;

  /// 底部间距
  final double bottomSpacing;

  const LogoConfig({
    this.defaultWidth = LogoConstants.smallWidth,
    this.defaultHeight = LogoConstants.smallHeight,
    this.alignment = pw.Alignment.topLeft,
    this.bottomSpacing = LogoConstants.defaultBottomSpacing,
    super.enabled = true,
    super.priority = 10,
    super.required = false,
  });

  /// 创建默认配置
  static LogoConfig defaultConfig() => LogoConfig();

  /// 创建居中配置
  static LogoConfig centerConfig() =>
      LogoConfig(alignment: pw.Alignment.topCenter);

  /// 创建右对齐配置
  static LogoConfig rightConfig() =>
      LogoConfig(alignment: pw.Alignment.topRight);

  /// 创建副本
  ///
  /// ### 参数
  /// - [defaultWidth] 默认宽度
  /// - [defaultHeight] 默认高度
  /// - [alignment] 对齐方式
  /// - [bottomSpacing] 底部间距
  /// - [enabled] 是否启用该模块
  /// - [priority] 模块优先级
  /// - [required] 是否必需
  /// ### 返回值
  /// 返回新的 LogoConfig 实例
  @override
  LogoConfig copyWith({
    double? defaultWidth,
    double? defaultHeight,
    pw.Alignment? alignment,
    double? bottomSpacing,
    bool? enabled,
    int? priority,
    bool? required,
  }) {
    return LogoConfig(
      defaultWidth: defaultWidth ?? this.defaultWidth,
      defaultHeight: defaultHeight ?? this.defaultHeight,
      alignment: alignment ?? this.alignment,
      bottomSpacing: bottomSpacing ?? this.bottomSpacing,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      required: required ?? this.required,
    );
  }
}
