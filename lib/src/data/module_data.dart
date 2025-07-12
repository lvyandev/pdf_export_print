/// 模块数据基类
class ModuleData {
  /// 模块类型
  final String moduleType;

  /// 数据内容
  final Map<String, dynamic> data;

  /// 元数据
  final Map<String, dynamic> metadata;

  ModuleData({
    required this.moduleType,
    required this.data,
    this.metadata = const {},
  });

  /// 获取数据字段
  T? getValue<T>(String key) {
    return data[key] as T?;
  }

  /// 获取元数据字段
  T? getMetadata<T>(String key) {
    return metadata[key] as T?;
  }
}
