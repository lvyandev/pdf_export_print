/// 数据适配器相关常量定义
///
/// 提供类型安全的枚举常量，替代硬编码字符串
library;

/// 原始数据键名枚举
///
/// 定义从业务系统传入的原始数据中的键名
enum DataKeys {
  /// 标题数据键
  titles('titles'),

  /// 主表数据键
  mainData('mainData'),

  /// 详情/子表数据键
  details('details'),

  /// Logo URL数据键
  logoUrl('logoUrl'),

  /// 审批记录数据键
  approvals('approvals'),

  /// 页脚数据键
  footerData('footerData');

  const DataKeys(this.value);

  /// 字符串值
  final String value;

  /// 从字符串值获取枚举
  static DataKeys? fromString(String value) {
    for (final key in DataKeys.values) {
      if (key.value == value) return key;
    }
    return null;
  }
}

/// PDF模块类型枚举
///
/// 定义PDF中支持的模块类型
enum ModuleTypes {
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

  const ModuleTypes(this.value);

  /// 字符串值
  final String value;

  /// 从字符串值获取枚举
  static ModuleTypes? fromString(String value) {
    for (final type in ModuleTypes.values) {
      if (type.value == value) return type;
    }
    return null;
  }

  /// 获取所有模块类型的字符串值
  static List<String> get allValues =>
      ModuleTypes.values.map((e) => e.value).toList();
}

/// 模块数据键枚举
///
/// 定义模块内部使用的通用数据键
enum ModuleDataKeys {
  /// 字段列表
  fields('fields'),

  /// 表头列表
  headers('headers'),

  /// 数据行列表
  rows('rows'),

  /// 标题列表
  titles('titles'),

  /// 审批记录列表
  approvals('approvals'),

  /// Logo URL
  logoUrl('logoUrl'),

  /// 宽度
  width('width'),

  /// 高度
  height('height'),

  /// 标题
  title('title'),

  /// 显示边框
  showBorder('showBorder'),

  /// 列宽配置
  columnWidths('columnWidths'),

  /// 表头排序配置
  headerSorts('headerSorts');

  const ModuleDataKeys(this.value);

  /// 字符串值
  final String value;

  /// 从字符串值获取枚举
  static ModuleDataKeys? fromString(String value) {
    for (final key in ModuleDataKeys.values) {
      if (key.value == value) return key;
    }
    return null;
  }
}
