import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

/// 自定义表格布局配置
class CustomTableConfig {
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

  /// 每行最大列数
  final int maxColumnsPerRow;

  /// 标题与内容的比例（标题:内容 = 1:(ratio-1)）
  final double labelContentRatio;

  /// 标题字体大小
  final double? labelFontSize;

  /// 内容字体大小
  final double? contentFontSize;

  /// 标题颜色
  final PdfColor? labelColor;

  /// 内容颜色
  final PdfColor? contentColor;

  CustomTableConfig({
    this.showBorder = true,
    this.showInnerBorder = true,
    this.borderColor,
    this.borderWidth,
    this.cellPadding = const pw.EdgeInsets.all(4),
    this.maxColumnsPerRow = 3,
    this.labelContentRatio = 3.0, // 标题:内容 = 1:2
    this.labelFontSize,
    this.contentFontSize,
    this.labelColor,
    this.contentColor,
  });

  /// 创建主表配置
  static CustomTableConfig forMainTable({
    bool showBorder = true,
    bool showInnerBorder = true,
    PdfColor? borderColor,
    double? borderWidth,
    pw.EdgeInsets? cellPadding,
    double? labelFontSize,
    double? contentFontSize,
    PdfColor? labelColor,
    PdfColor? contentColor,
  }) {
    return CustomTableConfig(
      showBorder: showBorder,
      showInnerBorder: showInnerBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      cellPadding: cellPadding ?? const pw.EdgeInsets.all(4),
      maxColumnsPerRow: 3,
      labelContentRatio: 3.0,
      labelFontSize: labelFontSize,
      contentFontSize: contentFontSize,
      labelColor: labelColor,
      contentColor: contentColor,
    );
  }

  /// 创建页脚配置
  static CustomTableConfig forFooter({
    bool showBorder = true,
    bool showInnerBorder = false,
    PdfColor? borderColor,
    double? borderWidth,
    pw.EdgeInsets? cellPadding,
    int fieldsPerRow = 3,
    double? labelFontSize,
    double? contentFontSize,
    PdfColor? labelColor,
    PdfColor? contentColor,
  }) {
    return CustomTableConfig(
      showBorder: showBorder,
      showInnerBorder: showInnerBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      cellPadding: cellPadding ?? const pw.EdgeInsets.all(4),
      maxColumnsPerRow: fieldsPerRow,
      labelContentRatio: 2.0, // 页脚标题:内容 = 1:1
      labelFontSize: labelFontSize,
      contentFontSize: contentFontSize,
      labelColor: labelColor,
      contentColor: contentColor,
    );
  }
}
