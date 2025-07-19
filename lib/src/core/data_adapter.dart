import 'dart:developer';

import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/constants/constants.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/table_field.dart';
import 'package:pdf_export_print/src/models/models.dart';
import 'package:pdf_export_print/src/modules/modules.dart';

/// 数据适配器接口
abstract class DataAdapter {
  DataAdapter(this.config);

  /// 适配器配置
  final DataAdapterConfig config;

  /// 将ModuleDescriptor适配为具体的模块数据类型
  /// ### 参数
  /// - [descriptor] 模块描述符
  /// ### 返回值
  /// 返回适配后的具体数据类型（LogoData、TitleData、MainTableData、SubTableData等），如果适配失败返回null
  ModuleDescriptor? adaptModuleData(ModuleDescriptor descriptor);

  /// 将ModuleDescriptor适配为对应的PDFModule
  ///
  /// ### 参数
  /// - [descriptor] 模块描述符
  /// ### 返回值
  /// 返回适配后的PDFModule实例，如果适配失败返回null
  PDFModule? adaptModule(ModuleDescriptor descriptor);

  /// 获取支持的模块类型列表
  List<String> getSupportedModules();
}

/// 类型安全的数据适配器
///
/// 使用枚举和配置驱动的方式替代硬编码字符串，提供类型安全的数据适配功能
class TypeSafeDataAdapter extends DataAdapter {
  /// 支持的图片服务域名列表
  static const List<String> imageServiceDomains = [
    'picsum.photos',
    'via.placeholder.com',
    'placehold.it',
    'dummyimage.com',
    'lorempixel.com',
    'unsplash.com',
    'pexels.com',
  ];

  /// 构造函数
  TypeSafeDataAdapter({DataAdapterConfig? config})
    : super(config ?? DataAdapterConfig.defaultConfig()) {
    // 验证配置
    final validationResult = this.config.validateConfiguration();
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
  PDFModule? adaptModule(ModuleDescriptor descriptor) {
    // 检查模块是否启用
    if (!config.isModuleEnabled(descriptor.type)) {
      log('$descriptor disabled!');
      return null;
    }

    final adaptedDescriptor = adaptModuleData(descriptor);
    if (adaptedDescriptor == null) {
      log('$descriptor adapt failed!');
      return null;
    }

    // 根据模块类型调用相应的专用转换方法
    switch (adaptedDescriptor.type) {
      case ModuleType.logo:
        final moduleConfig = config.getModuleConfig(adaptedDescriptor.type);
        return LogoModule(
          config: moduleConfig?.getTypedModuleConfig<LogoConfig>(),
          descriptor: adaptedDescriptor,
        );
      case ModuleType.title:
        final moduleConfig = config.getModuleConfig(adaptedDescriptor.type);
        return TitleModule(
          config: moduleConfig?.getTypedModuleConfig<TitleConfig>(),
          descriptor: adaptedDescriptor,
        );
      case ModuleType.mainTable:
        final moduleConfig = config.getModuleConfig(adaptedDescriptor.type);
        return MainTableModule(
          config: moduleConfig?.getTypedModuleConfig<MainTableConfig>(),
          descriptor: adaptedDescriptor,
        );
      case ModuleType.subTable:
        final moduleConfig = config.getModuleConfig(adaptedDescriptor.type);
        return SubTableModule(
          config: moduleConfig?.getTypedModuleConfig<SubTableConfig>(),
          descriptor: adaptedDescriptor,
        );
      case ModuleType.approval:
        final moduleConfig = config.getModuleConfig(adaptedDescriptor.type);
        return SubTableModule(
          config: moduleConfig?.getTypedModuleConfig<SubTableConfig>(),
          descriptor: adaptedDescriptor,
        );
      case ModuleType.footer:
        final moduleConfig = config.getModuleConfig(adaptedDescriptor.type);
        return FooterModule(
          config: moduleConfig?.getTypedModuleConfig<FooterConfig>(),
          descriptor: adaptedDescriptor,
        );
    }
  }

  @override
  ModuleDescriptor? adaptModuleData(ModuleDescriptor descriptor) {
    // 检查模块是否启用
    if (!config.isModuleEnabled(descriptor.type)) {
      return null;
    }

    // 根据模块类型调用相应的专用转换方法
    switch (descriptor.type) {
      case ModuleType.logo:
        return _adaptLogoData(descriptor);
      case ModuleType.title:
        return _adaptTitleData(descriptor);
      case ModuleType.mainTable:
        return _adaptMainTableData(descriptor);
      case ModuleType.subTable:
        return _adaptSubTableData(descriptor);
      case ModuleType.approval:
        return _adaptSubTableData(descriptor);
      case ModuleType.footer:
        return _adaptFooterData(descriptor);
    }
  }

  @override
  List<String> getSupportedModules() {
    return config.getSupportedModules();
  }

  /// 检查字符串是否为图片URL
  ///
  /// ### 参数
  /// - [value] 要检查的字符串值
  /// ### 返回值
  /// 如果是图片URL返回true，否则返回false
  bool _isImageUrl(String value) {
    if (value.isEmpty) return false;

    // 检查是否以http/https开头
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return false;
    }

    try {
      final uri = Uri.parse(value);
      final host = uri.host.toLowerCase();

      // 检查是否是已知的图片服务域名
      if (imageServiceDomains.any((domain) => host.contains(domain))) {
        return true;
      }

      // 检查文件扩展名
      final path = uri.path.toLowerCase();
      return path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.gif') ||
          path.endsWith('.webp') ||
          path.endsWith('.svg');
    } catch (e) {
      return false;
    }
  }

