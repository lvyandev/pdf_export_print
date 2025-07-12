import 'package:pdf_export_print/src/data/data.dart';

/// 主表数据模型（同时支持主表和页脚）
class MainTableData extends ModuleData {
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
    super.moduleType = 'main_table',
    this.fieldsPerRow,
  }) : super(
         data: {
           'fields': fields,
           'showBorder': showBorder,
           'showInnerBorder': showInnerBorder,
           'fieldsPerRow': fieldsPerRow,
         },
       );

  /// 从Map创建
  factory MainTableData.fromMap(Map<String, dynamic> map) {
    final fieldsData = map['fields'] as List<dynamic>? ?? [];
    final fields = fieldsData.whereType<TableField>().toList();

    return MainTableData(
      fields: fields,
      showBorder: map['showBorder'] as bool? ?? true,
      showInnerBorder: map['showInnerBorder'] as bool? ?? false,
      moduleType: map['moduleType'] as String? ?? 'main_table',
      fieldsPerRow: map['fieldsPerRow'] as int?,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'fields': fields,
      'showBorder': showBorder,
      'showInnerBorder': showInnerBorder,
      'fieldsPerRow': fieldsPerRow,
    };
  }

  /// 创建页脚数据
  factory MainTableData.forFooter({
    required List<TableField> fields,
    bool showBorder = true,
    bool showInnerBorder = false,
    int fieldsPerRow = 3,
  }) {
    return MainTableData(
      fields: fields,
      showBorder: showBorder,
      showInnerBorder: showInnerBorder,
      moduleType: 'footer',
      fieldsPerRow: fieldsPerRow,
    );
  }

  /// 创建主表数据
  factory MainTableData.forMainTable({
    required List<TableField> fields,
    bool showBorder = true,
    bool showInnerBorder = false,
  }) {
    return MainTableData(
      fields: fields,
      showBorder: showBorder,
      showInnerBorder: showInnerBorder,
      moduleType: 'main_table',
    );
  }

  /// 检查是否为页脚模块
  bool get isFooter => moduleType == 'footer';

  /// 检查是否为主表模块
  bool get isMainTable => moduleType == 'main_table';
}

/// 主表字段构建器
class MainTableFieldBuilder {
  final List<TableField> _fields = [];

  /// 添加字段
  MainTableFieldBuilder addField(
    String label,
    String value, {
    double? widthPercent,
    int sort = 0,
  }) {
    _fields.add(
      TableField(
        label: label,
        value: value,
        widthPercent: widthPercent,
        sort: sort,
      ),
    );
    return this;
  }

  /// 添加指定宽度字段
  MainTableFieldBuilder addWidthField(
    String label,
    String value,
    double widthPercent, {
    int sort = 0,
  }) {
    return addField(label, value, widthPercent: widthPercent, sort: sort);
  }

  /// 添加全宽字段
  MainTableFieldBuilder addFullWidthField(
    String label,
    String value, {
    int sort = 0,
  }) {
    return addField(label, value, widthPercent: 1.0, sort: sort);
  }

  /// 构建主表数据
  MainTableData build({bool showBorder = true, bool showInnerBorder = false}) {
    return MainTableData.forMainTable(
      fields: List.from(_fields),
      showBorder: showBorder,
      showInnerBorder: showInnerBorder,
    );
  }

  /// 构建页脚数据
  MainTableData buildFooter({
    bool showBorder = true,
    bool showInnerBorder = false,
    int fieldsPerRow = 3,
  }) {
    return MainTableData.forFooter(
      fields: List.from(_fields),
      showBorder: showBorder,
      showInnerBorder: showInnerBorder,
      fieldsPerRow: fieldsPerRow,
    );
  }

  /// 清空字段
  MainTableFieldBuilder clear() {
    _fields.clear();
    return this;
  }

  /// 获取字段数量
  int get fieldCount => _fields.length;

  /// 获取字段列表
  List<TableField> get fields => List.unmodifiable(_fields);
}
