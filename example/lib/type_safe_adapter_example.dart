// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:pdf_export_print/pdf_export_print.dart' as pdf;
import 'package:printing/printing.dart';

/// 类型安全数据适配器使用示例
///
/// 展示如何使用新的类型安全适配器替代硬编码的SimpleDataAdapter
class TypeSafeAdapterExample extends StatefulWidget {
  const TypeSafeAdapterExample({super.key});

  @override
  State<TypeSafeAdapterExample> createState() => _TypeSafeAdapterExampleState();
}

class _TypeSafeAdapterExampleState extends State<TypeSafeAdapterExample> {
  late pdf.TypeSafeDataAdapter _adapter;
  late pdf.PDFConfig _config;

  @override
  void initState() {
    super.initState();
    _initializeAdapter();
  }

  /// 初始化适配器
  void _initializeAdapter() {
    // 使用自定义配置（推荐方式）
    _adapter = pdf.TypeSafeDataAdapter(config: _createCustomConfig());

    // 注意：默认配置不包含字段映射，需要自定义
    // _adapter = TypeSafeDataAdapter(); // 字段标签将显示为原始键名

    _config = pdf.PDFConfig.builder()
        .withOrientation(pdf.PageOrientation.portrait)
        .pageSize(pdf.PdfPageFormat.a4)
        .margins(EdgeInsets.all(pdf.LayoutConstants.defaultMargin))
        .build();
  }

  /// 创建自定义配置示例
  pdf.DataAdapterConfig _createCustomConfig() {
    // 自定义字段标签映射 - 业务项目需要自定义所有用到的字段
    final customFieldLabels = pdf.FieldLabelConfig.custom({
      // 主表字段
      'name': '员工姓名',
      'age': '年龄',
      'department': '所属部门',
      'position': '岗位职务',
      'email': '邮箱地址',
      'phone': '联系电话',
      'salary': '薪资',
      'description': '工作描述',

      // 页脚字段
      'preparedBy': '制单人',
      'checkedBy': '审核人',
      'approvedBy': '批准人',
      'printDate': '打印日期',
      'version': '版本号',
      'pageCount': '页数',

      // 审批字段
      'nodeName': '审批节点',
      'approver': '审批人',
      'signature': '签名',
      'approveTime': '审批时间',
      'opinion': '审批意见',

      // 子表字段
      'projectName': '项目名称',
      'startDate': '开始时间',
      'endDate': '结束时间',
      'status': '项目状态',
      'evaluation': '项目评价',

      // 页脚字段
      'totalAmount': '总金额',
      'createDate': '创建日期',
      'creator': '创建人',

      // 模块标题
      'subTable': '项目详情',
      'approval': '审批记录',
    });

    // 自定义模块配置 - 详细说明各参数作用
    final customModuleConfigs = <pdf.ModuleTypes, pdf.AdapterModuleConfig>{
      pdf.ModuleTypes.logo: const pdf.AdapterModuleConfig(
        moduleType: pdf.ModuleTypes.logo,
        enabled: true, // 控制模块是否参与PDF生成
        priority: 1, // 数值越小优先级越高，控制在PDF中的显示顺序
        required: false, // 数据验证时是否必须提供该模块的数据
        customSettings: {
          // 使用常量替代硬编码数值
          'defaultWidth': pdf.LogoConstants.defaultWidth,
          'defaultHeight': pdf.LogoConstants.defaultHeight,
          'bottomSpacing': pdf.LogoConstants.defaultBottomSpacing,
        },
      ),
      pdf.ModuleTypes.title: const pdf.AdapterModuleConfig(
        moduleType: pdf.ModuleTypes.title,
        enabled: true, // 启用标题模块
        priority: 2, // 在Logo之后显示
        required: true, // 必须提供标题数据，否则验证失败
        customSettings: {
          // 使用常量和配置支持动态设置
          'topSpacing': pdf.TitleConstants.defaultTopSpacing,
          'bottomSpacing': pdf.TitleConstants.defaultBottomSpacing,
          'titleSpacing': pdf.TitleConstants.defaultTitleSpacing,
          'defaultColor': pdf.TitleConstants.defaultColor,
          'defaultAlignment': pdf.TitleConstants.defaultAlignment,
        },
      ),
      pdf.ModuleTypes.mainTable: const pdf.AdapterModuleConfig(
        moduleType: pdf.ModuleTypes.mainTable,
        enabled: true,
        priority: 3, // 在标题之后显示
        required: false,
        fieldConfigs: [
          pdf.FieldConfig(fieldKey: 'description', widthPercent: 0.67, sort: 2),
          pdf.FieldConfig(fieldKey: 'name', widthPercent: 0.33, sort: 3),
          pdf.FieldConfig(fieldKey: 'department', widthPercent: 0.33, sort: 1),
        ],
      ),
      pdf.ModuleTypes.subTable: const pdf.AdapterModuleConfig(
        moduleType: pdf.ModuleTypes.subTable,
        enabled: true, // 启用子表模块
        priority: 4,
        required: false,
        fieldConfigs: [
          pdf.FieldConfig(fieldKey: 'projectName', widthPercent: 0.4, sort: 1),
          pdf.FieldConfig(fieldKey: 'status', widthPercent: 0.2, sort: 2),
          pdf.FieldConfig(fieldKey: 'startDate', widthPercent: 0.2, sort: 3),
          pdf.FieldConfig(fieldKey: 'endDate', widthPercent: 0.2, sort: 4),
          // evaluation 字段自动分配剩余空间
        ],
        customSettings: {
          // 使用表格常量
          'cellPadding': pdf.TableConstants.defaultCellPadding,
          'headerHeight': pdf.TableConstants.defaultHeaderHeight,
          'rowHeight': pdf.TableConstants.defaultRowHeight,
        },
      ),
      pdf.ModuleTypes.approval: const pdf.AdapterModuleConfig(
        moduleType: pdf.ModuleTypes.approval,
        enabled: true,
        priority: 5,
        required: false,
        fieldConfigs: [
          pdf.FieldConfig(fieldKey: 'nodeName', widthPercent: 0.25, sort: 1),
          pdf.FieldConfig(fieldKey: 'approver', widthPercent: 0.20, sort: 2),
          pdf.FieldConfig(fieldKey: 'approveTime', widthPercent: 0.25, sort: 3),
          pdf.FieldConfig(fieldKey: 'signature', widthPercent: 0.15, sort: 4),
          pdf.FieldConfig(fieldKey: 'opinion', widthPercent: 0.15, sort: 5),
          // 其他字段自动分配剩余空间
        ],
        customSettings: {
          // 使用表格常量
          'cellPadding': pdf.TableConstants.defaultCellPadding,
          'headerHeight': pdf.TableConstants.defaultHeaderHeight,
          'rowHeight': pdf.TableConstants.defaultRowHeight,
        },
      ),
      pdf.ModuleTypes.footer: const pdf.AdapterModuleConfig(
        moduleType: pdf.ModuleTypes.footer,
        enabled: true,
        priority: 6,
        required: false,
        fieldConfigs: [
          pdf.FieldConfig(fieldKey: 'totalAmount', widthPercent: 0.67, sort: 1),
          pdf.FieldConfig(fieldKey: 'createDate', widthPercent: 0.33, sort: 2),
        ],
        customSettings: {
          // 页脚特有配置
          'fieldsPerRow': 3,
          'showBorder': true,
          'showInnerBorder': false,
          // 使用表格常量
          'cellPadding': pdf.TableConstants.defaultCellPadding,
        },
      ),
    };

    // 自定义数据键映射
    final customDataKeyMappings = <pdf.DataKeys, pdf.ModuleTypes>{
      pdf.DataKeys.logoUrl: pdf.ModuleTypes.logo,
      pdf.DataKeys.titles: pdf.ModuleTypes.title,
      pdf.DataKeys.mainData: pdf.ModuleTypes.mainTable,
      pdf.DataKeys.details: pdf.ModuleTypes.subTable,
      pdf.DataKeys.approvals: pdf.ModuleTypes.approval,
      pdf.DataKeys.footerData: pdf.ModuleTypes.footer,
    };

    return pdf.DataAdapterConfig(
      fieldLabelConfig: customFieldLabels,
      moduleConfigs: customModuleConfigs,
      dataKeyMappings: customDataKeyMappings,
    );
  }

