// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf_export_print/pdf_export_print.dart' as pw;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Export Print Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PDFExamplePage(),
    );
  }
}

class PDFExamplePage extends StatefulWidget {
  const PDFExamplePage({super.key});

  @override
  State<PDFExamplePage> createState() => _PDFExamplePageState();
}

class _PDFExamplePageState extends State<PDFExamplePage> {
  bool _isGenerating = false;
  late pw.TypeSafeDataAdapter _adapter;
  late pw.PDFConfig _config;

  // 模块显示控制
  bool _showLogo = true;
  bool _showTitle = true;
  bool _showMainTable = true;
  bool _showSubTable = true;
  bool _showApproval = true;
  bool _showFooter = true;

  // 边框显示控制
  bool _globalBorder = true;
  bool _mainTableBorder = true;
  bool _mainTableInnerBorder = true;
  bool _subTableBorder = true;
  bool _approvalBorder = true;
  bool _footerBorder = true;

  // 页面方向控制
  pw.PageOrientation _orientation = pw.PageOrientation.portrait;

  @override
  void initState() {
    super.initState();
    _initializeAdapter();
  }

  /// 初始化适配器
  void _initializeAdapter() {
    // 使用自定义配置
    _adapter = pw.TypeSafeDataAdapter(config: _createCustomConfig());

    _config = pw.PDFConfig.builder()
        .pageSize(pw.PdfPageFormat.a4)
        .withOrientation(_orientation)
        .margins(pw.EdgeInsets.all(20))
        .build();
  }

