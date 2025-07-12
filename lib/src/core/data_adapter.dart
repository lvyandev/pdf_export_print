import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/constants/constants.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/models/models.dart';

/// 数据适配器接口
abstract class DataAdapter {
  /// 将原始数据适配为标准化的模块数据
  ///
  /// ### 参数
  /// - [rawData] 原始业务数据
  /// ### 返回值
  /// 返回按模块类型分组的标准化数据
  Map<String, ModuleData> adaptData(Map<String, dynamic> rawData);

  /// 验证原始数据是否有效
  ///
  /// ### 参数
  /// - [rawData] 原始业务数据
  /// ### 返回值
  /// 如果数据有效返回true，否则返回false
  bool validateData(Map<String, dynamic> rawData);

  /// 获取支持的模块类型列表
  List<String> getSupportedModules();
}

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

  /// 将原始数据适配为标准化的模块数据
  ///
  /// 根据配置的数据键映射和模块配置，将原始业务数据转换为
  /// 类型安全的模块数据对象。只处理已启用的模块。
  ///
  /// ### 参数
  /// - [rawData] 原始业务数据，键名应匹配 DataKeys 枚举值
  ///
  /// ### 返回值
  /// 返回按模块类型分组的标准化数据，键为模块类型字符串，值为对应的ModuleData子类
  ///
  /// ### 处理流程
  /// 1. 遍历所有已定义的数据键
  /// 2. 检查原始数据中是否包含该键
  /// 3. 获取对应的模块类型和配置
  /// 4. 调用相应的适配方法进行类型转换
  /// 5. 返回转换后的模块数据集合
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

  /// 验证原始数据是否有效
  ///
  /// 检查原始数据是否包含所有必需的模块数据。
  ///
  /// ### 参数
  /// - [rawData] 待验证的原始业务数据
  ///
  /// ### 返回值
  /// 如果数据有效返回true，否则返回false
  ///
  /// ### 验证规则
  /// 1. 数据不能为空
  /// 2. 所有标记为required的模块必须有对应的数据键
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

  /// 获取支持的模块类型列表
  ///
  /// 返回当前配置中已启用的模块类型字符串列表。
  ///
  /// ### 返回值
  /// 返回支持的模块类型字符串列表
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
  ///
  /// 根据模块类型调用相应的适配方法，将原始数据转换为具体的ModuleData子类。
  ///
  /// ### 参数
  /// - [dataKey] 数据键枚举，标识原始数据的类型
  /// - [moduleType] 模块类型枚举，决定使用哪个适配方法
  /// - [rawValue] 原始数据值，类型根据模块而定
  ///
  /// ### 返回值
  /// 返回对应的ModuleData子类实例，如果适配失败返回null
  ///
  /// ### 支持的模块类型
  /// - logo: 返回LogoData
  /// - title: 返回TitleData
  /// - mainTable: 返回MainTableData
  /// - subTable: 返回SubTableData
  /// - approval: 返回SubTableData
  /// - footer: 返回MainTableData
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
  ///
  /// 将原始Logo数据转换为类型安全的LogoData对象。
  ///
  /// ### 参数
  /// - [rawValue] 原始Logo数据，支持以下格式：
  ///   - String: 直接的Logo URL，使用默认尺寸
  ///   - `Map<String, dynamic>`: 包含logoUrl、width、height的详细配置
  ///
  /// ### 返回值
  /// 返回包含Logo URL和尺寸信息的LogoData对象
  ///
  /// ### 异常
  /// - ArgumentError: 当rawValue格式不支持时抛出
  LogoData _adaptLogoData(dynamic rawValue) {
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
      throw ArgumentError(
        'Invalid logo data format. Expected String (URL) or Map<String, dynamic> '
        'with logoUrl field, but got ${rawValue.runtimeType}',
      );
    }

    // 返回新的LogoData对象
    return LogoData(logoUrl: logoUrl, width: width, height: height);
  }

  /// 适配标题数据
  ///
  /// 将原始标题数据转换为类型安全的TitleData对象。
  ///
  /// ### 参数
  /// - [rawValue] 原始标题数据，支持以下格式：
  ///   - String: 单个标题文本
  ///   - List: 多个标题文本的列表
  ///   - `Map<String, dynamic>`: 包含titles、color、alignment的详细配置
  ///
  /// ### 返回值
  /// 返回包含标题列表和样式配置的TitleData对象
  ///
  /// ### 异常
  /// - ArgumentError: 当rawValue格式不支持时抛出
  TitleData _adaptTitleData(dynamic rawValue) {
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
        throw ArgumentError(
          'Invalid titles format in title data. Expected List or String for '
          'titles field, but got ${titlesData.runtimeType}',
        );
      }

      color = rawValue['color'] as String?;
      alignment = rawValue['alignment'] as String?;
    } else {
      throw ArgumentError(
        'Invalid title data format. Expected String, List, or Map<String, dynamic>, '
        'but got ${rawValue.runtimeType}',
      );
    }

    // 返回新的TitleData对象
    return TitleData(titles: titles, color: color, alignment: alignment);
  }

  /// 适配主表数据
  ///
  /// 将原始主表数据转换为类型安全的MainTableData对象。
  /// 根据配置的字段映射和标签配置处理表格字段。
  ///
  /// ### 参数
  /// - [rawValue] 原始主表数据，必须是 `Map<String, dynamic>` 格式
  ///
  /// ### 返回值
  /// 返回包含表格字段列表的MainTableData对象
  ///
  /// ### 异常
  /// - ArgumentError: 当rawValue不是Map类型时抛出
  MainTableData _adaptMainTableData(dynamic rawValue) {
    if (rawValue is! Map<String, dynamic>) {
      throw ArgumentError(
        'Main table data must be a Map<String, dynamic>, '
        'but got ${rawValue.runtimeType}',
      );
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
  ///
  /// 将原始子表数据转换为类型安全的SubTableData对象。
  /// 启用表头排序功能。
  ///
  /// ### 参数
  /// - [rawValue] 原始子表数据，必须是List格式
  ///
  /// ### 返回值
  /// 返回包含表头、行数据和排序配置的SubTableData对象
  SubTableData _adaptSubTableData(dynamic rawValue) {
    return _adaptTableData(
      rawValue,
      ModuleTypes.subTable,
      includeHeaderSorts: true,
    );
  }

  /// 适配审批记录数据
  ///
  /// 将原始审批记录数据转换为类型安全的SubTableData对象。
  /// 不启用表头排序功能。
  ///
  /// ### 参数
  /// - [rawValue] 原始审批数据，必须是List格式
  ///
  /// ### 返回值
  /// 返回包含审批记录表头和行数据的SubTableData对象
  SubTableData _adaptApprovalData(dynamic rawValue) {
    return _adaptTableData(
      rawValue,
      ModuleTypes.approval,
      includeHeaderSorts: false,
    );
  }

  /// 通用表格数据适配方法
  ///
  /// 统一处理子表和审批记录的数据适配逻辑。
  /// 将原始列表数据转换为结构化的SubTableData对象。
  ///
  /// ### 参数
  /// - [rawValue] 原始表格数据，必须是List格式
  /// - [moduleType] 模块类型，用于获取相应的配置
  /// - [includeHeaderSorts] 是否包含表头排序配置（当前未使用，保留用于扩展）
  ///
  /// ### 返回值
  /// 返回结构化的SubTableData对象
  ///
  /// ### 异常
  /// - ArgumentError: 当rawValue不是List类型时由_createSubTableData抛出
  SubTableData _adaptTableData(
    dynamic rawValue,
    ModuleTypes moduleType, {
    bool includeHeaderSorts = false,
  }) {
    // 直接创建 SubTableData，统一处理逻辑
    return _createSubTableData(rawValue, moduleType);
  }

  /// 适配页脚数据
  ///
  /// 将原始页脚数据转换为类型安全的MainTableData对象。
  /// 页脚数据使用MainTableData格式，支持多行显示。
  ///
  /// ### 参数
  /// - [rawValue] 原始页脚数据，必须是 `Map<String, dynamic>` 格式
  ///
  /// ### 返回值
  /// 返回配置为页脚模式的MainTableData对象，包含字段列表和显示配置
  ///
  /// ### 异常
  /// - ArgumentError: 当rawValue不是Map类型时抛出
  MainTableData _adaptFooterData(dynamic rawValue) {
    if (rawValue is! Map<String, dynamic>) {
      throw ArgumentError(
        'Footer data must be a Map<String, dynamic>, '
        'but got ${rawValue.runtimeType}',
      );
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

  /// 创建SubTableData对象
  ///
  /// 从原始列表数据创建结构化的SubTableData对象。
  /// 自动推断表头，转换数据行，并应用字段配置。
  ///
  /// ### 处理逻辑
  /// 1. 从第一行数据推断表头结构
  /// 2. 将原始数据转换为TableField对象
  /// 3. 应用字段配置（标签、列宽、排序等）
  /// 4. 生成显示用的表头标签
  ///
  /// ### 参数
  /// - [rawValue] 原始表格数据，必须是List格式，每个元素为 `Map<String, dynamic>`
  /// - [moduleType] 模块类型，用于获取字段配置和标题
  ///
  /// ### 返回值
  /// 返回完整配置的SubTableData对象，包含表头、行数据和显示配置
  ///
  /// ### 异常
  /// - ArgumentError: 当rawValue不是List类型时抛出
  SubTableData _createSubTableData(dynamic rawValue, ModuleTypes moduleType) {
    if (rawValue is! List) {
      throw ArgumentError(
        'Table data must be a List of Map<String, dynamic>, '
        'but got ${rawValue.runtimeType}',
      );
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
    final firstItem = dataList.first;
    if (firstItem is! Map<String, dynamic>) {
      throw ArgumentError(
        'Each item in table data must be a Map<String, dynamic>, '
        'but first item is ${firstItem.runtimeType}',
      );
    }
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

      // 遍历每个表头，创建对应的TableField
      for (int i = 0; i < originalHeaders.length; i++) {
        final originalHeader = originalHeaders[i]; // 原始字段名
        final displayHeader = headers[i]; // 显示标签
        final value = itemMap[originalHeader]?.toString() ?? '';

        // 获取字段配置（用于排序和列宽）
        final fieldConfig = moduleConfig?.getFieldConfig(originalHeader);

        // 确定列宽优先级：配置的列宽 > 字段配置的列宽 > 默认等宽
        double? widthPercent;
        if (columnWidthConfig.containsKey(originalHeader)) {
          // 优先使用模块配置中的列宽
          widthPercent = columnWidthConfig[originalHeader];
        } else if (fieldConfig != null) {
          // 其次使用字段配置中的列宽百分比
          widthPercent = fieldConfig.getEffectiveWidthPercent();
        }
        // 如果都没有配置，widthPercent 保持为 null，使用默认等宽

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