  /// 检查字段名是否包含图片相关关键词
  ///
  /// ### 参数
  /// - [fieldName] 字段名
  /// ### 返回值
  /// 如果字段名包含图片关键词返回true，否则返回false
  bool _isImageField(String fieldName) {
    final lowerFieldName = fieldName.toLowerCase();
    return lowerFieldName.contains('图片') ||
        lowerFieldName.contains('image') ||
        lowerFieldName.contains('photo') ||
        lowerFieldName.contains('pic') ||
        lowerFieldName.contains('avatar') ||
        lowerFieldName.contains('logo');
  }

  /// 智能创建TableField，支持图片检测
  ///
  /// ### 参数
  /// - [originalHeader] 原始字段名
  /// - [displayHeader] 显示标签
  /// - [rawValue] 原始数据值
  /// - [widthPercent] 列宽百分比
  /// - [sort] 排序值
  /// ### 返回值
  /// 返回创建的TableField实例
  TableField _createTableFieldWithImageDetection({
    required String originalHeader,
    required String displayHeader,
    required dynamic rawValue,
    required double? widthPercent,
    required int? sort,
  }) {
    // 处理null值
    if (rawValue == null) {
      return TableField(
        label: displayHeader,
        value: '',
        widthPercent: widthPercent,
        sort: sort,
      );
    }

    // 如果是字符串类型，检查是否为图片URL
    if (rawValue is String) {
      final stringValue = rawValue.trim();

      // 检查是否为图片URL（通过URL格式或字段名判断）
      if ((_isImageUrl(stringValue) || _isImageField(originalHeader)) &&
          stringValue.isNotEmpty) {
        return TableField(
          label: displayHeader,
          value: '[img]', // 显示占位文本
          content: ImageContent(imageUrl: stringValue, altText: '[img]'),
          widthPercent: widthPercent,
          sort: sort,
        );
      } else {
        // 普通文本字段
        return TableField(
          label: displayHeader,
          value: stringValue,
          widthPercent: widthPercent,
          sort: sort,
        );
      }
    }

    // 如果是Map类型（复杂对象），检查是否包含图片信息
    if (rawValue is Map<String, dynamic>) {
      // 检查是否包含图片URL字段
      final imageUrl =
          rawValue['imageUrl']?.toString() ??
          rawValue['url']?.toString() ??
          rawValue['image']?.toString() ??
          '';

      if (imageUrl.isNotEmpty) {
        return TableField(
          label: displayHeader,
          value: rawValue['altText']?.toString() ?? '[图片]',
          content: ImageContent(
            imageUrl: imageUrl,
            altText: rawValue['altText']?.toString(),
            maxHeight: rawValue['maxHeight'] as double?,
          ),
          widthPercent: widthPercent,
          sort: sort,
        );
      } else {
        // 复杂文本对象，取value或转换为字符串
        final displayValue =
            rawValue['value']?.toString() ?? rawValue.toString();
        return TableField(
          label: displayHeader,
          value: displayValue,
          widthPercent: widthPercent,
          sort: sort,
        );
      }
    }

    // 其他类型，转换为字符串
    return TableField(
      label: displayHeader,
      value: rawValue.toString(),
      widthPercent: widthPercent,
      sort: sort,
    );
  }

  /// 适配Logo数据
  LogoData? _adaptLogoData(ModuleDescriptor descriptor) {
    if (descriptor is LogoData) {
      return descriptor;
    }

    final dynamic rawValue = descriptor.data;
    if (rawValue == null) return null;

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

    if (logoUrl.isEmpty) return null;

    // 返回新的LogoData对象
    return LogoData(logoUrl: logoUrl, width: width, height: height);
  }

