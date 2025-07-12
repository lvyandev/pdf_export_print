import 'package:pdf_export_print/src/constants/adapter_constants.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/data/table_field.dart';

/// 字段标签配置类
///
/// 管理字段键名到显示标签的映射关系
class FieldLabelConfig {
  /// 字段标签映射
  final Map<String, String> _labelMappings;

  /// 私有构造函数
  const FieldLabelConfig._(this._labelMappings);

  /// 创建默认配置（空映射）
  ///
  /// 库级别不提供具体的字段映射，由业务项目自定义
  factory FieldLabelConfig.defaultConfig() {
    return FieldLabelConfig._(const <String, String>{});
  }

  /// 创建自定义配置
  factory FieldLabelConfig.custom(Map<String, String> customMappings) {
    return FieldLabelConfig._(Map<String, String>.from(customMappings));
  }

  /// 获取字段显示标签
  String getLabel(String fieldKey) {
    return _labelMappings[fieldKey] ?? fieldKey;
  }

  /// 通过字符串键获取标签（保持兼容性）
  String getLabelByString(String fieldKey) {
    return getLabel(fieldKey);
  }

  /// 检查是否包含字段映射
  bool hasMapping(String fieldKey) {
    return _labelMappings.containsKey(fieldKey);
  }

  /// 获取所有映射
  Map<String, String> get allMappings => Map.unmodifiable(_labelMappings);
}

/// 字段配置类
///
/// 定义字段的详细配置信息（不包含标签，标签由FieldLabelConfig管理）
class FieldConfig {
  /// 字段键
  final String fieldKey;

  /// 列宽百分比（0.0-1.0，如0.3表示30%）
  final double? widthPercent;

  /// 排序权重
  final int sort;

  /// 是否必需
  final bool required;

  const FieldConfig({
    required this.fieldKey,
    this.widthPercent,
    this.sort = 0,
    this.required = false,
  });

  /// 获取有效的列宽百分比
  double getEffectiveWidthPercent() {
    return getEffectiveWidthPercentUtil(widthPercent);
  }

  /// 创建表格字段（需要外部提供标签）
  TableField toTableField(dynamic value, String label) {
    return TableField(
      label: label,
      value: value?.toString() ?? '',
      widthPercent: widthPercent,
      sort: sort,
    );
  }
}

/// 适配器模块配置类
///
/// 定义适配器模块的配置信息
class AdapterModuleConfig {
  /// 模块类型
  final ModuleTypes moduleType;

  /// 是否启用
  final bool enabled;

  /// 优先级
  final int priority;

  /// 是否必需
  final bool required;

  /// 字段配置列表
  final List<FieldConfig> fieldConfigs;

  /// 自定义设置
  final Map<String, dynamic> customSettings;

  const AdapterModuleConfig({
    required this.moduleType,
    this.enabled = true,
    this.priority = 0,
    this.required = false,
    this.fieldConfigs = const [],
    this.customSettings = const {},
  });

  /// 获取字段配置
  FieldConfig? getFieldConfig(String fieldKey) {
    for (final config in fieldConfigs) {
      if (config.fieldKey == fieldKey) return config;
    }
    return null;
  }

  /// 获取自定义设置
  T? getSetting<T>(String key) {
    return customSettings[key] as T?;
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
  final Map<ModuleTypes, AdapterModuleConfig> moduleConfigs;

  /// 数据键映射
  final Map<DataKeys, ModuleTypes> dataKeyMappings;

  const DataAdapterConfig({
    required this.fieldLabelConfig,
    required this.moduleConfigs,
    required this.dataKeyMappings,
  });

  /// 创建默认配置
  factory DataAdapterConfig.defaultConfig() {
    return DataAdapterConfig(
      fieldLabelConfig: FieldLabelConfig.defaultConfig(),
      moduleConfigs: _createDefaultModuleConfigs(),
      dataKeyMappings: _createDefaultDataKeyMappings(),
    );
  }

  /// 获取模块配置
  AdapterModuleConfig? getModuleConfig(ModuleTypes moduleType) {
    return moduleConfigs[moduleType];
  }

  /// 通过数据键获取模块类型
  ModuleTypes? getModuleTypeByDataKey(DataKeys dataKey) {
    return dataKeyMappings[dataKey];
  }

  /// 检查模块是否启用
  bool isModuleEnabled(ModuleTypes moduleType) {
    final config = moduleConfigs[moduleType];
    return config?.enabled ?? false;
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

    // 验证数据键映射的完整性
    for (final moduleType in ModuleTypes.values) {
      final moduleConfig = moduleConfigs[moduleType];
      if (moduleConfig?.enabled == true) {
        final hasDataKey = dataKeyMappings.values.contains(moduleType);
        if (!hasDataKey) {
          allWarnings.add('启用的模块 ${moduleType.value} 没有对应的数据键映射');
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
Map<ModuleTypes, AdapterModuleConfig> _createDefaultModuleConfigs() {
  return {
    ModuleTypes.logo: const AdapterModuleConfig(
      moduleType: ModuleTypes.logo,
      enabled: true,
      priority: 1,
      required: false,
    ),
    ModuleTypes.title: const AdapterModuleConfig(
      moduleType: ModuleTypes.title,
      enabled: true,
      priority: 2,
      required: false,
    ),
    ModuleTypes.mainTable: const AdapterModuleConfig(
      moduleType: ModuleTypes.mainTable,
      enabled: true,
      priority: 3,
      required: false,
    ),
    ModuleTypes.subTable: const AdapterModuleConfig(
      moduleType: ModuleTypes.subTable,
      enabled: true,
      priority: 4,
      required: false,
    ),
    ModuleTypes.approval: const AdapterModuleConfig(
      moduleType: ModuleTypes.approval,
      enabled: true,
      priority: 5,
      required: false,
    ),
    ModuleTypes.footer: const AdapterModuleConfig(
      moduleType: ModuleTypes.footer,
      enabled: true,
      priority: 6,
      required: false,
    ),
  };
}

/// 创建默认数据键映射
Map<DataKeys, ModuleTypes> _createDefaultDataKeyMappings() {
  return {
    DataKeys.logoUrl: ModuleTypes.logo,
    DataKeys.titles: ModuleTypes.title,
    DataKeys.mainData: ModuleTypes.mainTable,
    DataKeys.details: ModuleTypes.subTable,
    DataKeys.approvals: ModuleTypes.approval,
    DataKeys.footerData: ModuleTypes.footer,
  };
}
