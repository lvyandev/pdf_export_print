/// 模块配置基类
///
/// 所有模块配置类的基类，提供通用属性和方法
class BaseModuleConfig {
  /// 是否启用该模块
  final bool enabled;

  /// 模块优先级，数值越小优先级越高
  final int priority;

  /// 是否必需
  final bool required;

  /// 构造函数
  ///
  /// ### 参数
  /// - [enabled] 是否启用该模块
  /// - [priority] 模块优先级，数值越小优先级越高
  /// - [required] 是否必需
  const BaseModuleConfig({
    this.enabled = true,
    this.priority = 0,
    this.required = false,
  });

  /// 创建副本
  ///
  /// ### 参数
  /// - [enabled] 是否启用该模块
  /// - [priority] 模块优先级
  /// - [required] 是否必需
  /// ### 返回值
  /// 返回新的配置实例
  ///
  /// 注意：子类应该重写此方法以返回正确的子类类型
  BaseModuleConfig copyWith({bool? enabled, int? priority, bool? required}) {
    return BaseModuleConfig(
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      required: required ?? this.required,
    );
  }

  @override
  String toString() {
    return 'BaseModuleConfig(enabled: $enabled, priority: $priority, required: $required)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModuleConfig &&
        other.enabled == enabled &&
        other.priority == priority &&
        other.required == required;
  }

  @override
  int get hashCode => Object.hash(enabled, priority, required);
}