  /// 创建自定义配置
  pw.DataAdapterConfig _createCustomConfig() {
    // 使用增强配置，支持全局映射和模块特定映射
    final customFieldLabels = pw.FieldLabelConfig.enhanced(
      // 全局字段映射
      globalMappings: {
        // 主表字段
        'name': '员工姓名',
        'age': '年龄',
        'department': '所属部门',
        'position': '岗位职务',
        'email': '邮箱地址',
        'phone': '联系电话',
        'salary': '薪资',
        'description': '工作描述',
        'city': '城市',

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

        // 通用子表字段
        'projectName': '项目名称',
        'startDate': '开始时间',
        'endDate': '结束时间',
        'status': '项目状态',
        'evaluation': '项目评价',

        // 模块标题
        pw.ModuleType.subTable.value: '子表模块',
        'testDetails': '测试详情',
        'approval': '审批记录',
        'footer': '页脚模块',
      },
      // 模块特定映射
      moduleMappings: {
        // 测试详情模块的特定字段标签
        'testDetails': {
          'testName': '测试名称',
          'testType': '测试类型',
          'testResult': '测试结果',
          'testDate': '测试日期',
          'testDuration': '测试时长',
          'docNo': '测试编号', // 与主表的docNo区分
          'remarks': '测试备注', // 与主表的remarks区分
        },
        // 月度计划详情模块的特定字段标签
        'monthPlanDetails': {
          'docNo': '计划编号', // 与主表的docNo区分
          'remarks': '计划备注', // 与主表的remarks区分
          'planDate': '计划日期',
          'planAmount': '计划金额',
        },
      },
    );

    // 自定义模块配置 - 使用具体的配置类型
    final customModuleConfigs = <pw.ModuleType, pw.AdapterModuleConfig>{
      pw.ModuleType.logo: const pw.AdapterModuleConfig(
        moduleType: pw.ModuleType.logo,
        moduleConfig: pw.LogoConfig(
          defaultWidth: pw.LogoConstants.defaultWidth,
          defaultHeight: pw.LogoConstants.defaultHeight,
          bottomSpacing: pw.LogoConstants.defaultBottomSpacing,
          enabled: true, // 控制模块是否参与PDF生成
          priority: 1, // 数值越小优先级越高，控制在PDF中的显示顺序
          required: false, // 数据验证时是否必须提供该模块的数据
        ),
      ),
      pw.ModuleType.title: const pw.AdapterModuleConfig(
        moduleType: pw.ModuleType.title,
        moduleConfig: pw.TitleConfig(
          topSpacing: 5.0,
          bottomSpacing: 15.0,
          titleSpacing: 5.0,
          color: 'red',
          enabled: true, // 启用标题模块
          priority: 2, // 在Logo之后显示
          required: true, // 必须提供标题数据，否则验证失败
        ),
      ),
      pw.ModuleType.mainTable: const pw.AdapterModuleConfig(
        moduleType: pw.ModuleType.mainTable,
        fieldConfigs: [
          pw.FieldConfig(fieldKey: 'position', widthPercent: 0.33, sort: 1),
          pw.FieldConfig(fieldKey: 'name', widthPercent: 1, sort: 2),
          pw.FieldConfig(fieldKey: 'description', widthPercent: 0.67, sort: 3),
          pw.FieldConfig(fieldKey: 'department', widthPercent: 0.33, sort: 4),
          pw.FieldConfig(fieldKey: 'email', widthPercent: 1, sort: 5),
        ],
        moduleConfig: pw.MainTableConfig(
          showBorder: true,
          showInnerBorder: true,
          cellPadding: pw.EdgeInsets.all(4),
          fieldsPerRow: 3,
          enabled: true,
          priority: 3, // 在标题之后显示
          required: false,
        ),
      ),
      pw.ModuleType.subTable: const pw.AdapterModuleConfig(
        moduleType: pw.ModuleType.subTable,
        fieldConfigs: [
          pw.FieldConfig(fieldKey: 'projectName', widthPercent: 0.4, sort: 1),
          pw.FieldConfig(fieldKey: 'status', widthPercent: 0.2, sort: 2),
          pw.FieldConfig(fieldKey: 'startDate', widthPercent: 0.2, sort: 3),
          pw.FieldConfig(fieldKey: 'endDate', widthPercent: 0.2, sort: 4),
          // 保留图片字段配置
          pw.FieldConfig(fieldKey: '项目', widthPercent: 0.25, sort: 5),
          pw.FieldConfig(fieldKey: '图片', widthPercent: 0.2, sort: 6),
          pw.FieldConfig(fieldKey: '状态', widthPercent: 0.15, sort: 7),
          pw.FieldConfig(fieldKey: '进度', widthPercent: 0.1, sort: 8),
          pw.FieldConfig(fieldKey: '负责人', widthPercent: 0.15, sort: 9),
          pw.FieldConfig(fieldKey: '开始时间', widthPercent: 0.35, sort: 10),
          // evaluation 字段自动分配剩余空间
        ],
        moduleConfig: pw.SubTableConfig(
          showBorder: true,
          cellPadding: pw.EdgeInsets.all(4),
          headerHeight: 25.0,
          dataAlignment: pw.Alignment.center,
          enabled: true, // 启用子表模块
          priority: 4,
          required: false,
        ),
      ),
      pw.ModuleType.approval: const pw.AdapterModuleConfig(
        moduleType: pw.ModuleType.approval,
        fieldConfigs: [
          pw.FieldConfig(fieldKey: 'nodeName', widthPercent: 0.25, sort: 1),
          pw.FieldConfig(fieldKey: 'approver', widthPercent: 0.20, sort: 2),
          pw.FieldConfig(fieldKey: 'approveTime', widthPercent: 0.25, sort: 3),
          pw.FieldConfig(fieldKey: 'signature', widthPercent: 0.15, sort: 4),
          pw.FieldConfig(fieldKey: 'opinion', widthPercent: 0.15, sort: 5),
          // 其他字段自动分配剩余空间
        ],
        moduleConfig: pw.SubTableConfig(
          showBorder: true,
          cellPadding: pw.EdgeInsets.all(4),
          headerHeight: 25.0,
          defaultColumnWidths: pw.SubTableConfig.approvalDefaultColumnWidths,
          dataAlignment: pw.Alignment.center,
          enabled: true,
          priority: 5,
          required: false,
        ),
      ),
      pw.ModuleType.footer: const pw.AdapterModuleConfig(
        moduleType: pw.ModuleType.footer,
        fieldConfigs: [
          pw.FieldConfig(fieldKey: 'totalAmount', widthPercent: 0.67, sort: 1),
          pw.FieldConfig(fieldKey: 'createDate', widthPercent: 0.33, sort: 2),
        ],
        moduleConfig: pw.FooterConfig(
          fieldsPerRow: 3,
          showBorder: true,
          showInnerBorder: false,
          cellPadding: pw.EdgeInsets.all(4),
          enabled: true,
          priority: 6,
          required: false,
        ),
      ),
    };

    // 扩展的模块描述符集合（支持自定义模块）
    final customModuleDescriptors = <pw.ModuleDescriptor>{
      // 标准模块描述符（使用静态常量）
      pw.ModuleDescriptor.logo.copyWith(
        data: {
          'logoUrl': 'https://picsum.photos/100/50?random=1',
          'width': 100.0,
          'height': 50.0,
        },
      ),
      pw.ModuleDescriptor.title.copyWith(
        data: {
          'titles': ['示例文档', '副标题'],
          'color': 'blue',
          'alignment': 'center',
        },
      ),
      pw.ModuleDescriptor.mainTable.copyWith(
        data: {
          'name': '张三',
          'age': 28,
          'city': '北京',
          'email': 'zhangsan@example.com',
          'department': '技术部',
          'position': '高级工程师',
          'description': '软件工程师',
        },
      ),
      pw.ModuleDescriptor.subTable.copyWith(
        data: [
          {
            'projectName': 'PDF导出系统',
            'startDate': '2024-01-01',
            'endDate': '2024-03-31',
            'status': '已完成',
            'evaluation': '优秀',
            // 保留图片展示功能
            '项目': 'Flutter PDF 组件',
            '图片': 'https://picsum.photos/200/150?random=1',
            '状态': '已发布',
            '进度': '100%',
            '负责人': '张三',
            '开始时间': '2024-01-01',
          },
          {
            'projectName': '用户管理平台',
            'startDate': '2024-04-01',
            'endDate': '2024-06-30',
            'status': '进行中',
            'evaluation': '良好',
            // 保留图片展示功能
            '项目': 'PDF 预览功能',
            '图片': 'https://picsum.photos/200/150?random=2',
            '状态': '开发中',
            '进度': '80%',
            '负责人': '李四',
            '开始时间': '2024-04-01',
          },
          {
            'projectName': '数据分析系统',
            'startDate': '2024-07-01',
            'endDate': '2024-09-30',
            'status': '计划中',
            'evaluation': '一般',
          },
          {
            'projectName': '移动应用开发',
            'startDate': '2024-10-01',
            'endDate': '2024-12-31',
            'status': '已完成',
            'evaluation': '优秀',
          },
        ],
      ),
      pw.ModuleDescriptor.approval.copyWith(
        data: [
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
          {
            'nodeName': '财务审批',
            'approver': '赵六',
            'signature': '赵六',
            'approveTime': '2024-01-16 10:15:00',
            'opinion': '财务审核通过',
          },
        ],
      ),
      pw.ModuleDescriptor.footer.copyWith(
        data: {'totalAmount': '18000元', 'createDate': '2024-01-16'},
      ),

      // 自定义模块描述符（调用方创建）
      const pw.ModuleDescriptor(pw.ModuleType.subTable, 'testDetails', [
        {
          'testName': '单元测试',
          'testType': '自动化测试',
          'testResult': '通过',
          'testDate': '2024-01-10',
          'testDuration': '2小时',
        },
        {
          'testName': '集成测试',
          'testType': '手动测试',
          'testResult': '通过',
          'testDate': '2024-01-15',
          'testDuration': '4小时',
        },
        {
          'testName': '性能测试',
          'testType': '压力测试',
          'testResult': '待优化',
          'testDate': '2024-01-20',
          'testDuration': '6小时',
        },
      ]),
    };

    return pw.DataAdapterConfig(
      fieldLabelConfig: customFieldLabels,
      moduleConfigs: customModuleConfigs,
      moduleDescriptors: customModuleDescriptors,
    );
  }

