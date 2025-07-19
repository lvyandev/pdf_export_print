import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf_export_print/src/configs/base_module_config.dart';

/// 子表模块配置
class SubTableConfig extends BaseModuleConfig {
  /// 审批记录默认列宽配置（百分比形式）
  /// 顺序：排序、节点名称、审批人、签名、审批时间、意见
  static const List<double> approvalDefaultColumnWidths = [
    0.10, // 排序 - 10%
    0.18, // 节点名称 - 18%
    0.18, // 审批人 - 18%
    0.18, // 签名 - 18%
    0.18, // 审批时间 - 18%
    0.18, // 意见 - 18%
  ]; // 总和：100%

  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final PdfColor? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 单元格内边距
  final pw.EdgeInsets cellPadding;

  /// 表头高度（null时自适应）
  final double? headerHeight;

  /// 数据行高度（null时自适应）
  final double? rowHeight;

  /// 表头字体大小
  final double? headerFontSize;

  /// 数据字体大小
  final double? dataFontSize;

  /// 表头颜色
  final PdfColor? headerColor;

  /// 数据颜色
  final PdfColor? dataColor;

  /// 表头背景颜色
  final PdfColor? headerBackgroundColor;

  /// 表头对齐方式
  final pw.Alignment headerAlignment;

  /// 数据对齐方式
  final pw.Alignment dataAlignment;

  /// 是否显示标题
  final bool showTitle;

  /// 标题对齐方式
  final pw.Alignment titleAlignment;

  /// 标题字体大小
  final double? titleFontSize;

  /// 标题颜色
  final PdfColor? titleColor;

  /// 标题内边距
  final double titlePadding;

  /// 顶部间距
  final double topSpacing;

  /// 底部间距
  final double bottomSpacing;

  /// 默认列宽配置（可选）
  final List<double>? defaultColumnWidths;

  /// 单元格垂直对齐方式
  final pw.TableCellVerticalAlignment cellVerticalAlignment;

  const SubTableConfig({
    this.showBorder = true,
    this.borderColor,
    this.borderWidth,
    this.cellPadding = const pw.EdgeInsets.all(4),
    this.headerHeight,
    this.rowHeight,
    this.headerFontSize,
    this.dataFontSize,
    this.headerColor,
    this.dataColor,
    this.headerBackgroundColor,
    this.headerAlignment = pw.Alignment.center,
    this.dataAlignment = pw.Alignment.centerLeft,
    this.showTitle = true,
    this.titleAlignment = pw.Alignment.center,
    this.titleFontSize,
    this.titleColor,
    this.titlePadding = 5.0,
    this.topSpacing = 0.0,
    this.bottomSpacing = 0.0,
    this.defaultColumnWidths,
    this.cellVerticalAlignment = pw.TableCellVerticalAlignment.middle,
    super.enabled = true,
    super.priority = 40,
    super.required = false,
  });

  /// 创建默认配置
  static SubTableConfig defaultConfig() => SubTableConfig();

  /// 创建无边框配置
  static SubTableConfig noBorderConfig() => SubTableConfig(showBorder: false);

  /// 创建紧凑配置
  static SubTableConfig compactConfig() => SubTableConfig(
    cellPadding: const pw.EdgeInsets.all(2),
    headerHeight: 20.0,
    rowHeight: 18.0,
  );

  /// 创建大表格配置
  static SubTableConfig largeConfig() =>
      SubTableConfig(headerHeight: 30.0, rowHeight: 25.0);

  /// 创建副本
  ///
  /// ### 参数
  /// - [showBorder] 是否显示边框
  /// - [borderColor] 边框颜色
  /// - [borderWidth] 边框宽度
  /// - [cellPadding] 单元格内边距
  /// - [headerHeight] 表头高度
  /// - [rowHeight] 数据行高度
  /// - [headerFontSize] 表头字体大小
  /// - [dataFontSize] 数据字体大小
  /// - [headerColor] 表头颜色
  /// - [dataColor] 数据颜色
  /// - [headerBackgroundColor] 表头背景颜色
  /// - [headerAlignment] 表头对齐方式
  /// - [dataAlignment] 数据对齐方式
  /// - [showTitle] 是否显示标题
  /// - [titleAlignment] 标题对齐方式
  /// - [titleFontSize] 标题字体大小
  /// - [titleColor] 标题颜色
  /// - [titlePadding] 标题内边距
  /// - [topSpacing] 顶部间距
  /// - [bottomSpacing] 底部间距
  /// - [defaultColumnWidths] 默认列宽配置
  /// - [cellVerticalAlignment] 单元格垂直对齐方式
  /// - [enabled] 是否启用该模块
  /// - [priority] 模块优先级
  /// - [required] 是否必需
  /// ### 返回值
  /// 返回新的 SubTableConfig 实例
  @override
  SubTableConfig copyWith({
    bool? showBorder,
    PdfColor? borderColor,
    double? borderWidth,
    pw.EdgeInsets? cellPadding,
    double? headerHeight,
    double? rowHeight,
    double? headerFontSize,
    double? dataFontSize,
    PdfColor? headerColor,
    PdfColor? dataColor,
    PdfColor? headerBackgroundColor,
    pw.Alignment? headerAlignment,
    pw.Alignment? dataAlignment,
    bool? showTitle,
    pw.Alignment? titleAlignment,
    double? titleFontSize,
    PdfColor? titleColor,
    double? titlePadding,
    double? topSpacing,
    double? bottomSpacing,
    List<double>? defaultColumnWidths,
    pw.TableCellVerticalAlignment? cellVerticalAlignment,
    bool? enabled,
    int? priority,
    bool? required,
  }) {
    return SubTableConfig(
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cellPadding: cellPadding ?? this.cellPadding,
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      headerFontSize: headerFontSize ?? this.headerFontSize,
      dataFontSize: dataFontSize ?? this.dataFontSize,
      headerColor: headerColor ?? this.headerColor,
      dataColor: dataColor ?? this.dataColor,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerAlignment: headerAlignment ?? this.headerAlignment,
      dataAlignment: dataAlignment ?? this.dataAlignment,
      showTitle: showTitle ?? this.showTitle,
      titleAlignment: titleAlignment ?? this.titleAlignment,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      titleColor: titleColor ?? this.titleColor,
      titlePadding: titlePadding ?? this.titlePadding,
      topSpacing: topSpacing ?? this.topSpacing,
      bottomSpacing: bottomSpacing ?? this.bottomSpacing,
      defaultColumnWidths: defaultColumnWidths ?? this.defaultColumnWidths,
      cellVerticalAlignment:
          cellVerticalAlignment ?? this.cellVerticalAlignment,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      required: required ?? this.required,
    );
  }
}
