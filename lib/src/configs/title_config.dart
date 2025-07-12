import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/module_config.dart';

/// 标题模块配置
class TitleConfig {
  /// 标题颜色（字符串形式）
  final String color;

  /// 字体大小
  final double? fontSize;

  /// 字体权重
  final pw.FontWeight fontWeight;

  /// 对齐方式
  final pw.Alignment alignment;

  /// 字体
  final pw.Font? font;

  /// 顶部间距
  final double topSpacing;

  /// 底部间距
  final double bottomSpacing;

  /// 标题间距
  final double titleSpacing;

  /// 模块配置
  final ModuleConfig moduleConfig;

  TitleConfig({
    this.color = 'red',
    this.fontSize,
    this.fontWeight = pw.FontWeight.normal,
    this.alignment = pw.Alignment.center,
    this.font,
    this.topSpacing = 0.0,
    this.bottomSpacing = 15.0,
    this.titleSpacing = 5.0,
    ModuleConfig? moduleConfig,
  }) : moduleConfig = moduleConfig ?? ModuleConfig(priority: 20);

  /// 创建默认配置
  static TitleConfig defaultConfig() => TitleConfig();

  /// 创建左对齐配置
  static TitleConfig leftConfig() =>
      TitleConfig(alignment: pw.Alignment.centerLeft);

  /// 创建右对齐配置
  static TitleConfig rightConfig() =>
      TitleConfig(alignment: pw.Alignment.centerRight);

  /// 创建大标题配置
  static TitleConfig largeConfig() =>
      TitleConfig(fontSize: 20.0, fontWeight: pw.FontWeight.bold);
}

/// 标题样式
class TitleStyle {
  /// 标题颜色
  final String? color;

  /// 字体大小
  final double? fontSize;

  /// 字体权重
  final pw.FontWeight? fontWeight;

  /// 对齐方式
  final pw.Alignment? alignment;

  /// 字体
  final pw.Font? font;

  TitleStyle({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.alignment,
    this.font,
  });

  /// 创建默认样式
  static TitleStyle defaultStyle() => TitleStyle();

  /// 创建粗体样式
  static TitleStyle boldStyle() => TitleStyle(fontWeight: pw.FontWeight.bold);

  /// 创建大字体样式
  static TitleStyle largeStyle() =>
      TitleStyle(fontSize: 18.0, fontWeight: pw.FontWeight.bold);
}
