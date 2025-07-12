import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf_export_print/src/configs/module_config.dart';

/// 页脚模块配置
class FooterConfig {
  /// 是否显示边框（只有外框）
  final bool showBorder;

  /// 是否显示内边框
  final bool showInnerBorder;

  /// 边框颜色
  final PdfColor? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 单元格内边距
  final pw.EdgeInsets cellPadding;

  /// 单元格高度
  final double cellHeight;

  /// 每行显示的字段数
  final int fieldsPerRow;

  /// 标题字体大小
  final double? labelFontSize;

  /// 内容字体大小
  final double? contentFontSize;

  /// 标题颜色
  final PdfColor? labelColor;

  /// 内容颜色
  final PdfColor? contentColor;

  /// 标题对齐方式
  final pw.Alignment labelAlignment;

  /// 内容对齐方式
  final pw.Alignment contentAlignment;

  /// 顶部间距
  final double topSpacing;

  /// 底部间距
  final double bottomSpacing;

  /// 模块配置
  final ModuleConfig moduleConfig;

  FooterConfig({
    this.showBorder = true,
    this.showInnerBorder = false,
    this.borderColor,
    this.borderWidth,
    this.cellPadding = const pw.EdgeInsets.all(4),
    this.cellHeight = 25.0,
    this.fieldsPerRow = 3,
    this.labelFontSize,
    this.contentFontSize,
    this.labelColor,
    this.contentColor,
    this.labelAlignment = pw.Alignment.centerLeft,
    this.contentAlignment = pw.Alignment.centerLeft,
    this.topSpacing = 0.0,
    this.bottomSpacing = 0.0,
    ModuleConfig? moduleConfig,
  }) : moduleConfig = moduleConfig ?? ModuleConfig(priority: 90);

  /// 创建默认配置
  static FooterConfig defaultConfig() => FooterConfig();

  /// 创建无边框配置
  static FooterConfig noBorderConfig() =>
      FooterConfig(showBorder: false, showInnerBorder: false);

  /// 创建紧凑配置
  static FooterConfig compactConfig() => FooterConfig(
    cellPadding: const pw.EdgeInsets.all(2),
    cellHeight: 20.0,
    topSpacing: 10.0,
  );
}
