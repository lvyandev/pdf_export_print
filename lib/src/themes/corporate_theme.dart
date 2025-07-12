import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'style_theme.dart';

/// 企业主题
class CorporateTheme extends StyleTheme {
  final PdfColor _brandColor;

  CorporateTheme(this._brandColor);

  @override
  PdfColor get primaryColor => _brandColor;

  @override
  PdfColor get titleColor => _brandColor;

  @override
  PdfColor get borderColor => PdfColors.grey;

  @override
  PdfColor get backgroundColor => PdfColors.white;

  @override
  pw.Font? get defaultFont => null;

  @override
  pw.Font? get titleFont => null;

  @override
  pw.Font? get boldFont => null;

  @override
  double get defaultFontSize => 12;

  @override
  double get titleFontSize => 18;

  @override
  double get borderWidth => 0.5;
}