  /// 适配标题数据
  TitleData? _adaptTitleData(ModuleDescriptor descriptor) {
    if (descriptor is TitleData) {
      return descriptor;
    }

    final rawValue = descriptor.data;
    if (rawValue == null) return null;

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

    if (titles.isEmpty) return null;

    // 返回新的TitleData对象
    return TitleData(titles: titles, color: color, alignment: alignment);
  }

  /// 适配主表数据
  MainTableData? _adaptMainTableData(ModuleDescriptor descriptor) {
    if (descriptor is MainTableData) {
      return descriptor;
    }

    final rawValue = descriptor.data;
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
      final moduleConfig = config.getModuleConfig(ModuleType.mainTable);
      final fieldConfig = moduleConfig?.getFieldConfig(key);

      if (fieldConfig != null) {
        // 使用字段配置创建TableField，标签从FieldLabelConfig获取（支持模块上下文）
        final label = config.fieldLabelConfig.getLabelWithModule(
          key,
          descriptor.moduleId,
        );
        fields.add(fieldConfig.toTableField(value, label));
      } else {
        // 如果没有字段配置，使用默认配置（支持模块上下文）
        final label = config.fieldLabelConfig.getLabelWithModule(
          key,
          descriptor.moduleId,
        );
        fields.add(
          TableField(
            label: label,
            value: value?.toString() ?? '',
            widthPercent: 0.33,
          ),
        );
      }
    });

    // 返回MainTableData用于主表
    return MainTableData.forMainTable(
      fields: fields,
      showBorder: true,
      showInnerBorder: true,
      moduleId: descriptor.moduleId,
    );
  }

  /// 适配子表数据
  ///
  /// 应用子表模块的配置，包括字段配置和样式配置
  SubTableData? _adaptSubTableData(ModuleDescriptor descriptor) {
    if (descriptor is SubTableData) {
      return descriptor;
    }

    final data = descriptor.data;
    if (data == null) return null;

    return _createSubTableData(data, descriptor.type, descriptor.moduleId);
  }

  /// 适配页脚数据
  MainTableData? _adaptFooterData(ModuleDescriptor descriptor) {
    if (descriptor is MainTableData) {
      return descriptor;
    }

    final rawValue = descriptor.data;
    if (rawValue == null) return null;

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
      final moduleConfig = config.getModuleConfig(ModuleType.footer);
      final fieldConfig = moduleConfig?.getFieldConfig(key);

      if (fieldConfig != null) {
        // 使用字段配置创建TableField，标签从FieldLabelConfig获取（支持模块上下文）
        final label = config.fieldLabelConfig.getLabelWithModule(
          key,
          descriptor.moduleId,
        );
        fields.add(fieldConfig.toTableField(value, label));
      } else {
        // 如果没有字段配置，使用默认配置（支持模块上下文）
        final label = config.fieldLabelConfig.getLabelWithModule(
          key,
          descriptor.moduleId,
        );
        fields.add(TableField(label: label, value: value?.toString() ?? ''));
      }
    });

    // 返回MainTableData用于页脚
    return MainTableData.forFooter(fields: fields);
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
  SubTableData _createSubTableData(
    dynamic rawValue,
    ModuleType moduleType,
    String moduleId,
  ) {
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
        tableRows: [],
        title: config.fieldLabelConfig.getLabel(moduleId),
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

    // 转换为显示标签（支持模块上下文）
    final headers = originalHeaders
        .map(
          (h) =>
              config.fieldLabelConfig.getLabelByStringWithModule(h, moduleId),
        )
        .toList();

    // 获取模块配置
    final moduleConfig = config.getModuleConfig(moduleType);

    // 从模块配置获取列宽设置（只使用FieldConfig）
    final columnWidthConfig =
        moduleConfig?.getColumnWidthsFromFieldConfigs() ?? <String, double>{};

    // 转换数据行为TableField列表
    final List<List<TableField>> rows = dataList.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final rowFields = <TableField>[];

      // 遍历每个表头，创建对应的TableField
      for (int i = 0; i < originalHeaders.length; i++) {
        final originalHeader = originalHeaders[i]; // 原始字段名
        final displayHeader = headers[i]; // 显示标签
        final rawValue = itemMap[originalHeader]; // 保持原始数据类型

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

        // 智能创建TableField，支持图片识别
        final tableField = _createTableFieldWithImageDetection(
          originalHeader: originalHeader,
          displayHeader: displayHeader,
          rawValue: rawValue,
          widthPercent: widthPercent,
          sort: fieldConfig?.sort,
        );

        rowFields.add(tableField);
      }

      return rowFields;
    }).toList();

    return SubTableData(
      headers: headers,
      tableRows: rows,
      title: config.fieldLabelConfig.getLabel(moduleId),
      showBorder: true,
    );
  }
}