  /// 演示多子表标题配置功能
  ///
  /// 展示如何为不同的子表实例设置不同的标题和数据源：
  /// 1. 默认子表模块：数据源 'details' -> 标题 '项目详情'
  /// 2. 自定义子表模块：数据源 'testDetails' -> 标题 '测试详情表'
  /// 3. 审批记录模块：数据源 'approvals' -> 标题 '审批记录'
  void _demonstrateMultiSubTableTitles() {
    print('=== 多子表标题配置演示 ===');
    print('');
    print('配置的标题映射：');
    print('  sub_table -> 项目详情 (默认子表，使用details数据)');
    print('  testDetails -> 测试详情表 (自定义子表，使用testDetails数据)');
    print('  approval -> 审批记录 (审批模块，使用approvals数据)');
    print('');
    print('数据源配置：');
    print('  1. details: [项目数据] -> SubTableModule()');
    print(
      '  2. testDetails: [测试数据] -> SubTableModule(moduleId: "testDetails")',
    );
    print('  3. approvals: [审批数据] -> SubTableModule(moduleId: "approval")');
    print('');
    print('工作原理：');
    print('  1. 系统首先尝试使用moduleId作为数据键查找数据');
    print('  2. 如果找到，直接使用该数据进行适配');
    print('  3. 同时使用moduleId作为标题查找键');
    print('  4. 实现不同子表使用不同数据源和标题');
    print('');
  }

