import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/components/components.dart';
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/models/models.dart';
import 'package:pdf_export_print/src/themes/themes.dart';

/// 子表模块，用于显示可分页的数据表格
///
/// 统一处理子表和审批记录，通过配置区分不同类型
class SubTableModule extends PDFModule {
  final SubTableConfig _config;
  final String? _customModuleId;
  late final CommonTableWidget _tableWidget;

  SubTableModule({SubTableConfig? config, String? moduleId})
    : _config = config ?? SubTableConfig.defaultConfig(),
      _customModuleId = moduleId {
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
      ),
    );
  }

  @override
  String get moduleId => _customModuleId ?? 'sub_table';

  @override
  int get priority => 40; // 中等优先级

  @override
  ModuleConfig get config => _config.moduleConfig;

  @override
  Future<List<pw.Widget>> render(ModuleData data, PDFContext context) async {
    // 直接使用SubTableData，适配器保证输入类型正确
    final subTableData = data as SubTableData;

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
      final title = subTableData.title ?? moduleId;
      widgets.add(_buildTitle(title, context));
    }

    // 构建表格
    final table = _buildTableFromSubTableData(subTableData, context);
    widgets.add(table);

    // 添加底部间距
    if (_config.bottomSpacing > 0) {
      widgets.add(pw.SizedBox(height: _config.bottomSpacing));
    }

    return widgets;
  }

  @override
  bool canRender(ModuleData data) {
    // 直接使用SubTableData，适配器保证输入类型正确
    final subTableData = data as SubTableData;
    return !subTableData.isEmpty;
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
  pw.Widget _buildTableFromSubTableData(
    SubTableData subTableData,
    PDFContext context,
  ) {
    // 将SubTableData转换为CommonTableWidget需要的格式
    final headers = subTableData.headers;
    final rows = subTableData.rows.map((rowFields) {
      return rowFields.map((field) => field.value).toList();
    }).toList();

    // 创建一个临时的ModuleData用于传递给CommonTableWidget
    final tempData = ModuleData(
      moduleType: subTableData.moduleType,
      data: {
        'headers': headers,
        'rows': rows,
        'title': subTableData.title,
        'showBorder': subTableData.showBorder,
        // 添加列宽信息
        'columnWidths': _extractColumnWidths(subTableData),
      },
    );

    return _tableWidget.buildTable(headers, rows, tempData, context);
  }

  /// 从SubTableData提取列宽信息
  List<double> _extractColumnWidths(SubTableData subTableData) {
    if (subTableData.rows.isEmpty) {
      return List.filled(
        subTableData.headers.length,
        1.0 / subTableData.headers.length,
      );
    }

    // 使用第一行的字段来确定列宽
    final firstRow = subTableData.rows.first;
    final columnWidths = <double>[];

    for (int i = 0; i < subTableData.headers.length; i++) {
      if (i < firstRow.length) {
        columnWidths.add(firstRow[i].getEffectiveWidthPercent());
      } else {
        // 如果没有对应的字段，使用平均宽度
        columnWidths.add(1.0 / subTableData.headers.length);
      }
    }

    // 确保总宽度为1.0
    final totalWidth = columnWidths.fold(0.0, (sum, width) => sum + width);
    if (totalWidth > 0) {
      for (int i = 0; i < columnWidths.length; i++) {
        columnWidths[i] = columnWidths[i] / totalWidth;
      }
    }

    return columnWidths;
  }
}
