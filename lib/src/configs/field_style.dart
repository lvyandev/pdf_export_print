import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

/// 字段样式配置
class FieldStyle {
  /// 字体大小
  final double? fontSize;
  
  /// 字体颜色
  final PdfColor? color;
  
  /// 是否粗体
  final bool bold;
  
  /// 文本对齐方式
  final pw.Alignment? alignment;
  
  /// 背景颜色
  final PdfColor? backgroundColor;
  
  FieldStyle({
    this.fontSize,
    this.color,
    this.bold = false,
    this.alignment,
    this.backgroundColor,
  });
}
