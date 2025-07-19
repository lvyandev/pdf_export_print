import 'package:pdf_export_print/src/constants/adapter_constants.dart';
import 'package:pdf_export_print/src/constants/constants.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';

/// 主表数据模型（同时支持主表和页脚）
///
/// 继承自 ModuleDescriptor，提供强类型的主表数据结构
class MainTableData extends ModuleDescriptor {
  /// 表格字段列表
  final List<TableField> fields;

  /// 是否显示边框
  final bool showBorder;

  /// 是否显示内边框
  final bool showInnerBorder;

  /// 每行字段数（主要用于页脚）
  final int? fieldsPerRow;

  MainTableData({
    required this.fields,
    this.showBorder = true,
    this.showInnerBorder = false,
    this.fieldsPerRow,
    String? moduleId,
    ModuleType moduleType = ModuleType.mainTable,
  }) : super(moduleType, moduleId ?? moduleType.value, {
         'fields': fields,
         'showBorder': showBorder,
         'showInnerBorder': showInnerBorder,
         if (fieldsPerRow != null) 'fieldsPerRow': fieldsPerRow,
       });

  /// 创建主表数据
  factory MainTableData.forMainTable({
    required List<TableField> fields,
    bool showBorder = true,
    bool showInnerBorder = false,
    String? moduleId,
  }) {
    return MainTableData(
      fields: fields,
      showBorder: showBorder,
      showInnerBorder: showInnerBorder,
      moduleId: moduleId,
      moduleType: ModuleType.mainTable,
    );
  }

  /// 创建页脚数据
  factory MainTableData.forFooter({
    required List<TableField> fields,
    bool showBorder = true,
    bool showInnerBorder = false,
    int fieldsPerRow = 3,
    String? moduleId,
  }) {
    return MainTableData(
      fields: fields,
      showBorder: showBorder,
      showInnerBorder: showInnerBorder,
      fieldsPerRow: fieldsPerRow,
      moduleId: moduleId,
      moduleType: ModuleType.footer,
    );
  }

  /// 从Map创建
  factory MainTableData.fromMap(
    Map<String, dynamic> map, {
    String? moduleId,
    ModuleType moduleType = ModuleType.mainTable,
  }) {
    final fieldsData = map['fields'] as List<dynamic>? ?? [];
    final fields = fieldsData
        .whereType<Map<String, dynamic>>()
        .map(
          (fieldMap) => TableField(
            label: fieldMap['label'] as String? ?? '',
            value: fieldMap['value'] as String? ?? '',
            widthPercent: fieldMap['widthPercent'] as double?,
            sort: fieldMap['sort'] as int? ?? 0,
          ),
        )
        .toList();

    return MainTableData(
      fields: fields,
      showBorder: map['showBorder'] as bool? ?? true,
      showInnerBorder: map['showInnerBorder'] as bool? ?? false,
      fieldsPerRow: map['fieldsPerRow'] as int?,
      moduleId: moduleId,
      moduleType: moduleType,
    );
  }

  /// 从 ModuleDescriptor 创建
  factory MainTableData.fromDescriptor(ModuleDescriptor descriptor) {
    if (descriptor.type != ModuleType.mainTable &&
        descriptor.type != ModuleType.footer) {
      throw ArgumentError('ModuleDescriptor type must be mainTable or footer');
    }

    if (descriptor.data is Map<String, dynamic>) {
      return MainTableData.fromMap(
        descriptor.data as Map<String, dynamic>,
        moduleId: descriptor.moduleId,
        moduleType: descriptor.type,
      );
    }

    throw ArgumentError('Invalid data format for MainTableData');
  }
}
