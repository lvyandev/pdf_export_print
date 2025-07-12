# PDF Export Print

一个功能强大、类型安全的 Flutter PDF 生成组件库，支持模块化设计和配置驱动的数据适配。

## ✨ 核心特性

- **🔒 类型安全**: 使用枚举常量替代硬编码字符串，提供编译时类型检查
- **⚙️ 配置驱动**: 集中管理字段映射和模块配置，易于维护和扩展
- **🧩 模块化设计**: 支持 Logo、标题、主表、子表、审批记录等多种模块
- **💧 水印支持**: 支持文本和图片水印，可配置位置、透明度、旋转等属性
- **📄 分页支持**: 自动处理长表格的分页显示
- **🎨 高度可定制**: 支持样式、布局、主题等全方位定制
- **🔄 向后兼容**: 支持渐进式迁移，不影响现有代码

## 📦 安装

在 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  pdf_export_print: ^0.0.1
```

然后运行：

```bash
flutter pub get
```

## 🚀 快速开始

### 使用类型安全适配器（推荐）

```dart
import 'package:pdf_export_print/pdf_export_print.dart';

// 1. 自定义字段标签映射
final fieldLabels = FieldLabelConfig.custom({
  'name': '员工姓名',
  'department': '所属部门',
  'position': '岗位职务',
  'salary': '薪资',
});

// 2. 创建配置
final config = DataAdapterConfig(
  fieldLabelConfig: fieldLabels,
  moduleConfigs: DataAdapterConfig.defaultConfig().moduleConfigs,
  dataKeyMappings: DataAdapterConfig.defaultConfig().dataKeyMappings,
);

// 3. 创建类型安全适配器
final adapter = TypeSafeDataAdapter(config: config);

// 4. 准备数据（使用枚举确保类型安全）
final data = {
  DataKeys.titles.value: ['员工信息表'],
  DataKeys.mainData.value: {
    'name': '张三',
    'department': '技术部',
    'position': '高级工程师',
    'salary': 15000,
  },
};

// 5. 生成PDF
final pdfBuilder = PDFPrintBuilder()
    .withConfig(PDFConfig.defaultConfig())
    .withDataAdapter(adapter);

final pdfDocument = await pdfBuilder.build(data);
final pdfBytes = await pdfDocument.save();
```

## � 常见使用场景

### 员工信息表

```dart
// 1. 配置字段标签
final fieldLabels = FieldLabelConfig.custom({
  'name': '姓名',
  'department': '部门',
  'position': '职位',
  'salary': '薪资',
  'phone': '联系电话',
  'email': '邮箱',
});

// 2. 准备数据
final employeeData = {
  DataKeys.titles.value: ['员工信息表'],
  DataKeys.mainData.value: {
    'name': '张三',
    'department': '技术部',
    'position': '高级工程师',
    'salary': 15000,
    'phone': '13800138000',
    'email': 'zhangsan@company.com',
  },
};

// 3. 生成PDF
final adapter = TypeSafeDataAdapter(
  config: DataAdapterConfig(
    fieldLabelConfig: fieldLabels,
    moduleConfigs: DataAdapterConfig.defaultConfig().moduleConfigs,
    dataKeyMappings: DataAdapterConfig.defaultConfig().dataKeyMappings,
  ),
);

final pdfBuilder = PDFPrintBuilder()
    .withConfig(PDFConfig.defaultConfig())
    .withDataAdapter(adapter);

final pdfDocument = await pdfBuilder.build(employeeData);
```

### 项目报告表

```dart
// 包含子表数据的项目报告
final projectData = {
  DataKeys.titles.value: ['项目进度报告'],
  DataKeys.mainData.value: {
    'projectName': 'PDF导出系统',
    'manager': '李四',
    'startDate': '2024-01-01',
    'status': '进行中',
  },
  DataKeys.details.value: [
    {
      'taskName': '需求分析',
      'assignee': '张三',
      'progress': '100%',
      'status': '已完成',
    },
    {
      'taskName': '系统设计',
      'assignee': '李四',
      'progress': '80%',
      'status': '进行中',
    },
  ],
};
```

## ⚙️ 常用配置

### 控制模块显示

```dart
// 只显示标题和主表，隐藏其他模块
final config = DataAdapterConfig(
  fieldLabelConfig: fieldLabels,
  moduleConfigs: {
    ModuleTypes.title: AdapterModuleConfig(
      enabled: true,
      priority: 1,
    ),
    ModuleTypes.mainTable: AdapterModuleConfig(
      enabled: true,
      priority: 2,
    ),
    ModuleTypes.subTable: AdapterModuleConfig(
      enabled: false,  // 隐藏子表
    ),
    ModuleTypes.approval: AdapterModuleConfig(
      enabled: false,  // 隐藏审批记录
    ),
  },
  dataKeyMappings: DataAdapterConfig.defaultConfig().dataKeyMappings,
);
```

### 自定义PDF样式

```dart
final pdfConfig = PDFConfig.builder()
    .withOrientation(pw.PageOrientation.portrait)  // 纵向
    .withMargins(const pw.EdgeInsets.all(20))      // 页边距
    .build();

