import 'dart:developer';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/watermark_config.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/themes/themes.dart';

/// PDF构建器主类
class PDFPrintBuilder {
  PDFConfig? _config;
  DataAdapter? _dataAdapter;
  final List<PDFModule> _modules = [];

  /// 设置PDF配置
  ///
  /// ### 参数
  /// - [config] PDF配置对象
  /// ### 返回值
  /// 返回构建器实例，支持链式调用
  PDFPrintBuilder withConfig(PDFConfig config) {
    _config = config;
    return this;
  }

  /// 设置数据适配器
  ///
  /// ### 参数
  /// - [adapter] 数据适配器实例
  /// ### 返回值
  /// 返回构建器实例，支持链式调用
  PDFPrintBuilder withDataAdapter(DataAdapter adapter) {
    _dataAdapter = adapter;
    return this;
  }

  /// 添加PDF模块
  ///
  /// ### 参数
  /// - [module] PDF模块实例
  /// ### 返回值
  /// 返回构建器实例，支持链式调用
  PDFPrintBuilder addModule(PDFModule module) {
    _modules.add(module);
    return this;
  }

  /// 构建PDF文档
  ///
  /// ### 参数
  /// - [data] 原始业务数据
  /// ### 返回值
  /// 返回生成的PDF文档
  /// ### 异常
  /// 如果配置或适配器未设置，抛出StateError
  Future<pw.Document> build(Map<String, dynamic> data) async {
    // 初始化中文字体支持
    await DefaultTheme.initChineseFont();
    // 验证必需的组件
    if (_config == null) {
      throw StateError('PDF配置未设置，请调用withConfig()方法');
    }
    if (_dataAdapter == null) {
      throw StateError('数据适配器未设置，请调用withDataAdapter()方法');
    }

    // 验证数据
    if (!_dataAdapter!.validateData(data)) {
      throw ArgumentError('输入数据验证失败');
    }

    // 适配数据
    final adaptedData = _dataAdapter!.adaptData(data);

    // 创建PDF文档
    final pdf = pw.Document();

    // 创建PDF上下文
    final context = _createPDFContext();

    // 按优先级排序模块（数值越小优先级越高）
    final sortedModules = List<PDFModule>.from(_modules)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    // 渲染所有模块
    final List<pw.Widget> allWidgets = [];

    for (final module in sortedModules) {
      if (!module.config.enabled) continue;

      final moduleData = adaptedData[module.moduleId];
      if (moduleData != null && module.canRender(moduleData)) {
        try {
          final widgets = await module.render(moduleData, context);
          allWidgets.addAll(widgets);
        } catch (e) {
          // 记录错误但继续处理其他模块
          log('模块 ${module.moduleId} 渲染失败: $e');
        }
      }
    }

    // 添加页面到PDF
    if (allWidgets.isNotEmpty) {
      // 创建页面主题（包含水印）
      final pageTheme = _createPageTheme();

      if (pageTheme != null) {
        // 如果有水印，使用 pageTheme
        pdf.addPage(
          pw.MultiPage(
            pageTheme: pageTheme,
            build: (pw.Context pdfContext) => allWidgets,
          ),
        );
      } else {
        // 如果没有水印，使用常规页面设置
        pdf.addPage(
          pw.MultiPage(
            pageFormat: _config!.pageSize,
            orientation: _config!.orientation,
            margin: pw.EdgeInsets.only(
              left: _config!.margins.left,
              top: _config!.margins.top,
              right: _config!.margins.right,
              bottom: _config!.margins.bottom,
            ),
            build: (pw.Context pdfContext) => allWidgets,
          ),
        );
      }
    }

    return pdf;
  }

  /// 创建页面主题（包含水印）
  ///
  /// ### 功能说明
  /// 根据水印配置创建包含水印的页面主题，支持文本和图片水印
  ///
  /// ### 透明度处理
  /// 使用 pw.Opacity 组件统一处理透明度，确保文本和图片水印的一致性
  ///
  /// ### 返回值
  /// 如果水印未启用或创建失败，返回 null；否则返回包含水印的 PageTheme
  pw.PageTheme? _createPageTheme() {
    final watermarkConfig = _config!.watermarkConfig;

    // 如果水印未启用，返回null
    if (!watermarkConfig.enabled) {
      return null;
    }

    // 创建水印Widget
    pw.Widget? watermarkWidget;

    // 根据水印类型创建相应的水印组件
    switch (watermarkConfig.type) {
      case WatermarkType.text:
        watermarkWidget = _createTextWatermark(watermarkConfig);
        break;
      case WatermarkType.image:
        if (watermarkConfig.imageData != null) {
          watermarkWidget = _createImageWatermark(watermarkConfig);
        }
        break;
    }

    if (watermarkWidget == null) {
      return null;
    }

    // 应用透明度：使用 Opacity 组件统一处理文本和图片水印的透明度
    watermarkWidget = pw.Opacity(
      opacity: watermarkConfig.opacity,
      child: watermarkWidget,
    );

    // 根据水印模式和位置创建PageTheme
    if (watermarkConfig.mode == WatermarkMode.background) {
      // 背景水印
      return pw.PageTheme(
        pageFormat: _config!.pageSize,
        orientation: _config!.orientation,
        margin: pw.EdgeInsets.only(
          left: _config!.margins.left,
          top: _config!.margins.top,
          right: _config!.margins.right,
          bottom: _config!.margins.bottom,
        ),
        buildBackground: (pw.Context context) => pw.FullPage(
          ignoreMargins: true,
          child: _positionWatermark(watermarkWidget!, watermarkConfig.position),
        ),
      );
    } else {
      // 前景水印
      return pw.PageTheme(
        pageFormat: _config!.pageSize,
        orientation: _config!.orientation,
        margin: pw.EdgeInsets.only(
          left: _config!.margins.left,
          top: _config!.margins.top,
          right: _config!.margins.right,
          bottom: _config!.margins.bottom,
        ),
        buildForeground: (pw.Context context) => pw.FullPage(
          ignoreMargins: true,
          child: _positionWatermark(watermarkWidget!, watermarkConfig.position),
        ),
      );
    }
  }

