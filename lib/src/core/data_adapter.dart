import 'package:pdf_export_print/src/constants/constants.dart';
import 'package:pdf_export_print/src/data/data.dart';

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

/// 通用数据适配器
class GenericDataAdapter extends DataAdapter {
  /// 字段映射配置
  final Map<String, FieldMapping> _fieldMappings;

  /// 模块配置
  final Map<String, ModuleAdapterConfig> _moduleConfigs;

  GenericDataAdapter({
    Map<String, FieldMapping>? fieldMappings,
    Map<String, ModuleAdapterConfig>? moduleConfigs,
  }) : _fieldMappings = fieldMappings ?? {},
       _moduleConfigs = moduleConfigs ?? {};

  @override
  Map<String, ModuleData> adaptData(Map<String, dynamic> rawData) {
    final Map<String, ModuleData> adaptedData = {};

    // 适配Logo模块数据
    if (_moduleConfigs.containsKey('logo') && rawData.containsKey('logoUrl')) {
      adaptedData['logo'] = _adaptLogoData(rawData);
    }

    // 适配标题模块数据
    if (_moduleConfigs.containsKey('title') && rawData.containsKey('titles')) {
      adaptedData['title'] = _adaptTitleData(rawData);
    }

    // 适配主表数据
    if (_moduleConfigs.containsKey('main_table') &&
        rawData.containsKey('mainData')) {
      adaptedData['main_table'] = _adaptMainTableData(rawData['mainData']);
    }

    // 适配子表数据
    if (_moduleConfigs.containsKey('sub_table') &&
        rawData.containsKey('details')) {
      adaptedData['sub_table'] = _adaptSubTableData(rawData['details']);
    }

    // 适配审批记录数据
    if (_moduleConfigs.containsKey('approval') &&
        rawData.containsKey('approvals')) {
      adaptedData['approval'] = _adaptApprovalData(rawData['approvals']);
    }

    // 适配页脚数据
    if (_moduleConfigs.containsKey('footer') &&
        rawData.containsKey('footerData')) {
      adaptedData['footer'] = _adaptFooterData(rawData['footerData']);
    }

    return adaptedData;
  }

  @override
  bool validateData(Map<String, dynamic> rawData) {
    // 基础数据验证
    if (rawData.isEmpty) return false;

    // 验证必需的模块数据
    for (final moduleType in _moduleConfigs.keys) {
      final config = _moduleConfigs[moduleType]!;
      if (config.required) {
        final requiredField = _getRequiredFieldForModule(moduleType);
        if (requiredField != null && !rawData.containsKey(requiredField)) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  List<String> getSupportedModules() {
    return _moduleConfigs.keys.toList();
  }

  /// 适配Logo数据
  ModuleData _adaptLogoData(Map<String, dynamic> rawData) {
    return ModuleData(
      moduleType: 'logo',
      data: {
        'logoUrl': rawData['logoUrl'],
        'width': rawData['logoWidth'] ?? LogoConstants.smallWidth,
        'height': rawData['logoHeight'] ?? LogoConstants.smallHeight,
      },
    );
  }

  /// 适配标题数据
  ModuleData _adaptTitleData(Map<String, dynamic> rawData) {
    final titles = rawData['titles'] as List<dynamic>? ?? [];
    return ModuleData(
      moduleType: 'title',
      data: {
        'titles': titles.map((t) => t.toString()).toList(),
        'color': rawData['titleColor'] ?? 'red',
        'alignment': rawData['titleAlignment'] ?? 'center',
      },
    );
  }

  /// 适配主表数据
  ModuleData _adaptMainTableData(Map<String, dynamic> data) {
    final List<TableField> fields = [];

    _fieldMappings.forEach((key, mapping) {
      if (data.containsKey(mapping.sourceField)) {
        final value = data[mapping.sourceField];
        if (value != null) {
          fields.add(
            TableField(
              label: mapping.displayLabel,
              value: _formatValue(value, mapping.formatter),
              sort: 0, // 默认排序值
            ),
          );
        }
      }
    });

    return ModuleData(
      moduleType: 'main_table',
      data: {'fields': fields, 'showBorder': data['showBorder'] ?? true},
    );
  }

  /// 适配子表数据
  ModuleData _adaptSubTableData(List<dynamic> details) {
    return _adaptGenericTableData(details, 'sub_table', 'sub_table');
  }

  /// 格式化值
  String _formatValue(dynamic value, String? formatter) {
    if (formatter == null) return value.toString();

    switch (formatter) {
      case 'currency':
        return '¥${value.toString()}';
      case 'date':
        return value.toString(); // 可以添加日期格式化逻辑
      default:
        return value.toString();
    }
  }

  /// 适配审批记录数据
  ModuleData _adaptApprovalData(List<dynamic> approvals) {
    return _adaptGenericTableData(approvals, 'approval', 'approval');
  }

  /// 适配页脚数据
  ModuleData _adaptFooterData(Map<String, dynamic> footerData) {
    final List<TableField> fields = [];

    footerData.forEach((key, value) {
      if (value != null) {
        fields.add(
          TableField(
            label: _getDisplayLabel(key),
            value: value.toString(),
            sort: 0, // 默认排序值
          ),
        );
      }
    });

    return ModuleData(
      moduleType: 'footer',
      data: {'fields': fields, 'showBorder': footerData['showBorder'] ?? true},
    );
  }

  /// 获取显示标签
  String _getDisplayLabel(String key) {
    // 可以根据需要扩展这个映射
    switch (key) {
      case 'preparedBy':
        return '制单人';
      case 'checkedBy':
        return '审核人';
      case 'approvedBy':
        return '批准人';
      case 'printDate':
        return '打印日期';
      default:
        return key;
    }
  }

  /// 获取模块的必需字段
  String? _getRequiredFieldForModule(String moduleType) {
    switch (moduleType) {
      case 'logo':
        return 'logoUrl';
      case 'title':
        return 'titles';
      case 'main_table':
        return 'mainData';
      case 'sub_table':
        return 'details';
      case 'approval':
        return 'approvals';
      case 'footer':
        return 'footerData';
      default:
        return null;
    }
  }

  /// 通用表格数据适配方法
  ModuleData _adaptGenericTableData(
    List<dynamic> dataList,
    String moduleType,
    String title,
  ) {
    if (dataList.isEmpty) {
      return ModuleData(
        moduleType: moduleType,
        data: {'headers': <String>[], 'rows': <List<String>>[], 'title': title},
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

    return ModuleData(
      moduleType: moduleType,
      data: {
        'headers': headers,
        'rows': rows,
        'title': title,
        'columnWidths': List.filled(headers.length, 1.0 / headers.length),
      },
    );
  }
}
