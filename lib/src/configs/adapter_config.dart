import 'dart:developer';

import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/constants/adapter_constants.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/data/table_field.dart';

/// 字段标签配置类
///
/// 管理字段键名到显示标签的映射关系，支持全局映射和模块特定映射
class FieldLabelConfig {
  /// 全局字段标签映射
  final Map<String, String> _labelMappings;

  /// 模块特定字段标签映射
  final Map<String, Map<String, String>> _moduleMappings;

  /// 私有构造函数
  const FieldLabelConfig._(this._labelMappings, this._moduleMappings);

  /// 创建默认配置（空映射）
  ///
  /// 库级别不提供具体的字段映射，由业务项目自定义
  factory FieldLabelConfig.defaultConfig() {
    return FieldLabelConfig._(
      const <String, String>{},
      const <String, Map<String, String>>{},
    );
  }

  /// 创建自定义配置（扁平化映射，向后兼容）
  factory FieldLabelConfig.custom(Map<String, String> customMappings) {
    return FieldLabelConfig._(
      Map<String, String>.from(customMappings),
      const <String, Map<String, String>>{},
    );
  }

  /// 创建增强配置（支持嵌套Map结构）
  ///
  /// ### 参数
  /// - [globalMappings] 全局字段映射，格式：`{'fieldKey': 'label'}`
  /// - [moduleMappings] 模块特定映射，格式：`{'moduleId': {'fieldKey': 'label'}}`
  ///
  /// ### 示例
  /// ```dart
  /// final config = FieldLabelConfig.enhanced(
  ///   globalMappings: {
  ///     'name': '姓名',
  ///     'age': '年龄',
  ///   },
  ///   moduleMappings: {
  ///     'monthPlanDetails': {
  ///       'docNo': '详情编号',
  ///       'remarks': '详情备注',
  ///     },
  ///     'testDetails': {
  ///       'docNo': '测试编号',
  ///       'remarks': '测试备注',
  ///     },
  ///   },
  /// );
  /// ```
  factory FieldLabelConfig.enhanced({
    Map<String, String> globalMappings = const {},
    Map<String, Map<String, String>> moduleMappings = const {},
  }) {
    return FieldLabelConfig._(
      Map<String, String>.from(globalMappings),
      Map<String, Map<String, String>>.from(
        moduleMappings.map(
          (key, value) => MapEntry(key, Map<String, String>.from(value)),
        ),
      ),
    );
  }

  /// 获取字段显示标签（向后兼容）
  String getLabel(String fieldKey) {
    return _getLabelWithContext(fieldKey, null);
  }

  /// 获取字段显示标签（支持模块上下文）
  ///
  /// ### 参数
  /// - [fieldKey] 字段键名
  /// - [moduleId] 模块ID，用于查找模块特定映射
  ///
  /// ### 查找优先级
  /// 1. 模块特定映射：`moduleMappings[moduleId][fieldKey]`
  /// 2. 全局映射：`globalMappings[fieldKey]`
  /// 3. 原始字段键：`fieldKey`
  String getLabelWithModule(String fieldKey, String moduleId) {
    return _getLabelWithContext(fieldKey, moduleId);
  }

  /// 内部方法：根据上下文获取标签
  String _getLabelWithContext(String fieldKey, String? moduleId) {
    // 优先查找模块特定映射
    if (moduleId != null && _moduleMappings.containsKey(moduleId)) {
      final moduleMapping = _moduleMappings[moduleId]!;
      if (moduleMapping.containsKey(fieldKey)) {
        return moduleMapping[fieldKey]!;
      }
    }

    // 回退到全局映射
    return _labelMappings[fieldKey] ?? fieldKey;
  }

  /// 通过字符串键获取标签（保持兼容性）
  String getLabelByString(String fieldKey) {
    return getLabel(fieldKey);
  }

  /// 通过字符串键获取标签（支持模块上下文）
  String getLabelByStringWithModule(String fieldKey, String moduleId) {
    return getLabelWithModule(fieldKey, moduleId);
  }

  /// 检查是否包含字段映射（全局或模块特定）
  bool hasMapping(String fieldKey, {String? moduleId}) {
    if (moduleId != null && _moduleMappings.containsKey(moduleId)) {
      final moduleMapping = _moduleMappings[moduleId]!;
      if (moduleMapping.containsKey(fieldKey)) {
        return true;
      }
    }
    return _labelMappings.containsKey(fieldKey);
  }

  /// 获取所有全局映射
  Map<String, String> get allMappings => Map.unmodifiable(_labelMappings);

  /// 获取所有模块映射
  Map<String, Map<String, String>> get allModuleMappings => Map.unmodifiable(
    _moduleMappings.map((key, value) => MapEntry(key, Map.unmodifiable(value))),
  );
}

/// 字段配置类
///
/// 定义字段的详细配置信息（不包含标签，标签由FieldLabelConfig管理）
class FieldConfig {
  /// 字段键
  final String fieldKey;

  /// 列宽百分比（0.0-1.0，如0.3表示30%）
  final double? widthPercent;

