import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/themes/themes.dart';
import 'package:pdf_export_print/src/configs/common_table_config.dart';

/// 通用表格组件
class CommonTableWidget {
  final CommonTableConfig _config;

  const CommonTableWidget({required CommonTableConfig config})
    : _config = config;

  /// 构建表格
  pw.Widget buildTable(
    List<String> headers,
    List<List<String>> rows,
    ModuleData data,
    PDFContext context,
  ) {
    // 处理表头排序
    final sortedData = _sortTableData(headers, rows, data);
    final List<String> sortedHeaders = sortedData['headers'] as List<String>;
    final List<List<String>> sortedRows =
        sortedData['rows'] as List<List<String>>;

    // 获取列宽配置
    final columnWidths =
        data.getValue<List<dynamic>>('columnWidths') as List<double>?;

    return pw.Table(
      columnWidths: _buildColumnWidths(sortedHeaders.length, columnWidths),
      border: _config.showBorder ? _createTableBorder(context) : null,
      children: [
        // 表头行
        _buildHeaderRow(sortedHeaders, context),
        // 数据行
        ...sortedRows.map(
          (row) => _buildDataRow(row, sortedHeaders.length, context),
        ),
      ],
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
      height: _config.headerHeight,
      child: pw.Align(
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
      ),
    );
  }

  /// 构建数据行
  pw.TableRow _buildDataRow(
    List<String> row,
    int expectedColumns,
    PDFContext context,
  ) {
    // 确保行数据长度与列数匹配
    final List<String> paddedRow = List<String>.from(row);
    while (paddedRow.length < expectedColumns) {
      paddedRow.add('');
    }
    if (paddedRow.length > expectedColumns) {
      paddedRow.removeRange(expectedColumns, paddedRow.length);
    }

    return pw.TableRow(
      children: paddedRow.map((cell) => _buildDataCell(cell, context)).toList(),
    );
  }

  /// 构建数据单元格
  pw.Widget _buildDataCell(String cell, PDFContext context) {
    return pw.Container(
      padding: _config.cellPadding,
      child: pw.Align(
        alignment: _config.dataAlignment,
        child: pw.Text(
          cell,
          style: pw.TextStyle(
            fontSize: _config.dataFontSize ?? context.theme.defaultFontSize,
            color: _config.dataColor ?? context.theme.primaryColor,
            font: DefaultTheme.getFontByWeight(400),
          ),
        ),
      ),
    );
  }

  /// 对表格数据进行排序
  Map<String, dynamic> _sortTableData(
    List<String> headers,
    List<List<String>> rows,
    ModuleData data,
  ) {
    // 从 ModuleData 中获取表头排序设置
    final headerSorts =
        data.getValue<Map<String, dynamic>>('headerSorts')
            as Map<String, int>? ??
        <String, int>{};

    // 创建表头字段对象列表
    final List<TableField> headerFields = [];
    for (int i = 0; i < headers.length; i++) {
      final headerName = headers[i];
      final sort = headerSorts[headerName] ?? 0;
      headerFields.add(
        TableField(label: headerName, value: headerName, sort: sort),
      );
    }

    // 按 sort 值降序排列，相同 sort 值保持原顺序
    final sortedHeaderFields = List<TableField>.from(headerFields);
    sortedHeaderFields.sort((a, b) {
      if (a.sort != b.sort) {
        return b.sort.compareTo(a.sort); // 降序：sort 值大的在前
      }
      return 0; // 相同 sort 值保持原顺序
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
      final originalIndex =
          originalIndexMap[headerField.value]; // 使用 value 作为 key
      if (originalIndex != null) {
        newColumnOrder.add(originalIndex);
        sortedHeaders.add(headerField.label);
      }
    }

    // 重新排列数据行
    final List<List<String>> sortedRows = rows.map((row) {
      final List<String> sortedRow = [];
      for (final columnIndex in newColumnOrder) {
        if (columnIndex < row.length) {
          sortedRow.add(row[columnIndex]);
        } else {
          sortedRow.add('');
        }
      }
      return sortedRow;
    }).toList();

    return {'headers': sortedHeaders, 'rows': sortedRows};
  }
}
