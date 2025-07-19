import 'package:pdf_export_print/src/constants/constants.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/table_field.dart';

/// 子表数据模型（同时支持子表和审批流）
///
/// 继承自 ModuleDescriptor，提供强类型的子表数据结构
class SubTableData extends ModuleDescriptor {
  /// 表格数据行列表（每行是 TableField 列表）
  final List<List<TableField>> tableRows;

  /// 表头列表
  final List<String> headers;

  /// 表格列配置
  final Map<String, dynamic>? columnConfig;

  /// 标题
  final String? title;

  /// 检查是否为空
  bool get isEmpty => tableRows.isEmpty;

  /// 获取原始行数据（向后兼容）
  List<Map<String, dynamic>> get rows {
    return tableRows.map((row) {
      final Map<String, dynamic> rowMap = {};
      for (int i = 0; i < row.length && i < headers.length; i++) {
        rowMap[headers[i]] = row[i].value;
      }
      return rowMap;
    }).toList();
  }

  SubTableData({
    required this.tableRows,
    required this.headers,
    this.columnConfig,
    this.title,
    String? moduleId,
    ModuleType moduleType = ModuleType.subTable,
  }) : super(
         moduleType,
         moduleId ??
             (moduleType == ModuleType.approval ? 'approval' : 'sub_table'),
         {
           'tableRows': tableRows,
           'headers': headers,
           if (columnConfig != null) 'columnConfig': columnConfig,
           if (title != null) 'title': title,
         },
       );

  /// 从原始行数据创建 SubTableData（私有方法）
  factory SubTableData._fromRawRows(
    List<Map<String, dynamic>> rawRows, {
    Map<String, dynamic>? columnConfig,
    String? title,
    String? moduleId,
    ModuleType moduleType = ModuleType.subTable,
  }) {
    if (rawRows.isEmpty) {
      return SubTableData(
        tableRows: [],
        headers: [],
        columnConfig: columnConfig,
        title: title,
        moduleId: moduleId,
        moduleType: moduleType,
      );
    }

    // 从第一行提取表头
    final headers = rawRows.first.keys.toList();

    // 将每行数据转换为 TableField 列表
    final List<List<TableField>> tableRows = rawRows.map((rowMap) {
      return headers.map((header) {
        final rawValue = rowMap[header];

        // 智能解析不同类型的数据
        if (rawValue is Map<String, dynamic>) {
          // 如果是复杂对象（如图片信息），创建带有完整信息的 TableField
          final String displayValue =
              rawValue['value']?.toString() ??
              rawValue['url']?.toString() ??
              rawValue['imageUrl']?.toString() ??
              '';

          // 检查是否是图片类型
          if (rawValue.containsKey('imageUrl') || rawValue.containsKey('url')) {
            return TableField(
              label: header,
              value: displayValue,
              content: ImageContent(
                imageUrl:
                    rawValue['imageUrl']?.toString() ??
                    rawValue['url']?.toString() ??
                    '',
                altText: rawValue['altText']?.toString(),
                maxHeight: rawValue['maxHeight'] as double?,
              ),
              widthPercent: rawValue['widthPercent'] as double?,
              sort: rawValue['sort'] as int? ?? 0,
            );
          } else {
            // 复杂文本对象
            return TableField(
              label: header,
              value: displayValue,
              content: TextContent(displayValue),
              widthPercent: rawValue['widthPercent'] as double?,
              sort: rawValue['sort'] as int? ?? 0,
            );
          }
        } else {
          // 简单值，创建基本的 TableField
          return TableField(
            label: header,
            value: rawValue?.toString() ?? '',
            sort: 0,
          );
        }
      }).toList();
    }).toList();

    return SubTableData(
      tableRows: tableRows,
      headers: headers,
      columnConfig: columnConfig,
      title: title,
      moduleId: moduleId,
      moduleType: moduleType,
    );
  }

  /// 创建子表数据
  factory SubTableData.forSubTable({
    required List<Map<String, dynamic>> rows,
    Map<String, dynamic>? columnConfig,
    String? moduleId,
  }) {
    return SubTableData._fromRawRows(
      rows,
      columnConfig: columnConfig,
      moduleId: moduleId,
      moduleType: ModuleType.subTable,
    );
  }

  /// 创建审批流数据
  factory SubTableData.forApproval({
    required List<Map<String, dynamic>> rows,
    Map<String, dynamic>? columnConfig,
    String? moduleId,
  }) {
    return SubTableData._fromRawRows(
      rows,
      columnConfig: columnConfig,
      moduleId: moduleId,
      moduleType: ModuleType.approval,
    );
  }

  /// 从List创建
  factory SubTableData.fromList(
    List<dynamic> list, {
    String? moduleId,
    ModuleType moduleType = ModuleType.subTable,
  }) {
    final rows = list.whereType<Map<String, dynamic>>().toList();
    return SubTableData._fromRawRows(
      rows,
      moduleId: moduleId,
      moduleType: moduleType,
    );
  }

  /// 从 ModuleDescriptor 创建
  factory SubTableData.fromDescriptor(ModuleDescriptor descriptor) {
    if (descriptor.type != ModuleType.subTable &&
        descriptor.type != ModuleType.approval) {
      throw ArgumentError('ModuleDescriptor type must be subTable or approval');
    }

    if (descriptor.data is List<dynamic>) {
      return SubTableData.fromList(
        descriptor.data as List<dynamic>,
        moduleId: descriptor.moduleId,
        moduleType: descriptor.type,
      );
    }

    if (descriptor.data is Map<String, dynamic>) {
      final map = descriptor.data as Map<String, dynamic>;
      final rowsData = map['rows'] as List<dynamic>? ?? [];
      final rows = rowsData.whereType<Map<String, dynamic>>().toList();

      return SubTableData._fromRawRows(
        rows,
        columnConfig: map['columnConfig'] as Map<String, dynamic>?,
        title: map['title'] as String?,
        moduleId: descriptor.moduleId,
        moduleType: descriptor.type,
      );
    }

    throw ArgumentError('Invalid data format for SubTableData');
  }
}
