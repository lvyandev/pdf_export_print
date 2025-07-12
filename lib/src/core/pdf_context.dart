import 'package:flutter/material.dart';
import 'package:pdf_export_print/src/themes/themes.dart';

/// PDF上下文，提供渲染时的环境信息
class PDFContext {
  /// 可用页面宽度
  final double availableWidth;

  /// 可用页面高度
  final double availableHeight;

  /// 当前页码
  final int currentPage;

  /// 样式主题
  final StyleTheme theme;

  /// 页面边距
  final EdgeInsets margins;

  PDFContext({
    required this.availableWidth,
    required this.availableHeight,
    required this.currentPage,
    required this.theme,
    required this.margins,
  });
}
