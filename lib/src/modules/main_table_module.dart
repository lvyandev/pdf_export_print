import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/components/components.dart';
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/models/models.dart';

/// 主表模块，用于显示6列表格形式的主表数据
class MainTableModule extends PDFModule {
  final MainTableConfig _config;
  final ModuleDescriptor _descriptor;

  MainTableModule({
    MainTableConfig? config,
    required ModuleDescriptor descriptor,
  }) : this._internal(config ?? MainTableConfig.defaultConfig(), descriptor);

  MainTableModule._internal(this._config, this._descriptor) : super(_config);

  @override
  ModuleDescriptor get descriptor => _descriptor;

  @override
  Future<List<pw.Widget>> render(
    ModuleDescriptor descriptor,
    PDFContext context,
  ) async {
    // 直接使用 ModuleDescriptor 中的数据，或者如果传入的就是 MainTableData 则直接使用
    final MainTableData mainTableData;

    if (descriptor is MainTableData) {
      // 如果传入的就是 MainTableData，直接使用
      mainTableData = descriptor;
    } else {
      // 从 ModuleDescriptor.data 创建 MainTableData
      mainTableData = MainTableData.fromDescriptor(descriptor);
    }

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
  bool canRender(ModuleDescriptor descriptor) {
    try {
      final MainTableData mainTableData;
      if (descriptor is MainTableData) {
        mainTableData = descriptor;
      } else {
        mainTableData = MainTableData.fromDescriptor(descriptor);
      }
      return mainTableData.fields.isNotEmpty;
    } catch (e) {
      return false;
    }
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
    final layoutConfig = CustomTableConfig(
      showBorder: showBorder,
      showInnerBorder: _config.showInnerBorder,
      borderColor: _config.borderColor,
      borderWidth: _config.borderWidth,
      cellPadding: _config.cellPadding,
      maxColumnsPerRow: _config.fieldsPerRow,
      labelFontSize: _config.labelFontSize,
      contentFontSize: _config.contentFontSize,
      labelColor: _config.labelColor,
      contentColor: _config.contentColor,
    );

    final layout = CustomTableLayout(config: layoutConfig);
    return layout.buildTable(fields, context, showBorder);
  }
}
