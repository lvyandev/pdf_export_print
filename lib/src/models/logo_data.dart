import 'package:pdf_export_print/src/constants/adapter_constants.dart';
import 'package:pdf_export_print/src/constants/constants.dart';
import 'package:pdf_export_print/src/core/core.dart';

/// Logo数据模型
///
/// 继承自 ModuleDescriptor，提供强类型的Logo数据结构
class LogoData extends ModuleDescriptor {
  /// Logo URL
  final String logoUrl;

  /// 图片宽度
  final double? width;

  /// 图片高度
  final double? height;

  LogoData({required this.logoUrl, this.width, this.height, String? moduleId})
    : super(ModuleType.logo, moduleId ?? ModuleType.logo.value, {
        'logoUrl': logoUrl,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
      });

  /// 从Map创建
  factory LogoData.fromMap(Map<String, dynamic> map, {String? moduleId}) {
    return LogoData(
      logoUrl: map['logoUrl'] as String? ?? '',
      width: map['width'] as double?,
      height: map['height'] as double?,
      moduleId: moduleId,
    );
  }

  /// 从字符串URL创建
  factory LogoData.fromUrl(String url, {String? moduleId}) {
    return LogoData(logoUrl: url, moduleId: moduleId);
  }

  /// 从 ModuleDescriptor 创建
  factory LogoData.fromDescriptor(ModuleDescriptor descriptor) {
    if (descriptor.type != ModuleType.logo) {
      throw ArgumentError('ModuleDescriptor type must be logo');
    }

    if (descriptor.data is String) {
      return LogoData.fromUrl(
        descriptor.data as String,
        moduleId: descriptor.moduleId,
      );
    }

    if (descriptor.data is Map<String, dynamic>) {
      return LogoData.fromMap(
        descriptor.data as Map<String, dynamic>,
        moduleId: descriptor.moduleId,
      );
    }

    throw ArgumentError('Invalid data format for LogoData');
  }
}
