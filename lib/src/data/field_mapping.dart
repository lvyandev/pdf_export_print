/// 字段映射配置数据模型
class FieldMapping {
  /// 源字段名
  final String sourceField;

  /// 显示标签
  final String displayLabel;

  /// 格式化器
  final String? formatter;

  FieldMapping({
    required this.sourceField,
    required this.displayLabel,
    this.formatter,
  });
}
