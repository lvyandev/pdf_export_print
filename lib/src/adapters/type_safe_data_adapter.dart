import '../constants/adapter_constants.dart';
import '../constants/module_constants.dart';
import '../configs/adapter_config.dart';
import '../core/core.dart';
import '../data/data.dart';
import '../models/models.dart';

/// 类型安全的数据适配器
///
/// 使用枚举和配置驱动的方式替代硬编码字符串，提供类型安全的数据适配功能
class TypeSafeDataAdapter extends DataAdapter {
  /// 适配器配置
  final DataAdapterConfig _config;

  /// 构造函数
  TypeSafeDataAdapter({DataAdapterConfig? config})
    : _config = config ?? DataAdapterConfig.defaultConfig() {
    // 验证配置
    final validationResult = _config.validateConfiguration();
    if (!validationResult.isValid) {
      throw ArgumentError('适配器配置验证失败: ${validationResult.errors.join(', ')}');
    }

    // 存储验证结果供外部访问
    _validationResult = validationResult;
  }

  /// 配置验证结果
  late final ValidationResult _validationResult;

  /// 获取配置验证结果
  ValidationResult get validationResult => _validationResult;

  @override
  Map<String, ModuleData> adaptData(Map<String, dynamic> rawData) {
    final Map<String, ModuleData> adaptedData = {};

    // 遍历所有数据键，进行适配
    for (final dataKey in DataKeys.values) {
      if (rawData.containsKey(dataKey.value)) {
        final moduleType = _config.getModuleTypeByDataKey(dataKey);
        if (moduleType != null && _config.isModuleEnabled(moduleType)) {
          final moduleData = _adaptModuleData(
            dataKey,
            moduleType,
            rawData[dataKey.value],
          );
          if (moduleData != null) {
            adaptedData[moduleType.value] = moduleData;
          }
        }
      }
    }

    return adaptedData;
  }

