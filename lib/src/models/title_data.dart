import 'package:pdf_export_print/src/constants/constants.dart';
import 'package:pdf_export_print/src/core/core.dart';

/// 标题数据模型
///
/// 继承自 ModuleDescriptor，提供强类型的标题数据结构
class TitleData extends ModuleDescriptor {
  /// 标题列表
  final List<String> titles;

  /// 标题颜色
  final String? color;

  /// 对齐方式
  final String? alignment;

  TitleData({
    required this.titles,
    this.color,
    this.alignment,
    String? moduleId,
  }) : super(ModuleType.title, moduleId ?? 'title', {
         'titles': titles,
         if (color != null) 'color': color,
         if (alignment != null) 'alignment': alignment,
       });

  /// 从Map创建
  factory TitleData.fromMap(Map<String, dynamic> map, {String? moduleId}) {
    final titlesData = map['titles'] as List<dynamic>? ?? [];
    final titles = titlesData.whereType<String>().toList();

    return TitleData(
      titles: titles,
      color: map['color'] as String?,
      alignment: map['alignment'] as String?,
      moduleId: moduleId,
    );
  }

  /// 从 ModuleDescriptor 创建
  factory TitleData.fromDescriptor(ModuleDescriptor descriptor) {
    if (descriptor.type != ModuleType.title) {
      throw ArgumentError('ModuleDescriptor type must be title');
    }

    if (descriptor.data is Map<String, dynamic>) {
      return TitleData.fromMap(
        descriptor.data as Map<String, dynamic>,
        moduleId: descriptor.moduleId,
      );
    }

    throw ArgumentError('Invalid data format for TitleData');
  }
}
