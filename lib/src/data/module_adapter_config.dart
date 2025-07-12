/// 模块适配器配置数据模型
class ModuleAdapterConfig {
  /// 是否必需
  final bool required;

  /// 自定义配置
  final Map<String, dynamic> customConfig;

  ModuleAdapterConfig({
    this.required = false, 
    this.customConfig = const {},
  });
}