  @override
  bool validateData(Map<String, dynamic> rawData) {
    if (rawData.isEmpty) return false;

    // 验证必需的模块数据
    for (final moduleType in ModuleTypes.values) {
      final moduleConfig = _config.getModuleConfig(moduleType);
      if (moduleConfig?.required == true) {
        final requiredDataKey = _getDataKeyForModule(moduleType);
        if (requiredDataKey != null &&
            !rawData.containsKey(requiredDataKey.value)) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  List<String> getSupportedModules() {
    return _config.getSupportedModules();
  }

  /// 获取适配器配置
  ///
  /// ### 返回值
  /// 返回当前适配器的配置对象
  DataAdapterConfig get config => _config;

  /// 适配模块数据
  ModuleData? _adaptModuleData(
    DataKeys dataKey,
    ModuleTypes moduleType,
    dynamic rawValue,
  ) {
    switch (moduleType) {
      case ModuleTypes.logo:
        return _adaptLogoData(rawValue);
      case ModuleTypes.title:
        return _adaptTitleData(rawValue);
      case ModuleTypes.mainTable:
        return _adaptMainTableData(rawValue);
      case ModuleTypes.subTable:
        return _adaptSubTableData(rawValue);
      case ModuleTypes.approval:
        return _adaptApprovalData(rawValue);
      case ModuleTypes.footer:
        return _adaptFooterData(rawValue);
    }
  }

  /// 适配Logo数据
  ModuleData _adaptLogoData(dynamic rawValue) {
    String logoUrl;
    double? width;
    double? height;

    if (rawValue is String) {
      // 简单的URL字符串
      logoUrl = rawValue;
      width = LogoConstants.defaultWidth;
      height = LogoConstants.defaultHeight;
    } else if (rawValue is Map<String, dynamic>) {
      // 包含详细配置的Map
      logoUrl = rawValue['logoUrl'] as String? ?? '';
      width = rawValue['width'] as double?;
      height = rawValue['height'] as double?;

      // 如果没有指定尺寸，使用默认值
      width ??= LogoConstants.defaultWidth;
      height ??= LogoConstants.defaultHeight;
    } else {
      throw ArgumentError('Invalid logo data format');
    }

    // 返回新的LogoData对象
    return LogoData(logoUrl: logoUrl, width: width, height: height);
  }

  /// 适配标题数据
  ModuleData _adaptTitleData(dynamic rawValue) {
    List<String> titles;
    String? color;
    String? alignment;

    if (rawValue is List) {
      titles = rawValue.map((e) => e.toString()).toList();
    } else if (rawValue is String) {
      titles = [rawValue];
    } else if (rawValue is Map<String, dynamic>) {
      // 支持包含颜色和对齐方式的Map格式
      final titlesData = rawValue['titles'];
      if (titlesData is List) {
        titles = titlesData.map((e) => e.toString()).toList();
      } else if (titlesData is String) {
        titles = [titlesData];
      } else {
        throw ArgumentError('Invalid titles format in title data');
      }

      color = rawValue['color'] as String?;
      alignment = rawValue['alignment'] as String?;
    } else {
      throw ArgumentError('Invalid title data format');
    }

    // 返回新的TitleData对象
    return TitleData(titles: titles, color: color, alignment: alignment);
  }

  /// 适配主表数据
  ModuleData _adaptMainTableData(dynamic rawValue) {
    if (rawValue is! Map<String, dynamic>) {
      throw ArgumentError('Main table data must be a Map');
    }

    final mainData = rawValue;
    final fields = <TableField>[];

    mainData.forEach((key, value) {
      // 获取主表模块配置
      final moduleConfig = _config.getModuleConfig(ModuleTypes.mainTable);
      final fieldConfig = moduleConfig?.getFieldConfig(key);

      if (fieldConfig != null) {
        // 使用字段配置创建TableField，标签从FieldLabelConfig获取
        final label = _config.fieldLabelConfig.getLabel(key);
        fields.add(fieldConfig.toTableField(value, label));
      } else {
        // 如果没有字段配置，使用默认配置
        final label = _config.fieldLabelConfig.getLabel(key);
        fields.add(TableField(label: label, value: value.toString(), sort: 0));
      }
    });

    // 返回MainTableData用于主表
    return MainTableData.forMainTable(
      fields: fields,
      showBorder: true,
      showInnerBorder: false,
    );
  }

  /// 适配子表数据
  ModuleData _adaptSubTableData(dynamic rawValue) {
    return _adaptTableData(
      rawValue,
      ModuleTypes.subTable,
      includeHeaderSorts: true,
    );
  }

  /// 适配审批记录数据
  ModuleData _adaptApprovalData(dynamic rawValue) {
    return _adaptTableData(
      rawValue,
      ModuleTypes.approval,
      includeHeaderSorts: false,
    );
  }

  /// 通用表格数据适配方法（合并子表和审批逻辑）
  ModuleData _adaptTableData(
    dynamic rawValue,
    ModuleTypes moduleType, {
    bool includeHeaderSorts = false,
  }) {
    // 尝试创建新的SubTableData格式
    try {
      return _createSubTableData(rawValue, moduleType);
    } catch (e) {
      // 如果失败，回退到原始格式
      return _adaptGenericTableData(
        rawValue,
        moduleType.value,
        _config.fieldLabelConfig.getLabel(moduleType.value),
        includeHeaderSorts: includeHeaderSorts,
      );
    }
  }

  /// 适配页脚数据
  ModuleData _adaptFooterData(dynamic rawValue) {
    if (rawValue is! Map<String, dynamic>) {
      throw ArgumentError('Footer data must be a Map');
    }

    final footerData = rawValue;
    final fields = <TableField>[];

    footerData.forEach((key, value) {
      // 获取页脚模块配置
      final moduleConfig = _config.getModuleConfig(ModuleTypes.footer);
      final fieldConfig = moduleConfig?.getFieldConfig(key);

      if (fieldConfig != null) {
        // 使用字段配置创建TableField，标签从FieldLabelConfig获取
        final label = _config.fieldLabelConfig.getLabel(key);
        fields.add(fieldConfig.toTableField(value, label));
      } else {
        // 如果没有字段配置，使用默认配置
        final label = _config.fieldLabelConfig.getLabel(key);
        fields.add(TableField(label: label, value: value.toString(), sort: 0));
      }
    });

    // 返回MainTableData用于页脚
    return MainTableData.forFooter(
      fields: fields,
      showBorder: true,
      showInnerBorder: false,
      fieldsPerRow: 3,
    );
  }

  /// 根据模块类型获取对应的数据键
  DataKeys? _getDataKeyForModule(ModuleTypes moduleType) {
    for (final entry in _config.dataKeyMappings.entries) {
      if (entry.value == moduleType) {
        return entry.key;
      }
    }
    return null;
  }

  /// 通用表格数据适配方法
  ModuleData _adaptGenericTableData(
    dynamic rawValue,
    String moduleType,
    String title, {
    bool includeHeaderSorts = false,
  }) {
    if (rawValue is! List) {
      throw ArgumentError('Table data must be a List');
    }

    final dataList = rawValue;
    if (dataList.isEmpty) {
      return ModuleData(
        moduleType: moduleType,
        data: {
          'headers': <String>[],
          'rows': <List<String>>[],
          'headerSorts': <String, int>{},
          'columnWidths': <double>[],
        },
      );
    }

    // 从第一行数据推断表头
    final firstItem = dataList.first as Map<String, dynamic>;
    final headers = firstItem.keys.toList();

    // 转换数据行
    final rows = dataList.map((item) {
      final itemMap = item as Map<String, dynamic>;
      return headers
          .map((header) => itemMap[header]?.toString() ?? '')
          .toList();
    }).toList();

    // 获取模块类型枚举
    final moduleTypeEnum = ModuleTypes.values.firstWhere(
      (type) => type.value == moduleType,
      orElse: () => ModuleTypes.subTable, // 默认值
    );

    // 获取模块配置
    final moduleConfig = _config.getModuleConfig(moduleTypeEnum);

    // 设置表头排序权重（可选）
    final headerSorts = <String, int>{};
    if (includeHeaderSorts) {
      for (final header in headers) {
        final fieldConfig = moduleConfig?.getFieldConfig(header);
        final displayLabel = _config.fieldLabelConfig.getLabel(header);
        headerSorts[displayLabel] = fieldConfig?.sort ?? 0;
      }
    }

    // 从模块配置获取列宽设置（只使用FieldConfig）
    final columnWidthConfig =
        moduleConfig?.getColumnWidthsFromFieldConfigs() ?? <String, double>{};
    final columnWidths = <double>[];

    if (columnWidthConfig.isNotEmpty) {
      // 计算未配置列的默认宽度
      final configuredWidth = columnWidthConfig.values.fold(
        0.0,
        (sum, width) => sum + width,
      );
      final unconfiguredCount = headers.length - columnWidthConfig.length;
      final defaultWidth = unconfiguredCount > 0
          ? (1.0 - configuredWidth) / unconfiguredCount
          : 0.0;

      for (final header in headers) {
        columnWidths.add(columnWidthConfig[header] ?? defaultWidth);
      }
    } else {
      // 如果没有配置，使用等宽分配
      columnWidths.addAll(List.filled(headers.length, 1.0 / headers.length));
    }

    return ModuleData(
      moduleType: moduleType,
      data: {
        'title': title, // 添加标题到模块数据中
        'headers': headers
            .map((h) => _config.fieldLabelConfig.getLabelByString(h))
            .toList(),
        'rows': rows,
        'headerSorts': headerSorts,
        'columnWidths': columnWidths,
      },
    );
  }

  /// 创建新的SubTableData格式
  SubTableData _createSubTableData(dynamic rawValue, ModuleTypes moduleType) {
    if (rawValue is! List) {
      throw ArgumentError('Table data must be a List');
    }

    final dataList = rawValue;
    if (dataList.isEmpty) {
      return SubTableData(
        headers: [],
        rows: [],
        title: _config.fieldLabelConfig.getLabel(moduleType.value),
      );
    }

    // 从第一行数据推断表头
    final firstItem = dataList.first as Map<String, dynamic>;
    final originalHeaders = firstItem.keys.toList();

    // 转换为显示标签
    final headers = originalHeaders
        .map((h) => _config.fieldLabelConfig.getLabelByString(h))
        .toList();

    // 获取模块配置
    final moduleConfig = _config.getModuleConfig(moduleType);

    // 从模块配置获取列宽设置（只使用FieldConfig）
    final columnWidthConfig =
        moduleConfig?.getColumnWidthsFromFieldConfigs() ?? <String, double>{};

    // 转换数据行为TableField列表
    final rows = dataList.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final rowFields = <TableField>[];

      for (int i = 0; i < originalHeaders.length; i++) {
        final originalHeader = originalHeaders[i];
        final displayHeader = headers[i];
        final value = itemMap[originalHeader]?.toString() ?? '';

        // 获取字段配置
        final fieldConfig = moduleConfig?.getFieldConfig(originalHeader);

        // 确定列宽
        double? widthPercent;
        if (columnWidthConfig.containsKey(originalHeader)) {
          widthPercent = columnWidthConfig[originalHeader];
        } else if (fieldConfig != null) {
          // 从字段配置获取列宽百分比
          widthPercent = fieldConfig.getEffectiveWidthPercent();
        }

        rowFields.add(
          TableField(
            label: displayHeader,
            value: value,
            widthPercent: widthPercent,
            sort: fieldConfig?.sort ?? 0,
          ),
        );
      }

      return rowFields;
    }).toList();

    return SubTableData(
      headers: headers,
      rows: rows,
      title: _config.fieldLabelConfig.getLabel(moduleType.value),
      showBorder: true,
    );
  }
}
