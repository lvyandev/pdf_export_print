import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/themes/themes.dart';
import 'package:pdf_export_print/src/configs/watermark_config.dart';

/// PDF配置类，定义PDF生成的全局配置
abstract class PDFConfig {
  /// 页面尺寸
  PdfPageFormat get pageSize;

  /// 页面边距
  pw.EdgeInsets get margins;

  /// 样式主题
  StyleTheme get theme;

  /// 页面方向
  pw.PageOrientation? get orientation;

  /// 水印配置
  WatermarkConfig get watermarkConfig;

  /// 创建默认配置
  static PDFConfig defaultConfig() => _DefaultPDFConfig();

  /// 创建配置构建器
  static PDFConfigBuilder builder() => PDFConfigBuilder();
}

/// PDF配置构建器
class PDFConfigBuilder {
  PdfPageFormat _pageSize = PdfPageFormat.a4;
  pw.EdgeInsets _margins = const pw.EdgeInsets.all(20);
  StyleTheme _theme = DefaultTheme();
  pw.PageOrientation? _orientation = pw.PageOrientation.landscape;
  WatermarkConfig _watermarkConfig = WatermarkConfig.defaultConfig();

  /// 设置页面尺寸
  PDFConfigBuilder pageSize(PdfPageFormat size) {
    _pageSize = size;
    return this;
  }

  /// 设置页面边距
  PDFConfigBuilder margins(pw.EdgeInsets margins) {
    _margins = margins;
    return this;
  }

  /// 设置样式主题
  PDFConfigBuilder theme(StyleTheme theme) {
    _theme = theme;
    return this;
  }

  /// 设置页面方向
  PDFConfigBuilder withOrientation(pw.PageOrientation? orientation) {
    _orientation = orientation;
    return this;
  }

  /// 设置水印配置
  PDFConfigBuilder watermark(WatermarkConfig watermarkConfig) {
    _watermarkConfig = watermarkConfig;
    return this;
  }

  /// 构建配置对象
  PDFConfig build() {
    return _CustomPDFConfig(
      pageSize: _pageSize,
      margins: _margins,
      theme: _theme,
      orientation: _orientation,
      watermarkConfig: _watermarkConfig,
    );
  }
}

/// 默认PDF配置实现
class _DefaultPDFConfig extends PDFConfig {
  @override
  PdfPageFormat get pageSize => PdfPageFormat.a4;

  @override
  pw.EdgeInsets get margins => const pw.EdgeInsets.all(16);

  @override
  StyleTheme get theme => DefaultTheme();

  @override
  pw.PageOrientation? get orientation => pw.PageOrientation.landscape;

  @override
  WatermarkConfig get watermarkConfig => WatermarkConfig.defaultConfig();
}

/// 自定义PDF配置实现
class _CustomPDFConfig extends PDFConfig {
  final PdfPageFormat _pageSize;
  final pw.EdgeInsets _margins;
  final StyleTheme _theme;
  final pw.PageOrientation? _orientation;
  final WatermarkConfig _watermarkConfig;

  _CustomPDFConfig({
    required PdfPageFormat pageSize,
    required pw.EdgeInsets margins,
    required StyleTheme theme,
    pw.PageOrientation? orientation,
    required WatermarkConfig watermarkConfig,
  }) : _pageSize = pageSize,
       _margins = margins,
       _theme = theme,
       _orientation = orientation,
       _watermarkConfig = watermarkConfig;

  @override
  PdfPageFormat get pageSize => _pageSize;

  @override
  pw.EdgeInsets get margins => _margins;

  @override
  StyleTheme get theme => _theme;

  @override
  pw.PageOrientation? get orientation => _orientation;

  @override
  WatermarkConfig get watermarkConfig => _watermarkConfig;
}
