import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf_export_print/src/configs/module_config.dart';

/// 主表模块配置
class MainTableConfig {
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

  /// 标题字体大小
  final double? labelFontSize;

  /// 内容字体大小
  final double? contentFontSize;

  /// 标题颜色
  final PdfColor? labelColor;

  /// 内容颜色
  final PdfColor? contentColor;

  /// 顶部间距
  final double topSpacing;

  /// 底部间距
  final double bottomSpacing;

  /// 每行字段数
  final int fieldsPerRow;

  /// 模块配置
  final ModuleConfig moduleConfig;

  MainTableConfig({
    this.showBorder = true,
    this.showInnerBorder = true,

    this.borderColor,
    this.borderWidth,
    this.cellPadding = const pw.EdgeInsets.all(4),
    this.labelFontSize,
    this.contentFontSize,
    this.labelColor,
    this.contentColor,
    this.topSpacing = 0.0,
    this.bottomSpacing = 0.0,
    this.fieldsPerRow = 3,
    ModuleConfig? moduleConfig,
  }) : moduleConfig = moduleConfig ?? ModuleConfig(priority: 30);

  /// 创建默认配置
  static MainTableConfig defaultConfig() => MainTableConfig();

  /// 创建无边框配置
  static MainTableConfig noBorderConfig() =>
      MainTableConfig(showBorder: false, showInnerBorder: false);

  /// 创建紧凑配置
  static MainTableConfig compactConfig() => MainTableConfig(
    cellPadding: const pw.EdgeInsets.all(2),
    topSpacing: 0.0,
    bottomSpacing: 10.0,
  );
}
