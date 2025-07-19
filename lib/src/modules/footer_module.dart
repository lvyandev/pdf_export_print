import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/components/components.dart';
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/models/models.dart';

/// 页脚模块，用于显示页面底部信息
class FooterModule extends PDFModule {
  final FooterConfig _config;
  final ModuleDescriptor _descriptor;

  FooterModule({FooterConfig? config, required ModuleDescriptor descriptor})
    : this._internal(config ?? FooterConfig.defaultConfig(), descriptor);

  FooterModule._internal(this._config, this._descriptor) : super(_config);

  @override
  ModuleDescriptor get descriptor => _descriptor;

  @override
  Future<List<pw.Widget>> render(
    ModuleDescriptor descriptor,
    PDFContext context,
  ) async {
    // 直接使用 ModuleDescriptor 中的数据，或者如果传入的就是 MainTableData 则直接使用
    final MainTableData footerData;

    if (descriptor is MainTableData) {
      // 如果传入的就是 MainTableData，直接使用
      footerData = descriptor;
    } else {
      // 从 ModuleDescriptor.data 创建 MainTableData（用于页脚）
      footerData = MainTableData.fromDescriptor(descriptor);
    }

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
  bool canRender(ModuleDescriptor descriptor) {
    try {
      final MainTableData footerData;
      if (descriptor is MainTableData) {
        footerData = descriptor;
      } else {
        footerData = MainTableData.fromDescriptor(descriptor);
      }
      return footerData.fields.isNotEmpty;
    } catch (e) {
      return false;
    }
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
