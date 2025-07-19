/// 数据适配器相关常量定义
///
/// 提供类型安全的枚举常量和数据类，替代硬编码字符串
/// 支持动态的数据键和模块ID配置
library;

/// PDF模块类型枚举
///
/// 定义PDF中支持的模块类型
enum ModuleType {
  /// 标题模块
  title('title'),

  /// 主表模块
  mainTable('main_table'),

  /// 子表模块
  subTable('sub_table'),

  /// Logo模块
  logo('logo'),

  /// 审批记录模块
  approval('approval'),

  /// 页脚模块
  footer('footer');

  const ModuleType(this.value);

  /// 字符串值
  final String value;

  /// 从字符串值获取枚举
  static ModuleType? fromString(String value) {
    for (final type in ModuleType.values) {
      if (type.value == value) return type;
    }
    return null;
  }

  /// 获取所有模块类型的字符串值
  static List<String> get allValues =>
      ModuleType.values.map((e) => e.value).toList();
}