  /// 创建测试数据
  Map<String, dynamic> _createTestData() {
    return {
      // 标题数据 - 使用新的TitleData格式
      pdf.DataKeys.titles.value: {
        'titles': ['员工信息表', '人事档案'],
        'color': 'blue',
        'alignment': 'center',
      },

      // Logo数据 - 使用新的LogoData格式
      pdf.DataKeys.logoUrl.value: {
        'logoUrl': 'https://example.com/logo.png',
        'width': pdf.LogoConstants.defaultWidth,
        'height': pdf.LogoConstants.defaultHeight,
      },

      pdf.DataKeys.mainData.value: {
        // 使用字符串键名
        'name': '张三',
        'age': 28,
        'department': '技术部',
        'position': '高级工程师',
        'email': 'zhangsan@example.com',
        'phone': '13800138000',
        'salary': 15000,
        'description': '负责核心业务系统开发和维护',
      },

      pdf.DataKeys.details.value: [
        {
          'projectName': 'PDF导出系统',
          'startDate': '2024-01-01',
          'endDate': '2024-03-31',
          'status': '已完成',
          'evaluation': '优秀',
        },
        {
          'projectName': '数据分析平台',
          'startDate': '2024-04-01',
          'endDate': '2024-06-30',
          'status': '进行中',
          'evaluation': '良好',
        },
      ],

      pdf.DataKeys.approvals.value: [
        {
          'nodeName': '申请',
          'approver': '李四',
          'signature': '李四',
          'approveTime': '2024-01-15 09:30:00',
          'opinion': '申请提交',
        },
        {
          'nodeName': '部门审批',
          'approver': '王五',
          'signature': '王五',
          'approveTime': '2024-01-15 14:20:00',
          'opinion': '同意',
        },
      ],

      pdf.DataKeys.footerData.value: {
        'preparedBy': '张三',
        'checkedBy': '李四',
        'approvedBy': '王五',
        'printDate': '2024-01-16',
        'version': 'v2.0',
        'pageCount': '1/1',
      },
    };
  }