  /// 更新适配器配置以反映当前的控制面板设置
  void _updateAdapterConfig() {
    // 根据当前控制面板设置更新模块配置
    final updatedModuleConfigs =
        Map<pw.ModuleType, pw.AdapterModuleConfig>.from(
          _adapter.config.moduleConfigs,
        );

    // 更新各模块的enabled状态
    if (updatedModuleConfigs.containsKey(pw.ModuleType.logo)) {
      final logoConfig = updatedModuleConfigs[pw.ModuleType.logo]!;
      updatedModuleConfigs[pw.ModuleType.logo] = pw.AdapterModuleConfig(
        moduleType: logoConfig.moduleType,
        moduleConfig: (logoConfig.moduleConfig as pw.LogoConfig).copyWith(
          enabled: _showLogo,
        ),
        fieldConfigs: logoConfig.fieldConfigs,
      );
    }

    if (updatedModuleConfigs.containsKey(pw.ModuleType.title)) {
      final titleConfig = updatedModuleConfigs[pw.ModuleType.title]!;
      updatedModuleConfigs[pw.ModuleType.title] = pw.AdapterModuleConfig(
        moduleType: titleConfig.moduleType,
        moduleConfig: (titleConfig.moduleConfig as pw.TitleConfig).copyWith(
          enabled: _showTitle,
        ),
        fieldConfigs: titleConfig.fieldConfigs,
      );
    }

    if (updatedModuleConfigs.containsKey(pw.ModuleType.mainTable)) {
      final mainTableConfig = updatedModuleConfigs[pw.ModuleType.mainTable]!;
      updatedModuleConfigs[pw.ModuleType.mainTable] = pw.AdapterModuleConfig(
        moduleType: mainTableConfig.moduleType,
        moduleConfig: (mainTableConfig.moduleConfig as pw.MainTableConfig)
            .copyWith(
              enabled: _showMainTable,
              showBorder: _mainTableBorder,
              showInnerBorder: _mainTableInnerBorder,
            ),
        fieldConfigs: mainTableConfig.fieldConfigs,
      );
    }

    if (updatedModuleConfigs.containsKey(pw.ModuleType.subTable)) {
      final subTableConfig = updatedModuleConfigs[pw.ModuleType.subTable]!;
      updatedModuleConfigs[pw.ModuleType.subTable] = pw.AdapterModuleConfig(
        moduleType: subTableConfig.moduleType,
        moduleConfig: (subTableConfig.moduleConfig as pw.SubTableConfig)
            .copyWith(enabled: _showSubTable, showBorder: _subTableBorder),
        fieldConfigs: subTableConfig.fieldConfigs,
      );
    }

    if (updatedModuleConfigs.containsKey(pw.ModuleType.approval)) {
      final approvalConfig = updatedModuleConfigs[pw.ModuleType.approval]!;
      updatedModuleConfigs[pw.ModuleType.approval] = pw.AdapterModuleConfig(
        moduleType: approvalConfig.moduleType,
        moduleConfig: (approvalConfig.moduleConfig as pw.SubTableConfig)
            .copyWith(enabled: _showApproval, showBorder: _approvalBorder),
        fieldConfigs: approvalConfig.fieldConfigs,
      );
    }

    if (updatedModuleConfigs.containsKey(pw.ModuleType.footer)) {
      final footerConfig = updatedModuleConfigs[pw.ModuleType.footer]!;
      updatedModuleConfigs[pw.ModuleType.footer] = pw.AdapterModuleConfig(
        moduleType: footerConfig.moduleType,
        moduleConfig: (footerConfig.moduleConfig as pw.FooterConfig).copyWith(
          enabled: _showFooter,
          showBorder: _footerBorder,
        ),
        fieldConfigs: footerConfig.fieldConfigs,
      );
    }

    // 创建新的配置
    final updatedConfig = pw.DataAdapterConfig(
      fieldLabelConfig: _adapter.config.fieldLabelConfig,
      moduleConfigs: updatedModuleConfigs,
      moduleDescriptors: _adapter.config.moduleDescriptors,
    );

    // 重新创建适配器
    _adapter = pw.TypeSafeDataAdapter(config: updatedConfig);
  }

