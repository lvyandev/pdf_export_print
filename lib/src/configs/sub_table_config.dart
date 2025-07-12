import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf_export_print/src/configs/module_config.dart';

/// 子表模块配置
class SubTableConfig {
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

  /// 表头高度
  final double headerHeight;

  /// 数据行高度
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

  /// 为其他内容预留的高度
  final double reservedHeight;

  /// 默认列宽配置（可选）
  final List<double>? defaultColumnWidths;

  /// 模块配置
  final ModuleConfig moduleConfig;

  SubTableConfig({
    this.showBorder = true,
    this.borderColor,
    this.borderWidth,
    this.cellPadding = const pw.EdgeInsets.all(4),
    this.headerHeight = 25.0,
    this.rowHeight,
    this.headerFontSize,
    this.dataFontSize,
    this.headerColor,
    this.dataColor,
    this.headerBackgroundColor,
    this.headerAlignment = pw.Alignment.center,
    this.dataAlignment = pw.Alignment.centerLeft,
    this.showTitle = true,
    this.titleAlignment = pw.Alignment.centerLeft,
    this.titleFontSize,
    this.titleColor,
    this.titlePadding = 5.0,
    this.topSpacing = 0.0,
    this.bottomSpacing = 0.0,
    this.reservedHeight = 100.0,
    this.defaultColumnWidths,
    ModuleConfig? moduleConfig,
  }) : moduleConfig = moduleConfig ?? ModuleConfig(priority: 40);

  /// 创建默认配置
  static SubTableConfig defaultConfig() => SubTableConfig();

  /// 创建无边框配置
  static SubTableConfig noBorderConfig() => SubTableConfig(showBorder: false);

  /// 创建紧凑配置
  static SubTableConfig compactConfig() => SubTableConfig(
    cellPadding: const pw.EdgeInsets.all(2),
    headerHeight: 20.0,
    rowHeight: 18.0,
    reservedHeight: 80.0,
  );

  /// 创建大表格配置
  static SubTableConfig largeConfig() => SubTableConfig(
    headerHeight: 30.0,
    rowHeight: 25.0,
    reservedHeight: 120.0,
  );
}