  /// 根据位置配置水印
  pw.Widget _positionWatermark(
    pw.Widget watermark,
    WatermarkPosition position,
  ) {
    pw.Alignment alignment;

    switch (position) {
      case WatermarkPosition.topLeft:
        alignment = pw.Alignment.topLeft;
        break;
      case WatermarkPosition.topCenter:
        alignment = pw.Alignment.topCenter;
        break;
      case WatermarkPosition.topRight:
        alignment = pw.Alignment.topRight;
        break;
      case WatermarkPosition.centerLeft:
        alignment = pw.Alignment.centerLeft;
        break;
      case WatermarkPosition.center:
        alignment = pw.Alignment.center;
        break;
      case WatermarkPosition.centerRight:
        alignment = pw.Alignment.centerRight;
        break;
      case WatermarkPosition.bottomLeft:
        alignment = pw.Alignment.bottomLeft;
        break;
      case WatermarkPosition.bottomCenter:
        alignment = pw.Alignment.bottomCenter;
        break;
      case WatermarkPosition.bottomRight:
        alignment = pw.Alignment.bottomRight;
        break;
    }

    return pw.Align(alignment: alignment, child: watermark);
  }

  /// 创建文本水印组件
  ///
  /// ### 参数
  /// - [config] 水印配置
  /// ### 返回值
  /// 文本水印组件
  pw.Widget _createTextWatermark(WatermarkConfig config) {
    final baseColor = config.textColor ?? PdfColors.grey600;

    return pw.Watermark.text(
      config.content,
      style: pw.TextStyle(
        fontSize: config.fontSize ?? 48,
        color: baseColor,
        font: config.font,
        fontWeight: config.fontWeight,
      ),
      angle: config.rotation,
      fit: pw.BoxFit.contain,
    );
  }

  /// 创建图片水印组件
  ///
  /// ### 参数
  /// - [config] 水印配置
  /// ### 返回值
  /// 图片水印组件
  pw.Widget _createImageWatermark(WatermarkConfig config) {
    final image = pw.MemoryImage(config.imageData!);

    return pw.Watermark(
      child: pw.Image(image),
      angle: config.rotation,
      fit: pw.BoxFit.contain,
    );
  }

  /// 创建PDF上下文
  PDFContext _createPDFContext() {
    final pageSize = _config!.pageSize;
    final margins = _config!.margins;
    final orientation = _config!.orientation;

    // 根据页面方向调整页面尺寸
    late final double actualWidth;
    late final double actualHeight;

    if (orientation == pw.PageOrientation.landscape) {
      // 横向模式：宽高交换
      actualWidth = pageSize.height;
      actualHeight = pageSize.width;
    } else {
      // 竖向模式或null（默认竖向）：保持原始尺寸
      actualWidth = pageSize.width;
      actualHeight = pageSize.height;
    }

    // 计算可用区域
    final double availableWidth = actualWidth - margins.left - margins.right;
    final double availableHeight = actualHeight - margins.top - margins.bottom;

    return PDFContext(
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      currentPage: 1,
      theme: _config!.theme,
      margins: margins,
    );
  }

  /// 获取已添加的模块列表
  List<PDFModule> getModules() {
    return List.unmodifiable(_modules);
  }

  /// 移除指定模块
  ///
  /// ### 参数
  /// - [moduleId] 模块ID
  /// ### 返回值
  /// 如果成功移除返回true，否则返回false
  bool removeModule(String moduleId) {
    final index = _modules.indexWhere((module) => module.moduleId == moduleId);
    if (index != -1) {
      _modules.removeAt(index);
      return true;
    }
    return false;
  }

  /// 清空所有模块
  void clearModules() {
    _modules.clear();
  }

  /// 检查是否包含指定模块
  ///
  /// ### 参数
  /// - [moduleId] 模块ID
  /// ### 返回值
  /// 如果包含该模块返回true，否则返回false
  bool hasModule(String moduleId) {
    return _modules.any((module) => module.moduleId == moduleId);
  }

  /// 获取指定模块
  ///
  /// ### 参数
  /// - [moduleId] 模块ID
  /// ### 返回值
  /// 返回模块实例，如果不存在返回null
  PDFModule? getModule(String moduleId) {
    try {
      return _modules.firstWhere((module) => module.moduleId == moduleId);
    } catch (e) {
      return null;
    }
  }

  /// 替换指定模块
  ///
  /// ### 参数
  /// - [moduleId] 要替换的模块ID
  /// - [newModule] 新的模块实例
  /// ### 返回值
  /// 如果成功替换返回true，否则返回false
  bool replaceModule(String moduleId, PDFModule newModule) {
    final index = _modules.indexWhere((module) => module.moduleId == moduleId);
    if (index != -1) {
      _modules[index] = newModule;
      return true;
    }
    return false;
  }

  /// 重置构建器状态
  void reset() {
    _config = null;
    _dataAdapter = null;
    _modules.clear();
  }
}

/// PDF构建异常
class PDFBuildException implements Exception {
  final String message;
  final dynamic cause;

  PDFBuildException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'PDFBuildException: $message\nCaused by: $cause';
    }
    return 'PDFBuildException: $message';
  }
}
