import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/base_module_config.dart';

/// 标题模块配置
class TitleConfig extends BaseModuleConfig {
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

  const TitleConfig({
    this.color = 'red',
    this.fontSize,
    this.fontWeight = pw.FontWeight.normal,
    this.alignment = pw.Alignment.center,
    this.font,
    this.topSpacing = 0.0,
    this.bottomSpacing = 15.0,
    this.titleSpacing = 5.0,
    super.enabled = true,
    super.priority = 20,
    super.required = false,
  });

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

  /// 创建副本
  ///
  /// ### 参数
  /// - [color] 标题颜色（字符串形式）
  /// - [fontSize] 字体大小
  /// - [fontWeight] 字体权重
  /// - [alignment] 对齐方式
  /// - [font] 字体
  /// - [topSpacing] 顶部间距
  /// - [bottomSpacing] 底部间距
  /// - [titleSpacing] 标题间距
  /// - [enabled] 是否启用该模块
  /// - [priority] 模块优先级
  /// - [required] 是否必需
  /// ### 返回值
  /// 返回新的 TitleConfig 实例
  @override
  TitleConfig copyWith({
    String? color,
    double? fontSize,
    pw.FontWeight? fontWeight,
    pw.Alignment? alignment,
    pw.Font? font,
    double? topSpacing,
    double? bottomSpacing,
    double? titleSpacing,
    bool? enabled,
    int? priority,
    bool? required,
  }) {
    return TitleConfig(
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      alignment: alignment ?? this.alignment,
      font: font ?? this.font,
      topSpacing: topSpacing ?? this.topSpacing,
      bottomSpacing: bottomSpacing ?? this.bottomSpacing,
      titleSpacing: titleSpacing ?? this.titleSpacing,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      required: required ?? this.required,
    );
  }
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