  /// 排序权重（数值越小排序越靠前，null值排在最后）
  final int? sort;

  const FieldConfig({required this.fieldKey, this.widthPercent, this.sort});

  /// 获取有效的列宽百分比
  double getEffectiveWidthPercent() {
    return getEffectiveWidthPercentUtil(widthPercent);
  }

  /// 创建表格字段（需要外部提供标签）
  TableField toTableField(dynamic value, String label) {
    return TableField(
      label: label,
      value: value?.toString() ?? '',
      widthPercent: widthPercent ?? 0.33,
      sort: sort,
    );
  }
}

/// 适配器模块配置类
///
/// 定义适配器模块的配置信息，支持具体的模块配置类型
class AdapterModuleConfig {
  /// 模块类型
  final ModuleType moduleType;

  /// 字段配置列表
  final List<FieldConfig> fieldConfigs;

  /// 具体的模块配置
  final BaseModuleConfig? moduleConfig;

  const AdapterModuleConfig({
    required this.moduleType,
    this.fieldConfigs = const [],
    this.moduleConfig,
  });

  /// 获取模块是否启用
  bool get enabled => moduleConfig?.enabled ?? true;

  /// 获取模块优先级
  int get priority => moduleConfig?.priority ?? 0;

  /// 获取模块是否必需
  bool get required => moduleConfig?.required ?? false;

  /// 获取字段配置
  FieldConfig? getFieldConfig(String fieldKey) {
    for (final config in fieldConfigs) {
      if (config.fieldKey == fieldKey) return config;
    }
    return null;
  }

  /// 获取具体类型的模块配置
  ///
  /// ### 参数
  /// - [T] 期望的配置类型，必须继承自 BaseModuleConfig
  /// ### 返回值
  /// 返回指定类型的配置实例，如果类型不匹配则返回 null
  /// ### 异常
  /// 不会抛出类型转换异常，类型不匹配时返回 null
  T? getTypedModuleConfig<T extends BaseModuleConfig>() {
    if (moduleConfig is T) {
      return moduleConfig as T;
    } else if (moduleConfig != null) {
      log('模块配置类型不匹配，期望 ${T.toString()}，但实际类型为 ${moduleConfig.runtimeType}');
    }
    return null;
  }

  /// 获取列宽配置（从FieldConfig中提取，确保类型安全）
  ///
  /// 这是获取列宽配置的标准方法，只从FieldConfig中获取配置，
  /// 确保类型安全和配置的一致性。
  ///
  /// ### 返回值
  /// 返回字段键名到列宽百分比的映射，键为fieldKey，值为widthPercent
  Map<String, double> getColumnWidthsFromFieldConfigs() {
    final columnWidths = <String, double>{};

    for (final fieldConfig in fieldConfigs) {
      if (fieldConfig.widthPercent != null) {
        columnWidths[fieldConfig.fieldKey] = fieldConfig
            .getEffectiveWidthPercent();
      }
    }

    return columnWidths;
  }

