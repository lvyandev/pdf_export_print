// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf_export_print/pdf_export_print.dart' as pw;
import 'type_safe_adapter_example.dart';

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
  pw.PageOrientation _orientation = pw.PageOrientation.landscape;

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
      // 创建示例数据
      final sampleData = {
        'logoUrl': 'https://www.baidu.com/img/bdlogo.png',
        'titles': ['Flutter PDF 示例文档', '完整功能演示'],
        'mainData': {
          'name': '张三',
          'age': '30',
          'city': '北京',
          'phone': '13800138000',
          'email': 'zhangsan@example.com',
          'department': '技术部',
          'salary': '¥1,500',
          'position': '高级工程师\n啊\n啊啊\n啊啊\n啊啊\n啊啊\n啊\n啊啊\n啊啊',
          'description': '这是一个跨列显示的长文本描述，用于演示主表模块的跨列功能。这是一个跨列显示的长文本描述',
        },
        'details': [
          // 使用for循环生成50条测试数据
          for (int i = 1; i <= 50; i++)
            {
              '项目':
                  '项目${String.fromCharCode(64 + (i % 26) + 1)}${i > 26 ? (i ~/ 26).toString() : ''}',
              '状态': ['进行中', '已完成', '计划中', '暂停', '测试中'][(i - 1) % 5],
              '进度': '${(i * 2) % 101}%',
              '负责人': [
                '张三',
                '李四',
                '王五',
                '赵六',
                '钱七',
                '孙八',
                '周九',
                '吴十',
              ][(i - 1) % 8],
              '开始时间':
                  '2024-${(i % 12 + 1).toString().padLeft(2, '0')}-${(i % 28 + 1).toString().padLeft(2, '0')}',
              '预算': '¥${(i * 1000 + 5000).toString()}',
              '部门': ['技术部', '产品部', '运营部', '市场部', '财务部'][(i - 1) % 5],
            },
        ],
        'approvals': [
          {
            'nodeName': '申请',
            'approver': '张三',
            'signature': '张三',
            'approveTime': '2024-01-15 09:30:00',
            'opinion': '申请提交',
          },
          {
            'nodeName': '部门审批',
            'approver': '李四',
            'signature': '李四',
            'approveTime': '2024-01-15 14:20:00',
            'opinion': '同意',
          },
          {
            'nodeName': '财务审批',
            'approver': '王五',
            'signature': '王五',
            'approveTime': '2024-01-16 10:15:00',
            'opinion': '财务审核通过',
          },
        ],
        'footerData': {
          'preparedBy': '张三',
          'checkedBy': '李四',
          'approvedBy': '王五',
          'printDate': '2024-01-16',
          'version': 'v1.0',
          'pageCount': '1/1',
        },
      };

      // 创建数据适配器
      final adapter = SimpleDataAdapter();

      // 创建水印配置
      final watermarkConfig = pw.WatermarkConfig(
        enabled: _watermarkEnabled,
        type: _watermarkType,
        content: _watermarkContent,
        position: _watermarkPosition,
        mode: _watermarkMode,
        opacity: _watermarkOpacity,
        rotation: _watermarkRotation,
        textColor: _watermarkTextColor,
      );

      // 创建PDF配置
      final config = pw.PDFConfig.builder()
          .withOrientation(_orientation)
          .watermark(watermarkConfig)
          .build();

      // 创建PDF构建器
      final pdfBuilder = pw.PDFPrintBuilder()
          .withConfig(config)
          .withDataAdapter(adapter);

      // 根据控制选项添加模块
      if (_showLogo) {
        pdfBuilder.addModule(pw.LogoModule());
      }
      if (_showTitle) {
        pdfBuilder.addModule(pw.TitleModule());
      }
      if (_showMainTable) {
        pdfBuilder.addModule(
          pw.MainTableModule(
            config: pw.MainTableConfig(
              showBorder: _globalBorder && _mainTableBorder,
              showInnerBorder: _globalBorder && _mainTableInnerBorder,
            ),
          ),
        );
      }
      if (_showSubTable) {
        pdfBuilder.addModule(
          pw.SubTableModule(
            config: pw.SubTableConfig(
              showBorder: _globalBorder && _subTableBorder,
            ),
          ),
        );
      }
      if (_showApproval) {
        // 使用SubTableModule处理审批记录，通过配置区分
        pdfBuilder.addModule(
          pw.SubTableModule(
            config: pw.SubTableConfig(
              showBorder: _globalBorder && _approvalBorder,
              showTitle: true,
              titleAlignment: pw.Alignment.centerLeft,
              titlePadding: 5.0,
              topSpacing: 5.0,
              bottomSpacing: 0.0,
              // 使用审批记录的默认列宽配置
              defaultColumnWidths:
                  pw.SubTableConfig.approvalDefaultColumnWidths,
              moduleConfig: pw.ModuleConfig(priority: 50),
            ),
            moduleId: 'approval', // 指定正确的moduleId
          ),
        );
      }
      if (_showFooter) {
        pdfBuilder.addModule(
          pw.FooterModule(
            config: pw.FooterConfig(showBorder: _globalBorder && _footerBorder),
          ),
        );
      }

      // 生成PDF
      final pdfDocument = await pdfBuilder.build(sampleData);

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
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TypeSafeAdapterExample(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('TypeSafe适配器示例'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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

/// 简单的数据适配器实现
///
/// ⚠️ **已更新**: 现在基于 TypeSafeDataAdapter 实现，提供类型安全的数据适配。
/// 这个实现主要用于向后兼容，新项目建议直接使用 TypeSafeDataAdapter。
class SimpleDataAdapter extends pw.DataAdapter {
  late final pw.TypeSafeDataAdapter _typeSafeAdapter;

  SimpleDataAdapter() {
    // 创建字段标签配置
    final fieldLabels = pw.FieldLabelConfig.custom({
      // 主表字段标签
      'name': '姓名',
      'position': '职位',
      'department': '部门',
      'salary': '薪资',
      'email': '邮箱',
      'phone': '电话',
      'hireDate': '入职日期',
      'status': '状态',

      // 子表字段标签
      'project': '项目',
      'progress': '进度',
      'responsible': '负责人',
      'startDate': '开始时间',
      'budget': '预算',

      // 审批字段标签
      'nodeName': '节点名称',
      'approver': '审批人',
      'signature': '签名',
      'approveTime': '审批时间',
      'opinion': '意见',

      // 页脚字段标签
      'creator': '制表人',
      'createTime': '制表时间',
      'reviewer': '审核人',
      'reviewTime': '审核时间',
    });

    // 创建适配器配置
    final config = pw.DataAdapterConfig(
      fieldLabelConfig: fieldLabels,
      moduleConfigs: pw.DataAdapterConfig.defaultConfig().moduleConfigs,
      dataKeyMappings: pw.DataAdapterConfig.defaultConfig().dataKeyMappings,
    );

    // 初始化类型安全适配器
    _typeSafeAdapter = pw.TypeSafeDataAdapter(config: config);
  }

  @override
  Map<String, pw.ModuleData> adaptData(Map<String, dynamic> rawData) {
    // 直接委托给类型安全适配器
    return _typeSafeAdapter.adaptData(rawData);
  }

  @override
  bool validateData(Map<String, dynamic> rawData) {
    // 委托给类型安全适配器
    return _typeSafeAdapter.validateData(rawData);
  }

  @override
  List<String> getSupportedModules() {
    // 委托给类型安全适配器
    return _typeSafeAdapter.getSupportedModules();
  }
}
