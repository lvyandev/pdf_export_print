import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/components/components.dart';
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/models/models.dart';

/// 页脚模块，用于显示页面底部信息
class FooterModule extends PDFModule {
  final FooterConfig _config;

  FooterModule({FooterConfig? config})
    : _config = config ?? FooterConfig.defaultConfig();

  @override
  String get moduleId => 'footer';

  @override
  int get priority => 90; // 最低优先级，最后渲染

  @override
  ModuleConfig get config => _config.moduleConfig;

  @override
  Future<List<pw.Widget>> render(ModuleData data, PDFContext context) async {
    // 直接使用MainTableData，适配器保证输入类型正确
    final footerData = data as MainTableData;

    if (footerData.fields.isEmpty) {
      return [];
    }

    final List<pw.Widget> widgets = [];

    // 添加顶部间距
    if (_config.topSpacing > 0) {
      widgets.add(pw.SizedBox(height: _config.topSpacing));
    }

    // 构建页脚表格
    final table = _buildFooterTable(footerData.fields, context);
    widgets.add(table);

    // 添加底部间距
    if (_config.bottomSpacing > 0) {
      widgets.add(pw.SizedBox(height: _config.bottomSpacing));
    }

    return widgets;
  }

  @override
  bool canRender(ModuleData data) {
    // 直接使用MainTableData，适配器保证输入类型正确
    final footerData = data as MainTableData;
    return footerData.fields.isNotEmpty;
  }

  /// 构建页脚表格
  pw.Widget _buildFooterTable(List<TableField> fields, PDFContext context) {
    // 使用通用的自定义表格布局组件
    final layoutConfig = CustomTableConfig.forFooter(
      showBorder: _config.showBorder,
      showInnerBorder: _config.showInnerBorder,
      borderColor: _config.borderColor,
      borderWidth: _config.borderWidth,
      cellPadding: _config.cellPadding,
      fieldsPerRow: _config.fieldsPerRow,
      labelFontSize: _config.labelFontSize,
      contentFontSize: _config.contentFontSize,
      labelColor: _config.labelColor,
      contentColor: _config.contentColor,
    );

    final layout = CustomTableLayout(config: layoutConfig);
    return layout.buildTable(fields, context, _config.showBorder);
  }
}
