import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/table_field.dart';
import 'package:pdf_export_print/src/themes/themes.dart';
import 'package:pdf_export_print/src/configs/common_table_config.dart';
import 'package:pdf_export_print/src/components/cell_renderer.dart';

/// 通用表格组件
class CommonTableWidget {
  final CommonTableConfig _config;

  const CommonTableWidget({required CommonTableConfig config})
    : _config = config;

  /// 构建表格（支持TableField）
  Future<pw.Widget> buildTableWithFields(
    List<String> headers,
    List<List<TableField>> rows,
    PDFContext context, {
    List<double>? columnWidths,
  }) async {
    // 处理表头排序（基于 TableField 的 sort 属性）
    final sortedData = _sortTableDataWithFields(headers, rows);
    final List<String> sortedHeaders = sortedData['headers'] as List<String>;
    final List<List<TableField>> sortedRows =
        sortedData['rows'] as List<List<TableField>>;

    // 如果没有提供列宽，从 TableField 中提取
    final effectiveColumnWidths =
        columnWidths ?? _extractColumnWidthsFromFields(sortedRows);

    // 构建表格行（异步）
    final List<pw.TableRow> tableRows = [];

    // 添加表头行
    tableRows.add(_buildHeaderRow(sortedHeaders, context));

    // 添加数据行（异步处理）
    for (final row in sortedRows) {
      final tableRow = await _buildDataRowWithFields(
        row,
        sortedHeaders.length,
        context,
      );
      tableRows.add(tableRow);
    }

    return pw.Table(
      columnWidths: _buildColumnWidths(
        sortedHeaders.length,
        effectiveColumnWidths,
      ),
      border: _config.showBorder ? _createTableBorder(context) : null,
      defaultVerticalAlignment: _config.cellVerticalAlignment,
      children: tableRows,
    );
  }

  /// 构建列宽配置
  Map<int, pw.TableColumnWidth> _buildColumnWidths(
    int columnCount,
    List<double>? widths,
  ) {
    if (widths != null && widths.length == columnCount) {
      return {
        for (int i = 0; i < columnCount; i++) i: pw.FlexColumnWidth(widths[i]),
      };
    }

    // 使用默认列宽配置
    if (_config.defaultColumnWidths != null &&
        _config.defaultColumnWidths!.length == columnCount) {
      return {
        for (int i = 0; i < columnCount; i++)
          i: pw.FlexColumnWidth(_config.defaultColumnWidths![i]),
      };
    }

    // 如果都不匹配，使用等宽
    return {
      for (int i = 0; i < columnCount; i++) i: const pw.FlexColumnWidth(1),
    };
  }

  /// 创建表格边框
  pw.TableBorder _createTableBorder(PDFContext context) {
    return pw.TableBorder.all(
      color: _config.borderColor ?? context.theme.borderColor,
      width: _config.borderWidth ?? context.theme.borderWidth,
    );
  }

  /// 构建表头行
  pw.TableRow _buildHeaderRow(List<String> headers, PDFContext context) {
    return pw.TableRow(
      decoration: _config.headerBackgroundColor != null
          ? pw.BoxDecoration(color: _config.headerBackgroundColor)
          : null,
      children: headers
          .map((header) => _buildHeaderCell(header, context))
          .toList(),
    );
  }

