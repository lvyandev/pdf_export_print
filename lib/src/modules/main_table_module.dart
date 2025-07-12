import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/components/components.dart';
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/models/models.dart';

/// 主表模块，用于显示6列表格形式的主表数据
class MainTableModule extends PDFModule {
  final MainTableConfig _config;

  MainTableModule({MainTableConfig? config})
    : _config = config ?? MainTableConfig.defaultConfig();

  @override
  String get moduleId => 'main_table';

  @override
  int get priority => 30; // 中等优先级

  @override
  ModuleConfig get config => _config.moduleConfig;

  @override
  Future<List<pw.Widget>> render(ModuleData data, PDFContext context) async {
    // 直接使用MainTableData，适配器保证输入类型正确
    final mainTableData = data as MainTableData;

    if (mainTableData.fields.isEmpty) {
      return [];
    }

    final List<pw.Widget> widgets = [];

    // 添加顶部间距
    if (_config.topSpacing > 0) {
      widgets.add(pw.SizedBox(height: _config.topSpacing));
    }

    // 构建表格
    final table = _buildTable(mainTableData.fields, mainTableData, context);
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
    final mainTableData = data as MainTableData;
    return mainTableData.fields.isNotEmpty;
  }

  /// 构建表格
  pw.Widget _buildTable(
    List<TableField> fields,
    MainTableData mainTableData,
    PDFContext context,
  ) {
    // 使用配置中的边框设置，而不是从数据中获取
    final showBorder = _config.showBorder;

    // 使用自定义表格布局组件
    final layoutConfig = CustomTableConfig.forMainTable(
      showBorder: showBorder,
      showInnerBorder: _config.showInnerBorder,
      borderColor: _config.borderColor,
      borderWidth: _config.borderWidth,
      cellPadding: _config.cellPadding,
      labelFontSize: _config.labelFontSize,
      contentFontSize: _config.contentFontSize,
      labelColor: _config.labelColor,
      contentColor: _config.contentColor,
    );

    final layout = CustomTableLayout(config: layoutConfig);
    return layout.buildTable(fields, context, showBorder);
  }
}
