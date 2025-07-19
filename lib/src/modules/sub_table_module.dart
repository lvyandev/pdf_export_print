import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/components/components.dart';
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/table_field.dart';
import 'package:pdf_export_print/src/models/models.dart';
import 'package:pdf_export_print/src/themes/themes.dart';

/// 子表模块，用于显示可分页的数据表格
///
/// 统一处理子表和审批记录，通过配置区分不同类型
class SubTableModule extends PDFModule {
  final SubTableConfig _config;
  final ModuleDescriptor _descriptor;
  late final CommonTableWidget _tableWidget;

  SubTableModule({SubTableConfig? config, required ModuleDescriptor descriptor})
    : this._internal(config ?? SubTableConfig.defaultConfig(), descriptor);

  SubTableModule._internal(this._config, this._descriptor) : super(_config) {
    _tableWidget = CommonTableWidget(
      config: CommonTableConfig(
        showBorder: _config.showBorder,
        borderColor: _config.borderColor,
        borderWidth: _config.borderWidth,
        cellPadding: _config.cellPadding,
        headerHeight: _config.headerHeight,
        rowHeight: _config.rowHeight,
        headerFontSize: _config.headerFontSize,
        dataFontSize: _config.dataFontSize,
        headerColor: _config.headerColor,
        dataColor: _config.dataColor,
        headerBackgroundColor: _config.headerBackgroundColor,
        headerAlignment: _config.headerAlignment,
        dataAlignment: _config.dataAlignment,
        defaultColumnWidths: _config.defaultColumnWidths,
        cellVerticalAlignment: _config.cellVerticalAlignment,
      ),
    );
  }

  @override
  ModuleDescriptor get descriptor => _descriptor;

  @override
  Future<List<pw.Widget>> render(
    ModuleDescriptor descriptor,
    PDFContext context,
  ) async {
    // 直接使用 ModuleDescriptor 中的数据，或者如果传入的就是 SubTableData 则直接使用
    final SubTableData subTableData;

    if (descriptor is SubTableData) {
      // 如果传入的就是 SubTableData，直接使用
      subTableData = descriptor;
    } else {
      // 从 ModuleDescriptor.data 创建 SubTableData
      subTableData = SubTableData.fromDescriptor(descriptor);
    }

    if (subTableData.isEmpty) {
      return [];
    }

    final List<pw.Widget> widgets = [];

    // 添加顶部间距
    if (_config.topSpacing > 0) {
      widgets.add(pw.SizedBox(height: _config.topSpacing));
    }

    // 添加标题（如果配置启用）
    if (_config.showTitle) {
      final title = subTableData.title ?? descriptor.moduleId; // 使用模块ID作为标题
      widgets.add(_buildTitle(title, context));
    }

    // 构建表格
    final table = await _buildTableFromSubTableData(subTableData, context);
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
      final SubTableData subTableData;
      if (descriptor is SubTableData) {
        subTableData = descriptor;
      } else {
        subTableData = SubTableData.fromDescriptor(descriptor);
      }
      return !subTableData.isEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 构建标题
  pw.Widget _buildTitle(String title, PDFContext context) {
    return pw.Container(
      width: context.availableWidth,
      padding: pw.EdgeInsets.symmetric(vertical: _config.titlePadding),
      alignment: _config.titleAlignment,
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: _config.titleFontSize ?? context.theme.titleFontSize,
          fontWeight: pw.FontWeight.bold,
          color: _config.titleColor ?? context.theme.titleColor,
          font: DefaultTheme.getFontByWeight(700),
        ),
      ),
    );
  }

  /// 从SubTableData构建表格
  Future<pw.Widget> _buildTableFromSubTableData(
    SubTableData subTableData,
    PDFContext context,
  ) async {
    final headers = subTableData.headers;

    // 直接使用已解析的 TableField 数据
    final List<List<TableField>> tableFieldRows = subTableData.tableRows;

    // 使用支持 TableField 的方法
    return await _tableWidget.buildTableWithFields(
      headers,
      tableFieldRows,
      context,
    );
  }
}
