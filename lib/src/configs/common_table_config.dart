import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;

/// 通用表格组件配置
class CommonTableConfig {
  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final pw.PdfColor? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 单元格内边距
  final pw.EdgeInsets cellPadding;

  /// 表头高度（null时自适应）
  final double? headerHeight;

  /// 数据行高度
  final double? rowHeight;

  /// 表头字体大小
  final double? headerFontSize;

  /// 数据字体大小
  final double? dataFontSize;

  /// 表头颜色
  final pw.PdfColor? headerColor;

  /// 数据颜色
  final pw.PdfColor? dataColor;

  /// 表头背景颜色
  final pw.PdfColor? headerBackgroundColor;

  /// 表头对齐方式
  final pw.Alignment headerAlignment;

  /// 数据对齐方式
  final pw.Alignment dataAlignment;

  /// 默认列宽配置
  final List<double>? defaultColumnWidths;

  /// 单元格垂直对齐方式
  final pw.TableCellVerticalAlignment cellVerticalAlignment;

  const CommonTableConfig({
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
    this.defaultColumnWidths,
    this.cellVerticalAlignment = pw.TableCellVerticalAlignment.middle,
  });
}