  /// 验证列宽配置
  ValidationResult validateColumnWidths() {
    final columnWidths = getColumnWidthsFromFieldConfigs();
    final errors = <String>[];
    final warnings = <String>[];

    if (columnWidths.isEmpty) {
      return ValidationResult.success();
    }

    // 检查百分比范围
    for (final entry in columnWidths.entries) {
      final fieldKey = entry.key;
      final widthPercent = entry.value;

      if (widthPercent < 0.0 || widthPercent > 1.0) {
        errors.add('字段 "$fieldKey" 的列宽百分比 $widthPercent 超出有效范围 [0.0, 1.0]');
      }
    }

    // 检查总宽度
    final totalWidth = columnWidths.values.fold(
      0.0,
      (sum, width) => sum + width,
    );
    if (totalWidth > 1.0) {
      warnings.add('所有列宽百分比总和 $totalWidth 超过 1.0，将自动归一化');
    } else if (totalWidth < 0.8) {
      warnings.add('所有列宽百分比总和 $totalWidth 小于 0.8，可能存在未充分利用的空间');
    }

    // 检查字段配置一致性
    for (final fieldConfig in fieldConfigs) {
      if (fieldConfig.widthPercent != null &&
          !columnWidths.containsKey(fieldConfig.fieldKey)) {
        warnings.add(
          '字段 "${fieldConfig.fieldKey}" 配置了 widthPercent 但未在有效列宽中找到',
        );
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// 验证结果类
class ValidationResult {
  /// 是否验证通过
  final bool isValid;

  /// 错误信息列表
  final List<String> errors;

  /// 警告信息列表
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  /// 创建成功结果
  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  /// 创建失败结果
  factory ValidationResult.failure(
    List<String> errors, {
    List<String> warnings = const [],
  }) {
    return ValidationResult(isValid: false, errors: errors, warnings: warnings);
  }

  /// 是否有警告
  bool get hasWarnings => warnings.isNotEmpty;

  /// 获取所有消息
  List<String> get allMessages => [...errors, ...warnings];
}

/// 数据适配器总配置类
///
/// 管理整个数据适配器的配置
class DataAdapterConfig {
  /// 字段标签配置
  final FieldLabelConfig fieldLabelConfig;

  /// 模块配置映射
  final Map<ModuleType, AdapterModuleConfig> moduleConfigs;

  /// 扩展的模块描述符集合（支持自定义模块）
  final Set<ModuleDescriptor> moduleDescriptors;

  const DataAdapterConfig({
    required this.fieldLabelConfig,
    required this.moduleConfigs,
    this.moduleDescriptors = const {},
  });

  /// 创建默认配置
  factory DataAdapterConfig.defaultConfig() {
    return DataAdapterConfig(
      fieldLabelConfig: FieldLabelConfig.defaultConfig(),
      moduleConfigs: _createDefaultModuleConfigs(),
      moduleDescriptors: _createDefaultModuleDescriptors(),
    );
  }

  /// 获取模块配置
  AdapterModuleConfig? getModuleConfig(ModuleType moduleType) {
    return moduleConfigs[moduleType];
  }

  /// 检查模块是否启用
  bool isModuleEnabled(ModuleType moduleType) {
    final config = moduleConfigs[moduleType];
    return config?.enabled ?? false;
  }

  /// 通过模块ID获取模块类型
  ModuleType? getModuleTypeByModuleId(String moduleId) {
    // 在模块描述符中查找
    for (final descriptor in moduleDescriptors) {
      if (descriptor.moduleId == moduleId) {
        return descriptor.type;
      }
    }

    return null;
  }

  /// 通过模块类型获取第一个匹配的模块ID
  String? getModuleIdByType(ModuleType type) {
    for (final descriptor in moduleDescriptors) {
      if (descriptor.type == type) {
        return descriptor.moduleId;
      }
    }
    return null;
  }

  /// 获取所有模块描述符
  Set<ModuleDescriptor> getAllModuleDescriptors() {
    return Set.unmodifiable(moduleDescriptors);
  }

  /// 获取支持的模块类型列表
  List<String> getSupportedModules() {
    return moduleConfigs.keys
        .where((type) => moduleConfigs[type]?.enabled ?? false)
        .map((type) => type.value)
        .toList();
  }

  /// 验证整个适配器配置
  ValidationResult validateConfiguration() {
    final allErrors = <String>[];
    final allWarnings = <String>[];

    // 验证每个模块的配置
    for (final entry in moduleConfigs.entries) {
      final moduleType = entry.key;
      final moduleConfig = entry.value;

      if (!moduleConfig.enabled) continue;

      final result = moduleConfig.validateColumnWidths();
      if (!result.isValid) {
        allErrors.addAll(
          result.errors.map((error) => '${moduleType.value}: $error'),
        );
      }
      allWarnings.addAll(
        result.warnings.map((warning) => '${moduleType.value}: $warning'),
      );
    }

    // 验证模块描述符的完整性
    for (final moduleType in ModuleType.values) {
      final moduleConfig = moduleConfigs[moduleType];
      if (moduleConfig?.enabled == true) {
        final hasDescriptor = moduleDescriptors.any(
          (d) => d.type == moduleType,
        );
        if (!hasDescriptor) {
          allWarnings.add('启用的模块 ${moduleType.value} 没有对应的模块描述符');
        }
      }
    }

    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }
}

/// 创建默认模块配置
Map<ModuleType, AdapterModuleConfig> _createDefaultModuleConfigs() {
  return {
    ModuleType.logo: const AdapterModuleConfig(
      moduleType: ModuleType.logo,
      moduleConfig: LogoConfig(enabled: true, priority: 1, required: false),
    ),
    ModuleType.title: const AdapterModuleConfig(
      moduleType: ModuleType.title,
      moduleConfig: TitleConfig(enabled: true, priority: 2, required: false),
    ),
    ModuleType.mainTable: const AdapterModuleConfig(
      moduleType: ModuleType.mainTable,
      moduleConfig: MainTableConfig(
        enabled: true,
        priority: 3,
        required: false,
      ),
    ),
    ModuleType.subTable: const AdapterModuleConfig(
      moduleType: ModuleType.subTable,
      moduleConfig: SubTableConfig(enabled: true, priority: 4, required: false),
    ),
    ModuleType.approval: const AdapterModuleConfig(
      moduleType: ModuleType.approval,
      moduleConfig: SubTableConfig(enabled: true, priority: 5, required: false),
    ),
    ModuleType.footer: const AdapterModuleConfig(
      moduleType: ModuleType.footer,
      moduleConfig: FooterConfig(enabled: true, priority: 6, required: false),
    ),
  };
}

/// 创建默认模块描述符集合
Set<ModuleDescriptor> _createDefaultModuleDescriptors() {
  return {
    ModuleDescriptor.logo,
    ModuleDescriptor.title,
    ModuleDescriptor.mainTable,
    ModuleDescriptor.subTable,
    ModuleDescriptor.approval,
    ModuleDescriptor.footer,
  };
}