  // 水印配置控制
  bool _watermarkEnabled = false;
  pw.WatermarkType _watermarkType = pw.WatermarkType.text;
  String _watermarkContent = 'DRAFT';
  pw.WatermarkPosition _watermarkPosition = pw.WatermarkPosition.center;
  pw.WatermarkMode _watermarkMode = pw.WatermarkMode.background;
  double _watermarkOpacity = 0.5;
  double _watermarkRotation = 0.0;
  pw.PdfColor? _watermarkTextColor;

  /// 生成并预览PDF
  Future<void> _generatePDF() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // 演示多子表标题配置功能
      _demonstrateMultiSubTableTitles();

      // 更新适配器配置以反映当前控制面板设置
      _updateAdapterConfig();

      // 数据现在来自 ModuleDescriptor，无需单独创建
      print('📊 使用 ModuleDescriptor 中的内置数据');

      // 创建PDF构建器
      final pdfBuilder = pw.PDFPrintBuilder()
          .withConfig(_config)
          .withDataAdapter(_adapter);

      // TypeSafe适配器会自动根据配置添加模块，无需手动添加
      print('📄 开始生成PDF文档...');
      final pdfDocument = await pdfBuilder.build();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF生成失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Export Print 示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 控制面板
              _buildControlPanel(),
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generatePDF,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.create),
                label: Text(_isGenerating ? '生成中...' : '生成PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 16),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '功能特性',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• 模块化设计，支持Logo、标题、主表、子表、审批、页脚模块'),
                      Text('• 高度可配置的样式和布局，支持跨列合并'),
                      Text('• 灵活的数据适配机制，自动处理复杂数据结构'),
                      Text('• 智能分页处理，支持大数据集自动分页'),
                      Text('• 支持自定义主题和企业级样式定制'),
                      Text('• 完整的审批流程展示和页脚信息管理'),
                      Text('• 🆕 子表图片展示功能，支持网络图片自适应缩放'),
                      Text('• 🆕 TypeSafe数据适配器，提供类型安全的数据处理'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '控制面板',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 模块显示控制
            const Text(
              '模块显示控制',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildModuleSwitch('Logo模块', _showLogo, (value) {
                  setState(() => _showLogo = value);
                }),
                _buildModuleSwitch('标题模块', _showTitle, (value) {
                  setState(() => _showTitle = value);
                }),
                _buildModuleSwitch('主表模块', _showMainTable, (value) {
                  setState(() => _showMainTable = value);
                }),
                _buildModuleSwitch('子表模块', _showSubTable, (value) {
                  setState(() => _showSubTable = value);
                }),
                _buildModuleSwitch('审批模块', _showApproval, (value) {
                  setState(() => _showApproval = value);
                }),
                _buildModuleSwitch('页脚模块', _showFooter, (value) {
                  setState(() => _showFooter = value);
                }),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 边框显示控制
            const Text(
              '边框显示控制',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildModuleSwitch('全局边框', _globalBorder, (value) {
                  setState(() => _globalBorder = value);
                }),
                _buildModuleSwitch('主表边框', _mainTableBorder, (value) {
                  setState(() => _mainTableBorder = value);
                }),
                _buildModuleSwitch('主表内边框', _mainTableInnerBorder, (value) {
                  setState(() => _mainTableInnerBorder = value);
                }),
                _buildModuleSwitch('子表边框', _subTableBorder, (value) {
                  setState(() => _subTableBorder = value);
                }),
                _buildModuleSwitch('审批边框', _approvalBorder, (value) {
                  setState(() => _approvalBorder = value);
                }),
                _buildModuleSwitch('页脚边框', _footerBorder, (value) {
                  setState(() => _footerBorder = value);
                }),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 页面方向控制
            const Text(
              '页面方向控制',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButton<pw.PageOrientation>(
              value: _orientation,
              onChanged: (pw.PageOrientation? newValue) {
                if (newValue != null) {
                  setState(() => _orientation = newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: pw.PageOrientation.portrait,
                  child: Text('Portrait（竖屏）'),
                ),
                DropdownMenuItem(
                  value: pw.PageOrientation.landscape,
                  child: Text('Landscape（横屏）'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 水印配置控制
            _buildWatermarkControls(),
          ],
        ),
      ),
    );
  }

  /// 构建模块开关
  Widget _buildModuleSwitch(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SizedBox(
      width: 120,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: value, onChanged: onChanged),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  /// 构建水印配置控制
  Widget _buildWatermarkControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '水印配置',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // 水印启用开关
        _buildModuleSwitch('启用水印', _watermarkEnabled, (value) {
          setState(() => _watermarkEnabled = value);
        }),

        if (_watermarkEnabled) ...[
          const SizedBox(height: 16),

          // 水印类型选择
          Row(
            children: [
              const Text('水印类型：'),
              const SizedBox(width: 8),
              DropdownButton<pw.WatermarkType>(
                value: _watermarkType,
                onChanged: (pw.WatermarkType? newValue) {
                  if (newValue != null) {
                    setState(() => _watermarkType = newValue);
                  }
                },
                items: pw.WatermarkType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getWatermarkTypeDisplayName(type)),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 水印内容输入
          Row(
            children: [
              const Text('水印内容：'),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _watermarkContent),
                  onChanged: (value) {
                    setState(() => _watermarkContent = value);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 水印位置选择
          Row(
            children: [
              const Text('水印位置：'),
              const SizedBox(width: 8),
              DropdownButton<pw.WatermarkPosition>(
                value: _watermarkPosition,
                onChanged: (pw.WatermarkPosition? newValue) {
                  if (newValue != null) {
                    setState(() => _watermarkPosition = newValue);
                  }
                },
                items: pw.WatermarkPosition.values.map((position) {
                  return DropdownMenuItem(
                    value: position,
                    child: Text(_getWatermarkPositionDisplayName(position)),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 水印模式选择
          Row(
            children: [
              const Text('水印模式：'),
              const SizedBox(width: 8),
              DropdownButton<pw.WatermarkMode>(
                value: _watermarkMode,
                onChanged: (pw.WatermarkMode? newValue) {
                  if (newValue != null) {
                    setState(() => _watermarkMode = newValue);
                  }
                },
                items: pw.WatermarkMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(_getWatermarkModeDisplayName(mode)),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 水印颜色选择
          Row(
            children: [
              const Text('水印颜色：'),
              const SizedBox(width: 8),
              DropdownButton<pw.PdfColor?>(
                value: _watermarkTextColor,
                onChanged: (pw.PdfColor? newValue) {
                  setState(() => _watermarkTextColor = newValue);
                },
                items: [
                  const DropdownMenuItem(value: null, child: Text('默认灰色')),
                  DropdownMenuItem(
                    value: pw.PdfColors.red,
                    child: SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          Container(width: 16, height: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          const Text('红色'),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: pw.PdfColors.blue,
                    child: SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          Container(width: 16, height: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          const Text('蓝色'),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: pw.PdfColors.green,
                    child: SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          Container(width: 16, height: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text('绿色'),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: pw.PdfColors.orange,
                    child: SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          const Text('橙色'),
                        ],
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: pw.PdfColors.purple,
                    child: SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 4),
                          const Text('紫色'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 水印透明度滑块
          Row(
            children: [
              const Text('透明度：'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _watermarkOpacity,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  label: _watermarkOpacity.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => _watermarkOpacity = value);
                  },
                ),
              ),
              Text(_watermarkOpacity.toStringAsFixed(1)),
            ],
          ),

          // 水印旋转角度滑块
          Row(
            children: [
              const Text('旋转角度：'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _watermarkRotation,
                  min: -3.14159,
                  max: 3.14159,
                  divisions: 12,
                  label: '${(_watermarkRotation * 180 / 3.14159).round()}°',
                  onChanged: (value) {
                    setState(() => _watermarkRotation = value);
                  },
                ),
              ),
              Text('${(_watermarkRotation * 180 / 3.14159).round()}°'),
            ],
          ),
        ],
      ],
    );
  }

  /// 获取水印类型显示名称
  String _getWatermarkTypeDisplayName(pw.WatermarkType type) {
    switch (type) {
      case pw.WatermarkType.text:
        return '文本水印';
      case pw.WatermarkType.image:
        return '图片水印';
    }
  }

  /// 获取水印位置显示名称
  String _getWatermarkPositionDisplayName(pw.WatermarkPosition position) {
    switch (position) {
      case pw.WatermarkPosition.topLeft:
        return '左上角';
      case pw.WatermarkPosition.topCenter:
        return '顶部居中';
      case pw.WatermarkPosition.topRight:
        return '右上角';
      case pw.WatermarkPosition.centerLeft:
        return '左侧居中';
      case pw.WatermarkPosition.center:
        return '正中央';
      case pw.WatermarkPosition.centerRight:
        return '右侧居中';
      case pw.WatermarkPosition.bottomLeft:
        return '左下角';
      case pw.WatermarkPosition.bottomCenter:
        return '底部居中';
      case pw.WatermarkPosition.bottomRight:
        return '右下角';
    }
  }

  /// 获取水印模式显示名称
  String _getWatermarkModeDisplayName(pw.WatermarkMode mode) {
    switch (mode) {
      case pw.WatermarkMode.background:
        return '背景水印';
      case pw.WatermarkMode.foreground:
        return '前景水印';
    }
  }
}
