/// 模块配置
class ModuleConfig {
  /// 是否启用该模块
  final bool enabled;

  /// 模块优先级
  final int priority;

  /// 自定义设置
  final Map<String, dynamic> customSettings;

  ModuleConfig({
    this.enabled = true,
    this.priority = 0,
    this.customSettings = const {},
  });

  /// 获取自定义设置
  T? getSetting<T>(String key) {
    return customSettings[key] as T?;
  }
}
