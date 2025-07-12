import 'package:pdf_export_print/src/configs/configs.dart';

/// 工具函数：获取有效的列宽百分比
double getEffectiveWidthPercentUtil(double? widthPercent) {
  if (widthPercent != null) {
    return widthPercent.clamp(0.0, 1.0);
  }
  // 如果没有设置widthPercent，使用默认值
  return 0.33; // 默认1/3宽度
}

/// 表格字段数据模型
class TableField {
  /// 字段标签
  final String label;

  /// 字段值
  final String value;

  /// 列宽百分比（0.0-1.0，如0.3表示30%）
  final double? widthPercent;

  /// 排序值（数值越大排序越靠前）
  final int sort;

  /// 字段样式
  final FieldStyle? style;

  TableField({
    required this.label,
    required this.value,
    this.widthPercent,
    this.sort = 0,
    this.style,
  });

  /// 获取有效的列宽百分比
  double getEffectiveWidthPercent() {
    return getEffectiveWidthPercentUtil(widthPercent);
  }
}
