/// PDF模块相关常量定义
///
/// 统一管理所有模块的默认值和魔法数字，提高可维护性
library;

/// Logo模块常量
class LogoConstants {
  /// 默认Logo宽度
  static const double defaultWidth = 120.0;

  /// 默认Logo高度
  static const double defaultHeight = 60.0;

  /// 小尺寸Logo宽度
  static const double smallWidth = 50.0;

  /// 小尺寸Logo高度
  static const double smallHeight = 50.0;

  /// 大尺寸Logo宽度
  static const double largeWidth = 150.0;

  /// 大尺寸Logo高度
  static const double largeHeight = 75.0;

  /// 默认底部间距
  static const double defaultBottomSpacing = 15.0;

  /// 默认请求超时时间（秒）
  static const int defaultTimeoutSeconds = 10;

  /// 占位符字体大小
  static const double placeholderFontSize = 12.0;

  /// 占位符边框宽度
  static const double placeholderBorderWidth = 1.0;
}

/// 标题模块常量
class TitleConstants {
  /// 默认字体颜色
  static const String defaultColor = 'red';

  /// 默认对齐方式
  static const String defaultAlignment = 'center';

  /// 默认顶部间距
  static const double defaultTopSpacing = 0.0;

  /// 默认底部间距
  static const double defaultBottomSpacing = 15.0;

  /// 默认标题间距
  static const double defaultTitleSpacing = 5.0;
}

/// 表格模块常量
class TableConstants {
  /// 默认单元格内边距
  static const double defaultCellPadding = 4.0;

  /// 默认表头高度
  static const double defaultHeaderHeight = 25.0;

  /// 默认数据行高度
  static const double defaultRowHeight = 20.0;

  /// 紧凑模式单元格内边距
  static const double compactCellPadding = 2.0;

  /// 紧凑模式表头高度
  static const double compactHeaderHeight = 20.0;

  /// 紧凑模式数据行高度
  static const double compactRowHeight = 18.0;

  /// 大表格模式表头高度
  static const double largeHeaderHeight = 30.0;

  /// 大表格模式数据行高度
  static const double largeRowHeight = 25.0;
}

/// 页面布局常量
class LayoutConstants {
  /// 默认页边距
  static const double defaultMargin = 16.0;

  /// 默认模块间距
  static const double defaultModuleSpacing = 10.0;

  /// 默认字体大小
  static const double defaultFontSize = 12.0;

  /// 小字体大小
  static const double smallFontSize = 10.0;

  /// 大字体大小
  static const double largeFontSize = 14.0;

  /// 标题字体大小
  static const double titleFontSize = 18.0;

  /// 大标题字体大小
  static const double largeTitleFontSize = 20.0;
}
