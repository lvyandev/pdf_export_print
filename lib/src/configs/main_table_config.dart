import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf_export_print/src/configs/base_module_config.dart';

/// 主表模块配置
class MainTableConfig extends BaseModuleConfig {
  /// 是否显示边框
  final bool showBorder;

  /// 是否显示内边框
  final bool showInnerBorder;

  /// 边框颜色
  final PdfColor? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 单元格内边距
  final pw.EdgeInsets cellPadding;

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

  /// 每行字段数
  final int fieldsPerRow;

  const MainTableConfig({
    this.showBorder = true,
    this.showInnerBorder = true,
    this.borderColor,
    this.borderWidth,
    this.cellPadding = const pw.EdgeInsets.all(4),
    this.labelFontSize,
    this.contentFontSize,
    this.labelColor,
    this.contentColor,
    this.topSpacing = 0.0,
    this.bottomSpacing = 0.0,
    this.fieldsPerRow = 3,
    super.enabled = true,
    super.priority = 30,
    super.required = false,
  });

  /// 创建默认配置
  static MainTableConfig defaultConfig() => MainTableConfig();

  /// 创建无边框配置
  static MainTableConfig noBorderConfig() =>
      MainTableConfig(showBorder: false, showInnerBorder: false);

  /// 创建紧凑配置
  static MainTableConfig compactConfig() => MainTableConfig(
    cellPadding: const pw.EdgeInsets.all(2),
    topSpacing: 0.0,
    bottomSpacing: 10.0,
  );

  /// 创建副本
  ///
  /// ### 参数
  /// - [showBorder] 是否显示边框
  /// - [showInnerBorder] 是否显示内边框
  /// - [borderColor] 边框颜色
  /// - [borderWidth] 边框宽度
  /// - [cellPadding] 单元格内边距
  /// - [labelFontSize] 标题字体大小
  /// - [contentFontSize] 内容字体大小
  /// - [labelColor] 标题颜色
  /// - [contentColor] 内容颜色
  /// - [topSpacing] 顶部间距
  /// - [bottomSpacing] 底部间距
  /// - [fieldsPerRow] 每行字段数
  /// - [enabled] 是否启用该模块
  /// - [priority] 模块优先级
  /// - [required] 是否必需
  /// ### 返回值
  /// 返回新的 MainTableConfig 实例
  @override
  MainTableConfig copyWith({
    bool? showBorder,
    bool? showInnerBorder,
    PdfColor? borderColor,
    double? borderWidth,
    pw.EdgeInsets? cellPadding,
    double? labelFontSize,
    double? contentFontSize,
    PdfColor? labelColor,
    PdfColor? contentColor,
    double? topSpacing,
    double? bottomSpacing,
    int? fieldsPerRow,
    bool? enabled,
    int? priority,
    bool? required,
  }) {
    return MainTableConfig(
      showBorder: showBorder ?? this.showBorder,
      showInnerBorder: showInnerBorder ?? this.showInnerBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cellPadding: cellPadding ?? this.cellPadding,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      contentFontSize: contentFontSize ?? this.contentFontSize,
      labelColor: labelColor ?? this.labelColor,
      contentColor: contentColor ?? this.contentColor,
      topSpacing: topSpacing ?? this.topSpacing,
      bottomSpacing: bottomSpacing ?? this.bottomSpacing,
      fieldsPerRow: fieldsPerRow ?? this.fieldsPerRow,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      required: required ?? this.required,
    );
  }
}
