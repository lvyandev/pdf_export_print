import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// 样式主题抽象类
abstract class StyleTheme {
  /// 主要颜色
  PdfColor get primaryColor;

  /// 标题颜色
  PdfColor get titleColor;

  /// 边框颜色
  PdfColor get borderColor;

  /// 背景颜色
  PdfColor get backgroundColor;

  /// 默认字体
  pw.Font? get defaultFont;

  /// 标题字体
  pw.Font? get titleFont;

  /// 粗体字体
  pw.Font? get boldFont;

  /// 默认字体大小
  double get defaultFontSize;

  /// 标题字体大小
  double get titleFontSize;

  /// 边框宽度
  double get borderWidth;
}