  /// 生成PDF
  Future<void> _generatePDF() async {
    if (!mounted) return;

    try {
      final testData = _createTestData();
      print('📊 测试数据创建完成: ${testData.keys}');

      // 验证数据
      if (!_adapter.validateData(testData)) {
        print('❌ 数据验证失败');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('数据验证失败')));
        }
        return;
      }
      print('✅ 数据验证通过');

      // 创建PDF构建器
      final pdfBuilder = pdf.PDFPrintBuilder()
          .withConfig(_config)
          .withDataAdapter(_adapter);

      // 根据配置添加启用的模块
      print('🔧 开始添加PDF模块...');
      _addModulesBasedOnConfig(pdfBuilder);

      // 生成PDF文档
      print('📄 开始生成PDF文档...');
      final pdfDocument = await pdfBuilder.build(testData);
      print('✅ PDF文档生成完成');

      // 显示PDF预览
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfPreview(
              build: (format) => pdfDocument.save(),
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF生成失败：$e')));
      }
    }
  }

  /// 根据配置添加PDF模块
  void _addModulesBasedOnConfig(pdf.PDFPrintBuilder pdfBuilder) {
    // 获取适配器配置中的模块配置
    final moduleConfigs = _adapter.config.moduleConfigs;

    // 按优先级排序并添加启用的模块
    final sortedModules = moduleConfigs.entries.toList()
      ..sort((a, b) => a.value.priority.compareTo(b.value.priority));

    for (final entry in sortedModules) {
      final moduleType = entry.key;
      final moduleConfig = entry.value;

      if (!moduleConfig.enabled) {
        print('⏭️ 跳过禁用的模块: ${moduleType.value}');
        continue;
      }

      print('➕ 添加模块: ${moduleType.value} (优先级: ${moduleConfig.priority})');

      switch (moduleType) {
        case pdf.ModuleTypes.logo:
          pdfBuilder.addModule(pdf.LogoModule());
          break;
        case pdf.ModuleTypes.title:
          pdfBuilder.addModule(pdf.TitleModule());
          break;
        case pdf.ModuleTypes.mainTable:
          pdfBuilder.addModule(pdf.MainTableModule());
          break;
        case pdf.ModuleTypes.subTable:
          pdfBuilder.addModule(pdf.SubTableModule());
          break;
        case pdf.ModuleTypes.approval:
          // 审批记录也使用SubTableModule，通过配置和数据内容区分
          pdfBuilder.addModule(
            pdf.SubTableModule(
              config: _createApprovalSubTableConfig(),
              moduleId: 'approval', // 指定正确的moduleId
            ),
          );
          break;
        case pdf.ModuleTypes.footer:
          pdfBuilder.addModule(pdf.FooterModule());
          break;
      }
    }

    final addedModules = pdfBuilder.getModules();
    print('✅ 总共添加了 ${addedModules.length} 个模块');
  }

  /// 创建审批记录专用的SubTableConfig
  pdf.SubTableConfig _createApprovalSubTableConfig() {
    return pdf.SubTableConfig(
      showBorder: true,
      headerAlignment: pdf.Alignment.center,
      dataAlignment: pdf.Alignment.centerLeft,
      showTitle: true,
      titleAlignment: pdf.Alignment.centerLeft,
      titlePadding: 5.0,
      topSpacing: 5.0,
      bottomSpacing: 0.0,
      // 使用审批记录的默认列宽配置
      defaultColumnWidths: pdf.SubTableConfig.approvalDefaultColumnWidths,
      moduleConfig: pdf.ModuleConfig(priority: 50), // 审批记录的优先级
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('类型安全适配器示例'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '类型安全数据适配器特性：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard('🔒 类型安全', '使用枚举替代硬编码字符串，提供编译时检查', Colors.green),
            const SizedBox(height: 8),
            _buildFeatureCard('⚙️ 配置驱动', '集中管理字段映射和模块配置，易于维护', Colors.blue),
            const SizedBox(height: 8),
            _buildFeatureCard('🔧 易于扩展', '通过配置轻松添加新字段和模块类型', Colors.orange),
            const SizedBox(height: 8),
            _buildFeatureCard('🔄 向后兼容', '不影响现有代码，支持渐进式迁移', Colors.purple),
            const SizedBox(height: 32),
            const Text(
              '支持的模块类型：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _adapter.getSupportedModules().map((module) {
                return Chip(
                  label: Text(module),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generatePDF,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('生成PDF示例', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建特性卡片
  Widget _buildFeatureCard(String title, String description, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
