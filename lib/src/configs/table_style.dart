import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';

/// 表格样式配置
class TableStyle {
  /// 是否显示边框
  final bool showBorder;
  
  /// 边框颜色
  final PdfColor borderColor;
  
  /// 边框宽度
  final double borderWidth;
  
  /// 背景颜色
  final PdfColor backgroundColor;
  
  /// 内边距
  final EdgeInsets padding;
  
  /// 是否显示表头
  final bool showHeader;
  
  /// 表头背景颜色
  final PdfColor? headerBackgroundColor;
  
  TableStyle({
    this.showBorder = true,
    this.borderColor = PdfColors.black,
    this.borderWidth = 1.0,
    this.backgroundColor = PdfColors.white,
    this.padding = const EdgeInsets.all(4),
    this.showHeader = true,
    this.headerBackgroundColor,
  });
  
  /// 创建默认表格样式
  static TableStyle defaultStyle() => TableStyle();
  
  /// 创建无边框样式
  static TableStyle noBorderStyle() => TableStyle(showBorder: false);
}
