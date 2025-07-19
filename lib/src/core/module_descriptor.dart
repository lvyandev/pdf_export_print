import 'package:pdf_export_print/src/constants/constants.dart';

/// 模块描述符
///
/// 描述一个完整的模块配置，包含模块类型、模块ID和数据源
class ModuleDescriptor {
  /// 模块类型
  final ModuleType type;

  /// 模块ID（用于区分同一类型的不同实例）
  final String moduleId;

  /// 数据源
  final dynamic data;

  const ModuleDescriptor(this.type, this.moduleId, this.data);

  /// 创建带有默认 moduleId 的模块描述符
  factory ModuleDescriptor.withDefaultId(ModuleType type, {dynamic data}) {
    return ModuleDescriptor(type, type.value, data);
  }

  /// 复制并修改模块描述符
  ModuleDescriptor copyWith({
    ModuleType? type,
    String? moduleId,
    dynamic data,
  }) {
    return ModuleDescriptor(
      type ?? this.type,
      moduleId ?? this.moduleId,
      data ?? this.data,
    );
  }

  /// 预定义的模块描述符（六个默认模块）
  static const logo = ModuleDescriptor(ModuleType.logo, 'logo', null);

  static const title = ModuleDescriptor(ModuleType.title, 'title', null);

  static const mainTable = ModuleDescriptor(
    ModuleType.mainTable,
    'main_table',
    null,
  );

  static const subTable = ModuleDescriptor(
    ModuleType.subTable,
    'sub_table',
    null,
  );

  static const approval = ModuleDescriptor(
    ModuleType.approval,
    'approval',
    null,
  );

  static const footer = ModuleDescriptor(ModuleType.footer, 'footer', null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleDescriptor &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          moduleId == other.moduleId &&
          data == other.data;

  @override
  int get hashCode => type.hashCode ^ moduleId.hashCode ^ data.hashCode;

  @override
  String toString() => 'ModuleDescriptor($type, $moduleId, $data)';
}