final pdfBuilder = PDFPrintBuilder()
    .withConfig(pdfConfig)
    .withDataAdapter(adapter);
```

### 添加Logo

```dart
final dataWithLogo = {
  DataKeys.logoUrl.value: 'https://example.com/logo.png',
  DataKeys.titles.value: ['公司员工信息表'],
  DataKeys.mainData.value: {
    'name': '张三',
    'department': '技术部',
  },
};
```

### 水印配置

支持文本和图片水印，可配置位置、透明度、旋转角度等属性。

#### 文本水印

```dart
// 创建文本水印配置
final watermarkConfig = WatermarkConfig.textWatermark(
  enabled: true,
  content: 'CONFIDENTIAL',
  position: WatermarkPosition.center,
  mode: WatermarkMode.background,
  opacity: 0.3,
  rotation: -0.5, // 弧度
  scale: 1.5,
  fontSize: 48,
  textColor: PdfColors.grey400,
);

// 应用到PDF配置
final pdfConfig = PDFConfig.builder()
    .withOrientation(pw.PageOrientation.landscape)
    .watermark(watermarkConfig)
    .build();
```

#### 图片水印

```dart
// 加载图片数据
final imageData = await rootBundle.load('assets/images/watermark.png');
final imageBytes = imageData.buffer.asUint8List();

// 创建图片水印配置
final watermarkConfig = WatermarkConfig.imageWatermark(
  enabled: true,
  imageData: imageBytes,
  position: WatermarkPosition.bottomRight,
  mode: WatermarkMode.foreground,
  opacity: 0.5,
  scale: 0.8,
);

final pdfConfig = PDFConfig.builder()
    .watermark(watermarkConfig)
    .build();
```

#### 水印位置选项

- `WatermarkPosition.topLeft` - 左上角
- `WatermarkPosition.topCenter` - 顶部居中
- `WatermarkPosition.topRight` - 右上角
- `WatermarkPosition.centerLeft` - 左侧居中
- `WatermarkPosition.center` - 正中央
- `WatermarkPosition.centerRight` - 右侧居中
- `WatermarkPosition.bottomLeft` - 左下角
- `WatermarkPosition.bottomCenter` - 底部居中
- `WatermarkPosition.bottomRight` - 右下角

#### 水印模式

- `WatermarkMode.background` - 背景水印（在内容下方）
- `WatermarkMode.foreground` - 前景水印（在内容上方）

## � 详细文档

深入了解配置和高级用法：

1. **配置参数详解**: [docs/adapter_config_guide.md](docs/adapter_config_guide.md) - 了解各个配置参数的作用
2. **完整示例**: 查看 `example/lib/type_safe_adapter_example.dart` - 包含详细注释的示例代码

### 两种适配器对比

```dart
// 简单适配器（基础用法）
final simpleAdapter = SimpleDataAdapter();

// 类型安全适配器（推荐用法）
final fieldLabels = FieldLabelConfig.custom({
  'name': '姓名',
  'department': '部门',
  // 添加所有字段映射
});

final typeSafeAdapter = TypeSafeDataAdapter(
  config: DataAdapterConfig(
    fieldLabelConfig: fieldLabels,
    moduleConfigs: DataAdapterConfig.defaultConfig().moduleConfigs,
    dataKeyMappings: DataAdapterConfig.defaultConfig().dataKeyMappings,
  ),
);
```

## 📖 API 参考

### 核心类

- **`TypeSafeDataAdapter`**: 类型安全的数据适配器
- **`FieldLabelConfig`**: 字段标签配置管理
- **`DataAdapterConfig`**: 适配器总配置
- **`PDFPrintBuilder`**: PDF构建器

### 枚举常量

- **`DataKeys`**: 原始数据键名枚举
- **`ModuleTypes`**: PDF模块类型枚举
- **`ModuleDataKeys`**: 模块内部数据键枚举

### 配置类

- **`AdapterModuleConfig`**: 模块配置
- **`PDFConfig`**: PDF页面配置

## 📁 示例项目

查看 `example/` 目录获取完整示例：

- **`main.dart`**: 基础使用示例（旧版本兼容）
- **`type_safe_adapter_example.dart`**: 类型安全适配器示例（推荐）

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License
