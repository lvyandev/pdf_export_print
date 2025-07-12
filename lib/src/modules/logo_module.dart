import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/constants/constants.dart';
import 'package:pdf_export_print/src/models/models.dart';
import 'dart:developer' as dev;

import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';

/// Logo模块，用于在PDF页面左上角显示Logo图片
class LogoModule extends PDFModule {
  final LogoConfig _config;

  LogoModule({LogoConfig? config})
    : _config = config ?? LogoConfig.defaultConfig();

  @override
  String get moduleId => 'logo';

  @override
  int get priority => 10; // 高优先级，优先渲染

  @override
  ModuleConfig get config => _config.moduleConfig;

  @override
  Future<List<pw.Widget>> render(ModuleData data, PDFContext context) async {
    // 直接使用LogoData，适配器保证输入类型正确
    final logoData = data as LogoData;

    if (logoData.logoUrl.isEmpty) {
      return [];
    }

    try {
      // 加载图片
      final imageData = await _loadImageFromUrl(logoData.logoUrl);
      if (imageData == null) {
        return [_buildPlaceholder(context)];
      }

      final image = pw.MemoryImage(imageData);

      // 使用LogoData中的尺寸，如果没有则使用配置中的默认值
      final width = logoData.width ?? _config.defaultWidth;
      final height = logoData.height ?? _config.defaultHeight;
      final alignment = _config.alignment;

      return [
        pw.Container(
          width: context.availableWidth,
          child: pw.Align(
            alignment: alignment,
            child: pw.Container(
              width: width,
              height: height,
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        ),
        pw.SizedBox(height: _config.bottomSpacing),
      ];
    } catch (e) {
      dev.log('Logo加载失败: $e', level: 900);
      return [_buildPlaceholder(context)];
    }
  }

  @override
  bool canRender(ModuleData data) {
    // 直接使用LogoData，适配器保证输入类型正确
    final logoData = data as LogoData;
    return logoData.logoUrl.isNotEmpty;
  }

  /// 从URL加载图片数据
  Future<Uint8List?> _loadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      dev.log('图片加载失败: $e', level: 900);
    }
    return null;
  }

  /// 构建占位符
  pw.Widget _buildPlaceholder(PDFContext context) {
    return pw.Container(
      width: _config.defaultWidth,
      height: _config.defaultHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey,
          width: LogoConstants.placeholderBorderWidth,
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          'Logo',
          style: pw.TextStyle(
            color: PdfColors.grey,
            fontSize: LogoConstants.placeholderFontSize,
          ),
        ),
      ),
    );
  }
}
