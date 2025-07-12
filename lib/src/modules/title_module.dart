import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/models/models.dart';
import 'package:pdf_export_print/src/themes/themes.dart';

/// 标题模块，用于显示多行居中的红色标题
class TitleModule extends PDFModule {
  final TitleConfig _config;

  TitleModule({TitleConfig? config})
    : _config = config ?? TitleConfig.defaultConfig();

  @override
  String get moduleId => 'title';

  @override
  int get priority => 20; // 中等优先级

  @override
  ModuleConfig get config => _config.moduleConfig;

  @override
  Future<List<pw.Widget>> render(ModuleData data, PDFContext context) async {
    // 直接使用TitleData，适配器保证输入类型正确
    final titleData = data as TitleData;

    if (titleData.titles.isEmpty) {
      return [];
    }

    final List<pw.Widget> widgets = [];

    // 添加顶部间距
    if (_config.topSpacing > 0) {
      widgets.add(pw.SizedBox(height: _config.topSpacing));
    }

    // 渲染每个标题
    for (int i = 0; i < titleData.titles.length; i++) {
      final title = titleData.titles[i];
      if (title.isNotEmpty) {
        widgets.add(_buildTitleWidget(title, titleData, context));

        // 添加标题间距（除了最后一个标题）
        if (i < titleData.titles.length - 1 && _config.titleSpacing > 0) {
          widgets.add(pw.SizedBox(height: _config.titleSpacing));
        }
      }
    }

    // 添加底部间距
    if (_config.bottomSpacing > 0) {
      widgets.add(pw.SizedBox(height: _config.bottomSpacing));
    }

    return widgets;
  }

  @override
  bool canRender(ModuleData data) {
    // 直接使用TitleData，适配器保证输入类型正确
    final titleData = data as TitleData;
    return titleData.titles.isNotEmpty;
  }

  /// 构建标题Widget
  pw.Widget _buildTitleWidget(
    String title,
    TitleData titleData,
    PDFContext context,
  ) {
    // 优先使用TitleData中的颜色，其次使用配置中的颜色
    final dataColor = titleData.color != null
        ? _getColorFromString(titleData.color!)
        : null;
    final color =
        dataColor ??
        _getColorFromString(_config.color) ??
        context.theme.titleColor;

    // 优先使用TitleData中的对齐方式，其次使用配置中的对齐方式
    final dataAlignment = titleData.alignment != null
        ? _getAlignmentFromString(titleData.alignment!)
        : null;
    final alignment = dataAlignment ?? _config.alignment;

    // 获取字体大小
    final fontSize = _config.fontSize ?? context.theme.titleFontSize;

    // 获取字体
    final font = _config.font ?? context.theme.titleFont;

    return pw.Container(
      width: context.availableWidth,
      child: pw.Align(
        alignment: alignment,
        child: pw.Text(
          title,
          style: pw.TextStyle(
            color: color,
            fontSize: fontSize,
            font:
                DefaultTheme.getFontByWeight(
                  _getFontWeightValue(_config.fontWeight),
                ) ??
                font,
            fontWeight: _config.fontWeight,
          ),
          textAlign: _getTextAlign(alignment),
        ),
      ),
    );
  }

  /// 从字符串获取颜色
  PdfColor? _getColorFromString(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'red':
        return PdfColors.red;
      case 'blue':
        return PdfColors.blue;
      case 'green':
        return PdfColors.green;
      case 'black':
        return PdfColors.black;
      case 'grey':
      case 'gray':
        return PdfColors.grey;
      default:
        return null;
    }
  }

  /// 从字符串获取对齐方式
  pw.Alignment? _getAlignmentFromString(String alignmentStr) {
    switch (alignmentStr.toLowerCase()) {
      case 'left':
        return pw.Alignment.centerLeft;
      case 'right':
        return pw.Alignment.centerRight;
      case 'center':
        return pw.Alignment.center;
      case 'topleft':
        return pw.Alignment.topLeft;
      case 'topright':
        return pw.Alignment.topRight;
      case 'topcenter':
        return pw.Alignment.topCenter;
      default:
        return null;
    }
  }

  /// 从对齐方式获取文本对齐
  pw.TextAlign _getTextAlign(pw.Alignment alignment) {
    if (alignment == pw.Alignment.centerLeft ||
        alignment == pw.Alignment.topLeft) {
      return pw.TextAlign.left;
    } else if (alignment == pw.Alignment.centerRight ||
        alignment == pw.Alignment.topRight) {
      return pw.TextAlign.right;
    } else {
      return pw.TextAlign.center;
    }
  }

  /// 创建带自定义样式的标题模块
  TitleModule withStyle(TitleStyle style) {
    return TitleModule(
      config: TitleConfig(
        color: style.color ?? _config.color,
        fontSize: style.fontSize ?? _config.fontSize,
        fontWeight: style.fontWeight ?? _config.fontWeight,
        alignment: style.alignment ?? _config.alignment,
        topSpacing: _config.topSpacing,
        bottomSpacing: _config.bottomSpacing,
        titleSpacing: _config.titleSpacing,
      ),
    );
  }

  /// 获取FontWeight的数值
  int _getFontWeightValue(pw.FontWeight fontWeight) {
    if (fontWeight == pw.FontWeight.normal) return 400;
    if (fontWeight == pw.FontWeight.bold) return 700;
    // 对于其他FontWeight，使用默认值
    return 400;
  }
}
