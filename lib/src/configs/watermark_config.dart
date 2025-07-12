import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:typed_data';

/// 水印类型枚举
enum WatermarkType {
  /// 文本水印
  text,

  /// 图片水印
  image,
}

/// 水印位置枚举（九宫格定位）
enum WatermarkPosition {
  /// 左上角
  topLeft,

  /// 顶部居中
  topCenter,

  /// 右上角
  topRight,

  /// 左侧居中
  centerLeft,

  /// 正中央
  center,

  /// 右侧居中
  centerRight,

  /// 左下角
  bottomLeft,

  /// 底部居中
  bottomCenter,

  /// 右下角
  bottomRight,
}

/// 水印模式枚举
enum WatermarkMode {
  /// 背景水印（在内容下方）
  background,

  /// 前景水印（在内容上方）
  foreground,
}

/// 水印配置类
class WatermarkConfig {
  /// 是否启用水印
  final bool enabled;

  /// 水印类型
  final WatermarkType type;

  /// 水印内容（文本内容或图片路径）
  final String content;

  /// 水印位置
  final WatermarkPosition position;

  /// 水印模式
  final WatermarkMode mode;

  /// 水印透明度（0.0-1.0）
  final double opacity;

  /// 水印旋转角度（弧度）
  final double rotation;

  /// 文本水印字体大小
  final double? fontSize;

  /// 文本水印颜色
  final PdfColor? textColor;

  /// 文本水印字体
  final pw.Font? font;

  /// 文本水印字体权重
  final pw.FontWeight fontWeight;

  /// 图片水印数据（用于图片水印）
  final Uint8List? imageData;

  const WatermarkConfig({
    this.enabled = false,
    this.type = WatermarkType.text,
    this.content = 'DRAFT',
    this.position = WatermarkPosition.center,
    this.mode = WatermarkMode.background,
    this.opacity = 0.3,
    this.rotation = 0.0,
    this.fontSize,
    this.textColor,
    this.font,
    this.fontWeight = pw.FontWeight.normal,
    this.imageData,
  });

  /// 创建默认配置
  static WatermarkConfig defaultConfig() => const WatermarkConfig();

  /// 创建文本水印配置
  static WatermarkConfig textWatermark({
    bool enabled = true,
    String content = 'DRAFT',
    WatermarkPosition position = WatermarkPosition.center,
    WatermarkMode mode = WatermarkMode.background,
    double opacity = 0.3,
    double rotation = 0.0,
    double? fontSize,
    PdfColor? textColor,
    pw.Font? font,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
  }) {
    return WatermarkConfig(
      enabled: enabled,
      type: WatermarkType.text,
      content: content,
      position: position,
      mode: mode,
      opacity: opacity,
      rotation: rotation,
      fontSize: fontSize,
      textColor: textColor,
      font: font,
      fontWeight: fontWeight,
    );
  }

  /// 创建图片水印配置
  static WatermarkConfig imageWatermark({
    bool enabled = true,
    required Uint8List imageData,
    WatermarkPosition position = WatermarkPosition.center,
    WatermarkMode mode = WatermarkMode.background,
    double opacity = 0.3,
    double rotation = 0.0,
  }) {
    return WatermarkConfig(
      enabled: enabled,
      type: WatermarkType.image,
      content: '',
      position: position,
      mode: mode,
      opacity: opacity,
      rotation: rotation,
      imageData: imageData,
    );
  }

  /// 复制并修改配置
  WatermarkConfig copyWith({
    bool? enabled,
    WatermarkType? type,
    String? content,
    WatermarkPosition? position,
    WatermarkMode? mode,
    double? opacity,
    double? rotation,
    double? fontSize,
    PdfColor? textColor,
    pw.Font? font,
    pw.FontWeight? fontWeight,
    Uint8List? imageData,
  }) {
    return WatermarkConfig(
      enabled: enabled ?? this.enabled,
      type: type ?? this.type,
      content: content ?? this.content,
      position: position ?? this.position,
      mode: mode ?? this.mode,
      opacity: opacity ?? this.opacity,
      rotation: rotation ?? this.rotation,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      font: font ?? this.font,
      fontWeight: fontWeight ?? this.fontWeight,
      imageData: imageData ?? this.imageData,
    );
  }

  /// 获取水印对齐方式
  pw.Alignment getAlignment() {
    switch (position) {
      case WatermarkPosition.topLeft:
        return pw.Alignment.topLeft;
      case WatermarkPosition.topCenter:
        return pw.Alignment.topCenter;
      case WatermarkPosition.topRight:
        return pw.Alignment.topRight;
      case WatermarkPosition.centerLeft:
        return pw.Alignment.centerLeft;
      case WatermarkPosition.center:
        return pw.Alignment.center;
      case WatermarkPosition.centerRight:
        return pw.Alignment.centerRight;
      case WatermarkPosition.bottomLeft:
        return pw.Alignment.bottomLeft;
      case WatermarkPosition.bottomCenter:
        return pw.Alignment.bottomCenter;
      case WatermarkPosition.bottomRight:
        return pw.Alignment.bottomRight;
    }
  }

  /// 获取水印位置的显示名称
  String getPositionDisplayName() {
    switch (position) {
      case WatermarkPosition.topLeft:
        return '左上角';
      case WatermarkPosition.topCenter:
        return '顶部居中';
      case WatermarkPosition.topRight:
        return '右上角';
      case WatermarkPosition.centerLeft:
        return '左侧居中';
      case WatermarkPosition.center:
        return '正中央';
      case WatermarkPosition.centerRight:
        return '右侧居中';
      case WatermarkPosition.bottomLeft:
        return '左下角';
      case WatermarkPosition.bottomCenter:
        return '底部居中';
      case WatermarkPosition.bottomRight:
        return '右下角';
    }
  }

  /// 获取水印模式的显示名称
  String getModeDisplayName() {
    switch (mode) {
      case WatermarkMode.background:
        return '背景水印';
      case WatermarkMode.foreground:
        return '前景水印';
    }
  }

  /// 获取水印类型的显示名称
  String getTypeDisplayName() {
    switch (type) {
      case WatermarkType.text:
        return '文本水印';
      case WatermarkType.image:
        return '图片水印';
    }
  }
}
