import 'package:pdf_export_print/src/data/data.dart';

/// 标题数据模型
class TitleData extends ModuleData {
  /// 标题列表
  final List<String> titles;

  /// 标题颜色
  final String? color;

  /// 对齐方式
  final String? alignment;

  TitleData({required this.titles, this.color, this.alignment})
    : super(
        moduleType: 'title',
        data: {
          'titles': titles,
          if (color != null) 'color': color,
          if (alignment != null) 'alignment': alignment,
        },
      );

  /// 从Map创建
  factory TitleData.fromMap(Map<String, dynamic> map) {
    final titlesData = map['titles'] as List<dynamic>? ?? [];
    final titles = titlesData.whereType<String>().toList();

    return TitleData(
      titles: titles,
      color: map['color'] as String?,
      alignment: map['alignment'] as String?,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'titles': titles,
      if (color != null) 'color': color,
      if (alignment != null) 'alignment': alignment,
    };
  }
}

/// 标题构建器
class TitleBuilder {
  final List<String> _titles = [];
  String? _color;
  String? _alignment;

  /// 添加标题
  TitleBuilder addTitle(String title) {
    _titles.add(title);
    return this;
  }

  /// 添加多个标题
  TitleBuilder addTitles(List<String> titles) {
    _titles.addAll(titles);
    return this;
  }

  /// 设置颜色
  TitleBuilder setColor(String color) {
    _color = color;
    return this;
  }

  /// 设置对齐方式
  TitleBuilder setAlignment(String alignment) {
    _alignment = alignment;
    return this;
  }

  /// 构建数据
  TitleData build() {
    return TitleData(
      titles: List.from(_titles),
      color: _color,
      alignment: _alignment,
    );
  }

  /// 清空
  TitleBuilder clear() {
    _titles.clear();
    _color = null;
    _alignment = null;
    return this;
  }

  /// 获取标题数量
  int get titleCount => _titles.length;

  /// 获取标题列表
  List<String> get titles => List.unmodifiable(_titles);
}