  /// 构建表头单元格
  pw.Widget _buildHeaderCell(String header, PDFContext context) {
    return pw.Container(
      padding: _config.cellPadding,
      height: _config.headerHeight, // null时自适应高度
      alignment: _config.headerAlignment,
      child: pw.Text(
        header,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: _config.headerFontSize ?? context.theme.defaultFontSize,
          color: _config.headerColor ?? context.theme.primaryColor,
          font: DefaultTheme.getFontByWeight(700),
        ),
      ),
    );
  }

  /// 构建数据行（支持TableField）
  Future<pw.TableRow> _buildDataRowWithFields(
    List<TableField> row,
    int expectedColumns,
    PDFContext context,
  ) async {
    // 确保行数据长度与列数匹配
    final List<TableField> paddedRow = List<TableField>.from(row);
    while (paddedRow.length < expectedColumns) {
      paddedRow.add(TableField(label: '', value: ''));
    }
    if (paddedRow.length > expectedColumns) {
      paddedRow.removeRange(expectedColumns, paddedRow.length);
    }

    // 异步构建单元格
    final List<pw.Widget> cells = [];
    for (final field in paddedRow) {
      final cell = await _buildDataCellWithField(field, context);
      cells.add(cell);
    }

    return pw.TableRow(children: cells);
  }

  /// 构建数据单元格
  pw.Widget _buildDataCell(String cell, PDFContext context) {
    return pw.Container(
      padding: _config.cellPadding,
      alignment: _config.dataAlignment,
      child: pw.Text(
        cell,
        style: pw.TextStyle(
          fontSize: _config.dataFontSize ?? context.theme.defaultFontSize,
          color: _config.dataColor ?? context.theme.primaryColor,
          font: DefaultTheme.getFontByWeight(400),
        ),
      ),
    );
  }

  /// 构建数据单元格（支持TableField）
  Future<pw.Widget> _buildDataCellWithField(
    TableField field,
    PDFContext context,
  ) async {
    final content = field.effectiveContent;
    final renderer = CellRendererFactory.getRenderer(content.type);

    if (renderer == null) {
      // 降级到文本显示
      return _buildDataCell(content.displayText, context);
    }

    final renderContext = CellRenderContext(
      availableWidth: _calculateColumnWidth(field, context),
      maxHeight: _getMaxCellHeight(context),
      pdfContext: context,
      config: _config,
    );

    return await renderer.render(content, renderContext);
  }

  /// 计算列宽
  double _calculateColumnWidth(TableField field, PDFContext context) {
    final widthPercent = field.getEffectiveWidthPercent();
    return context.availableWidth * widthPercent;
  }

  /// 获取最大单元格高度
  double _getMaxCellHeight(PDFContext context) {
    return _config.rowHeight ?? 50.0;
  }

  /// 从 TableField 中提取列宽配置
  List<double> _extractColumnWidthsFromFields(List<List<TableField>> rows) {
    if (rows.isEmpty) return [];

    final firstRow = rows.first;
    final List<double> widths = [];

    for (final field in firstRow) {
      widths.add(field.getEffectiveWidthPercent());
    }

    // 确保总宽度为1.0
    final totalWidth = widths.fold(0.0, (sum, width) => sum + width);
    if (totalWidth > 0) {
      for (int i = 0; i < widths.length; i++) {
        widths[i] = widths[i] / totalWidth;
      }
    }

    return widths;
  }

  /// 对表格数据进行排序（支持TableField）
  Map<String, dynamic> _sortTableDataWithFields(
    List<String> headers,
    List<List<TableField>> rows,
  ) {
    if (rows.isEmpty) {
      return {'headers': headers, 'rows': rows};
    }

    // 从第一行的 TableField 中获取排序信息
    final firstRow = rows.first;
    final List<TableField> headerFields = [];

    for (int i = 0; i < headers.length && i < firstRow.length; i++) {
      final headerName = headers[i];
      final sort = firstRow[i].sort; // 使用 TableField 的 sort 属性
      headerFields.add(
        TableField(label: headerName, value: headerName, sort: sort),
      );
    }

    // 按 sort 值升序排列，null值排在最后，相同 sort 值保持原顺序
    final sortedHeaderFields = List<TableField>.from(headerFields);
    sortedHeaderFields.sort((a, b) {
      // null值排在最后
      if (a.sort == null && b.sort == null) return 0;
      if (a.sort == null) return 1; // a排在后面
      if (b.sort == null) return -1; // b排在后面

      // 都不为null时，按升序排列（数值越小越靠前）
      return a.sort!.compareTo(b.sort!);
    });

    // 创建列索引映射
    final Map<String, int> originalIndexMap = {};
    for (int i = 0; i < headers.length; i++) {
      originalIndexMap[headers[i]] = i;
    }

    // 生成新的列顺序
    final List<int> newColumnOrder = [];
    final List<String> sortedHeaders = [];
    for (final headerField in sortedHeaderFields) {
      final originalIndex = originalIndexMap[headerField.value];
      if (originalIndex != null) {
        newColumnOrder.add(originalIndex);
        sortedHeaders.add(headerField.label);
      }
    }

    // 重新排列数据行
    final List<List<TableField>> sortedRows = rows.map((row) {
      final List<TableField> sortedRow = [];
      for (final columnIndex in newColumnOrder) {
        if (columnIndex < row.length) {
          sortedRow.add(row[columnIndex]);
        } else {
          sortedRow.add(TableField(label: '', value: '', sort: null));
        }
      }
      return sortedRow;
    }).toList();

    return {'headers': sortedHeaders, 'rows': sortedRows};
  }
}
