/// PDF打印组件库
///
/// 一个功能强大、高度可定制的Flutter PDF生成组件库
library;

///
/// ## 主要特性
///
/// - **模块化设计**: 支持Logo、标题、主表、子表等多种模块
/// - **高度可配置**: 支持样式、布局、主题等全方位定制
/// - **数据适配**: 灵活的数据适配机制，支持多种数据格式
/// - **分页支持**: 自动处理长表格的分页显示
/// - **扩展性强**: 支持自定义模块和插件机制
///
/// ## 基础使用
///
/// ```dart
/// import 'package:pdf_export_print/pdf_export_print.dart';
///
/// // 创建带数据的模块描述符
/// final moduleDescriptors = {
///   ModuleDescriptor.logo.copyWith(data: 'https://example.com/logo.png'),
///   ModuleDescriptor.title.copyWith(data: {'titles': ['文档标题']}),
///   ModuleDescriptor.mainTable.copyWith(data: {'name': '张三', 'age': 30}),
/// };
///
/// // 创建配置
/// final config = DataAdapterConfig(moduleDescriptors: moduleDescriptors);
/// final adapter = TypeSafeDataAdapter(config: config);
///
/// // 创建PDF构建器
/// final pdfBuilder = PDFPrintBuilder()
///   .withConfig(PDFConfig.defaultConfig())
///   .withDataAdapter(adapter)
///   .addModule(LogoModule())
///   .addModule(TitleModule())
///   .addModule(MainTableModule());
///
/// // 生成PDF（数据来自 ModuleDescriptor）
/// final pdf = await pdfBuilder.build();
/// ```
///
/// ## 高级定制
///
/// ```dart
/// // 自定义配置
/// final config = PDFConfig.builder()
///   .pageSize(PdfPageFormat.a4)
///   .margins(EdgeInsets.all(20))
///   .theme(CorporateTheme(PdfColors.blue))
///   .build();
///
/// // 自定义模块
/// final customTitle = TitleModule(
///   config: TitleConfig(
///     color: 'blue',
///     fontSize: 18.0,
///     fontWeight: pw.FontWeight.bold,
///   ),
/// );
/// ```

// 核心功能
export 'src/core/core.dart';

// 模块集合
export 'src/modules/modules.dart';

// 通用组件
export 'src/components/components.dart';

// 配置类
export 'src/configs/configs.dart';

// 数据模型
export 'src/models/models.dart';

// 基础数据类型
export 'src/data/data.dart';

// 主题样式
export 'src/themes/themes.dart';

// 常量定义
export 'src/constants/adapter_constants.dart';
export 'src/constants/module_constants.dart';

// 类型安全适配器（已整合到 data_adapter.dart 中）

// 导出pdf库，方便用户直接使用
export 'package:pdf/pdf.dart';
export 'package:pdf/widgets.dart';
