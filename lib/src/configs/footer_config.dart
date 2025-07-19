import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf_export_print/src/configs/base_module_config.dart';

/// 页脚模块配置
class FooterConfig extends BaseModuleConfig {
  /// 是否显示边框（只有外框）
  final bool showBorder;

  /// 是否显示内边框
  final bool showInnerBorder;

  /// 边框颜色
  final PdfColor? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 单元格内边距
  final pw.EdgeInsets cellPadding;

  /// 每行显示的字段数
  final int fieldsPerRow;

  /// 标题字体大小
  final double? labelFontSize;

  /// 内容字体大小
  final double? contentFontSize;

  /// 标题颜色
  final PdfColor? labelColor;

  /// 内容颜色
  final PdfColor? contentColor;

  /// 顶部间距
  final double topSpacing;

  /// 底部间距
  final double bottomSpacing;

  const FooterConfig({
    this.showBorder = true,
    this.showInnerBorder = false,
    this.borderColor,
    this.borderWidth,
    this.cellPadding = const pw.EdgeInsets.all(4),
    this.fieldsPerRow = 3,
    this.labelFontSize,
    this.contentFontSize,
    this.labelColor,
    this.contentColor,
    this.topSpacing = 0.0,
    this.bottomSpacing = 0.0,
    super.enabled = true,
    super.priority = 90,
    super.required = false,
  });

  /// 创建默认配置
  static FooterConfig defaultConfig() => FooterConfig();

  /// 创建无边框配置
  static FooterConfig noBorderConfig() =>
      FooterConfig(showBorder: false, showInnerBorder: false);

  /// 创建紧凑配置
  static FooterConfig compactConfig() =>
      FooterConfig(cellPadding: const pw.EdgeInsets.all(2), topSpacing: 10.0);

  /// 创建副本
  ///
  /// ### 参数
  /// - [showBorder] 是否显示边框（只有外框）
  /// - [showInnerBorder] 是否显示内边框
  /// - [borderColor] 边框颜色
  /// - [borderWidth] 边框宽度
  /// - [cellPadding] 单元格内边距
  /// - [fieldsPerRow] 每行显示的字段数
  /// - [labelFontSize] 标题字体大小
  /// - [contentFontSize] 内容字体大小
  /// - [labelColor] 标题颜色
  /// - [contentColor] 内容颜色
  /// - [topSpacing] 顶部间距
  /// - [bottomSpacing] 底部间距
  /// - [enabled] 是否启用该模块
  /// - [priority] 模块优先级
  /// - [required] 是否必需
  /// ### 返回值
  /// 返回新的 FooterConfig 实例
  @override
  FooterConfig copyWith({
    bool? showBorder,
    bool? showInnerBorder,
    PdfColor? borderColor,
    double? borderWidth,
    pw.EdgeInsets? cellPadding,
    int? fieldsPerRow,
    double? labelFontSize,
    double? contentFontSize,
    PdfColor? labelColor,
    PdfColor? contentColor,
    double? topSpacing,
    double? bottomSpacing,
    bool? enabled,
    int? priority,
    bool? required,
  }) {
    return FooterConfig(
      showBorder: showBorder ?? this.showBorder,
      showInnerBorder: showInnerBorder ?? this.showInnerBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cellPadding: cellPadding ?? this.cellPadding,
      fieldsPerRow: fieldsPerRow ?? this.fieldsPerRow,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      contentFontSize: contentFontSize ?? this.contentFontSize,
      labelColor: labelColor ?? this.labelColor,
      contentColor: contentColor ?? this.contentColor,
      topSpacing: topSpacing ?? this.topSpacing,
      bottomSpacing: bottomSpacing ?? this.bottomSpacing,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      required: required ?? this.required,
    );
  }
}
