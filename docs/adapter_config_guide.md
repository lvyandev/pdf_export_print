# AdapterModuleConfig 配置详解

## 概述

`AdapterModuleConfig` 是控制数据适配器中各个模块行为的核心配置类。每个配置参数都有其特定的作用和影响范围。

## 配置参数详解

### 1. moduleType (模块类型)

```dart
moduleType: ModuleTypes.logo
```

**作用**：标识模块的类型，用于内部识别和处理。

**影响**：
- 决定使用哪个适配方法处理数据
- 与 `dataKeyMappings` 配合确定数据源

**使用场景**：必须与枚举值保持一致，不可随意修改。

### 2. enabled (启用状态)

```dart
enabled: true  // 或 false
```

**作用**：控制模块是否参与PDF生成过程。

**影响**：
- `true`：模块会被处理并出现在PDF中
- `false`：模块被完全跳过，不会出现在PDF中

**实际应用**：
```dart
// 在适配器中的检查逻辑
if (moduleType != null && _config.isModuleEnabled(moduleType)) {
  // 只有启用的模块才会被处理
  final moduleData = _adaptModuleData(dataKey, moduleType, rawData[dataKey.value]);
}
```

**使用场景**：
- 根据业务需求动态控制PDF内容
- A/B测试不同的PDF布局
- 根据用户权限显示不同模块

### 3. priority (优先级)

```dart
priority: 1  // 数值越小优先级越高
```

**作用**：控制模块在PDF中的显示顺序。

**影响**：
- 数值越小，在PDF中越靠前显示
- 相同优先级的模块按添加顺序排列

**默认优先级建议**：
```dart
ModuleTypes.logo: priority: 1,      // 最顶部
ModuleTypes.title: priority: 2,     // 标题区域
ModuleTypes.mainTable: priority: 3, // 主要内容
ModuleTypes.subTable: priority: 4,  // 详细数据
ModuleTypes.approval: priority: 5,  // 审批信息
ModuleTypes.footer: priority: 6,    // 页脚信息
```

**使用场景**：
- 调整PDF布局顺序
- 根据重要性排列模块
- 适应不同的文档格式需求

### 4. required (必需验证)

```dart
required: true  // 或 false
```

**作用**：在数据验证阶段检查是否必须提供该模块的数据。

**影响**：
- `true`：如果原始数据中缺少该模块的数据，`validateData()` 返回 `false`
- `false`：该模块的数据可选，缺少时不影响验证

**验证逻辑**：
```dart
// 在 validateData 方法中
for (final moduleType in ModuleTypes.values) {
  final moduleConfig = _config.getModuleConfig(moduleType);
  if (moduleConfig?.required == true) {
    final requiredDataKey = _getDataKeyForModule(moduleType);
    if (requiredDataKey != null && !rawData.containsKey(requiredDataKey.value)) {
      return false; // 验证失败
    }
  }
}
```

**使用场景**：
- 确保关键信息不会缺失
- 业务规则验证
- 数据完整性检查

### 5. customSettings (自定义设置)

```dart
customSettings: {
  'defaultWidth': 150.0,
  'defaultHeight': 75.0,
  'showBorder': true,
}
```

**作用**：存储模块特定的配置参数，可在适配过程中使用。

**获取方式**：
```dart
// 在适配器中获取自定义设置
final moduleConfig = _config.getModuleConfig(ModuleTypes.logo);
final width = moduleConfig?.getSetting<double>('defaultWidth') ?? 100.0;
final height = moduleConfig?.getSetting<double>('defaultHeight') ?? 50.0;
```

**使用场景**：
- Logo尺寸配置
- 表格样式设置
- 模块特定的业务参数
- 扩展功能配置

## 实际应用示例

### 场景1：动态控制PDF内容

```dart
// 根据用户类型显示不同模块
final isAdmin = user.role == 'admin';

final moduleConfigs = <ModuleTypes, AdapterModuleConfig>{
  ModuleTypes.logo: AdapterModuleConfig(
    moduleType: ModuleTypes.logo,
    enabled: true,
    priority: 1,
  ),
  ModuleTypes.approval: AdapterModuleConfig(
    moduleType: ModuleTypes.approval,
    enabled: isAdmin, // 只有管理员才显示审批信息
    priority: 5,
    required: isAdmin,
  ),
};
```

### 场景2：自定义模块样式

```dart
final moduleConfigs = <ModuleTypes, AdapterModuleConfig>{
  ModuleTypes.logo: AdapterModuleConfig(
    moduleType: ModuleTypes.logo,
    enabled: true,
    priority: 1,
    customSettings: {
      'width': company.logoWidth,
      'height': company.logoHeight,
      'alignment': 'center',
    },
  ),
  ModuleTypes.mainTable: AdapterModuleConfig(
    moduleType: ModuleTypes.mainTable,
    enabled: true,
    priority: 3,
    customSettings: {
      'columnsPerRow': 6,
      'showBorder': true,
      'cellPadding': 8.0,
    },
  ),
};
```

### 场景3：业务规则验证

```dart
final moduleConfigs = <ModuleTypes, AdapterModuleConfig>{
  ModuleTypes.title: AdapterModuleConfig(
    moduleType: ModuleTypes.title,
    enabled: true,
    priority: 2,
    required: true, // 标题是必需的
  ),
  ModuleTypes.approval: AdapterModuleConfig(
    moduleType: ModuleTypes.approval,
    enabled: true,
    priority: 5,
    required: document.needsApproval, // 根据文档类型决定是否必需
  ),
};
```

## 最佳实践

1. **优先级规划**：为不同类型的模块预留优先级区间
   - 1-10：头部信息（Logo、标题）
   - 11-50：主要内容（表格、数据）
   - 51-100：辅助信息（审批、页脚）

2. **必需验证**：只对关键业务数据设置 `required: true`

3. **自定义设置**：使用有意义的键名，并提供默认值

4. **动态配置**：根据业务逻辑动态生成配置，而不是硬编码

## 配置的生命周期

1. **创建阶段**：在 `DataAdapterConfig` 中定义模块配置
2. **验证阶段**：`validateData()` 检查必需模块的数据
3. **适配阶段**：`adaptData()` 根据 `enabled` 状态处理模块
4. **渲染阶段**：PDF构建器根据 `priority` 排序并渲染模块

通过合理配置这些参数，可以实现灵活、可控的PDF生成流程。
