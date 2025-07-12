import 'package:pdf_export_print/src/data/data.dart';

/// 子表数据模型
class SubTableData extends ModuleData {
  /// 表头列表
  final List<String> headers;
  
  /// 表格行数据（每行是一个TableField列表）
  final List<List<TableField>> rows;
  
  /// 表格标题
  final String? title;
  
  /// 是否显示边框
  final bool showBorder;

  SubTableData({
    required this.headers,
    required this.rows,
    this.title,
    this.showBorder = true,
  }) : super(
        moduleType: 'sub_table',
        data: {
          'headers': headers,
          'rows': rows,
          if (title != null) 'title': title,
          'showBorder': showBorder,
        },
      );

  /// 从Map创建
  factory SubTableData.fromMap(Map<String, dynamic> map) {
    final headersData = map['headers'] as List<dynamic>? ?? [];
    final headers = headersData.map((h) => h.toString()).toList();
    
    final rowsData = map['rows'] as List<dynamic>? ?? [];
    final rows = rowsData.map((row) {
      if (row is List) {
        return row.whereType<TableField>().toList();
      }
      return <TableField>[];
    }).toList();

    return SubTableData(
      headers: headers,
      rows: rows,
      title: map['title'] as String?,
      showBorder: map['showBorder'] as bool? ?? true,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'headers': headers,
      'rows': rows,
      if (title != null) 'title': title,
      'showBorder': showBorder,
    };
  }
  
  /// 获取指定行的数据
  List<TableField>? getRow(int index) {
    if (index >= 0 && index < rows.length) {
      return rows[index];
    }
    return null;
  }
  
  /// 获取行数
  int get rowCount => rows.length;
  
  /// 获取列数
  int get columnCount => headers.length;
  
  /// 检查是否为空表
  bool get isEmpty => headers.isEmpty || rows.isEmpty;
}

/// 子表字段构建器
class SubTableFieldBuilder {
  final List<String> _headers = [];
  final List<List<TableField>> _rows = [];

  /// 设置表头
  SubTableFieldBuilder setHeaders(List<String> headers) {
    _headers.clear();
    _headers.addAll(headers);
    return this;
  }
  
  /// 添加表头
  SubTableFieldBuilder addHeader(String header) {
    _headers.add(header);
    return this;
  }

  /// 添加行数据
  SubTableFieldBuilder addRow(List<TableField> row) {
    _rows.add(List.from(row));
    return this;
  }
  
  /// 添加简单行数据（自动创建TableField）
  SubTableFieldBuilder addSimpleRow(List<String> values, {List<double>? widthPercents}) {
    final row = <TableField>[];
    for (int i = 0; i < values.length; i++) {
      final value = values[i];
      final widthPercent = widthPercents != null && i < widthPercents.length 
          ? widthPercents[i] 
          : null;
      
      row.add(TableField(
        label: i < _headers.length ? _headers[i] : 'Column $i',
        value: value,
        widthPercent: widthPercent,
      ));
    }
    _rows.add(row);
    return this;
  }

  /// 构建数据
  SubTableData build({String? title, bool showBorder = true}) {
    return SubTableData(
      headers: List.from(_headers),
      rows: _rows.map((row) => List<TableField>.from(row)).toList(),
      title: title,
      showBorder: showBorder,
    );
  }

  /// 清空数据
  SubTableFieldBuilder clear() {
    _headers.clear();
    _rows.clear();
    return this;
  }

  /// 获取当前行数
  int get rowCount => _rows.length;
  
  /// 获取当前列数
  int get columnCount => _headers.length;
}
