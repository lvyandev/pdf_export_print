import 'package:pdf_export_print/src/configs/configs.dart';

/// 工具函数：获取有效的列宽百分比
double getEffectiveWidthPercentUtil(double? widthPercent) {
  if (widthPercent != null) {
    return widthPercent.clamp(0.0, 1.0);
  }
  // 如果没有设置widthPercent，使用默认值
  return 0.33; // 默认33%
}

/// 单元格内容类型枚举
enum CellContentType { text, image }

/// 单元格内容抽象基类
abstract class CellContent {
  String get displayText;
  CellContentType get type;
}

/// 文本内容
class TextContent extends CellContent {
  final String text;

  TextContent(this.text);

  @override
  String get displayText => text;

  @override
  CellContentType get type => CellContentType.text;
}

/// 图片内容
class ImageContent extends CellContent {
  final String imageUrl;
  final String? altText;
  final double? maxHeight;

  ImageContent({required this.imageUrl, this.altText, this.maxHeight});

  @override
  String get displayText => altText ?? '[图片]';

  @override
  CellContentType get type => CellContentType.image;
}

/// 表格字段数据模型
class TableField {
  /// 字段标签
  final String label;

  /// 字段值（保持向后兼容）
  final String value;

  /// 单元格内容（新增：支持多种内容类型）
  final CellContent? content;

  /// 列宽百分比（0.0-1.0，如0.3表示30%）
  final double? widthPercent;

  /// 排序值（数值越小排序越靠前，null值排在最后）
  final int? sort;

  /// 字段样式
  final FieldStyle? style;

  TableField({
    required this.label,
    required this.value,
    this.content,
    this.widthPercent,
    this.sort,
    this.style,
  });

  /// 获取有效的列宽百分比
  double getEffectiveWidthPercent() {
    return getEffectiveWidthPercentUtil(widthPercent);
  }

  /// 获取实际显示内容
  CellContent get effectiveContent => content ?? TextContent(value);

  /// 便捷构造方法：创建文本字段
  factory TableField.text({
    required String label,
    required String value,
    double? widthPercent,
    int? sort,
    FieldStyle? style,
  }) {
    return TableField(
      label: label,
      value: value,
      content: TextContent(value),
      widthPercent: widthPercent,
      sort: sort,
      style: style,
    );
  }

  /// 便捷构造方法：创建图片字段
  factory TableField.image({
    required String label,
    required String imageUrl,
    String? altText,
    double? maxHeight,
    double? widthPercent,
    int? sort,
    FieldStyle? style,
  }) {
    return TableField(
      label: label,
      value: altText ?? '[图片]',
      content: ImageContent(
        imageUrl: imageUrl,
        altText: altText,
        maxHeight: maxHeight,
      ),
      widthPercent: widthPercent,
      sort: sort,
      style: style,
    );
  }
}
