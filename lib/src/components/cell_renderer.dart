import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/themes/themes.dart';
import 'package:pdf_export_print/src/configs/common_table_config.dart';

/// 单元格渲染上下文
class CellRenderContext {
  final double availableWidth;
  final double maxHeight;
  final PDFContext pdfContext;
  final CommonTableConfig config;

  CellRenderContext({
    required this.availableWidth,
    required this.maxHeight,
    required this.pdfContext,
    required this.config,
  });
}

/// 单元格渲染器接口
abstract class CellRenderer {
  Future<pw.Widget> render(CellContent content, CellRenderContext context);
}

/// 文本单元格渲染器
class TextCellRenderer implements CellRenderer {
  @override
  Future<pw.Widget> render(
    CellContent content,
    CellRenderContext context,
  ) async {
    final textContent = content as TextContent;

    return pw.Container(
      padding: context.config.cellPadding,
      alignment: context.config.dataAlignment,
      child: pw.Text(
        textContent.text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize:
              context.config.dataFontSize ??
              context.pdfContext.theme.defaultFontSize,
          color:
              context.config.dataColor ?? context.pdfContext.theme.primaryColor,
          font: DefaultTheme.getFontByWeight(400),
        ),
      ),
    );
  }
}

/// 图片单元格渲染器
class ImageCellRenderer implements CellRenderer {
  @override
  Future<pw.Widget> render(
    CellContent content,
    CellRenderContext context,
  ) async {
    final imageContent = content as ImageContent;

    try {
      // 加载图片数据
      final imageData = await _loadImageFromUrl(imageContent.imageUrl);
      if (imageData == null) {
        return _buildPlaceholder(imageContent, context);
      }

      return pw.Container(
        padding: context.config.cellPadding,
        width: context.availableWidth,
        alignment: context.config.dataAlignment,
        child: pw.Image(pw.MemoryImage(imageData)),
      );
    } catch (e) {
      dev.log('图片渲染失败: ${imageContent.imageUrl} - $e', level: 900);
      return _buildPlaceholder(imageContent, context);
    }
  }

  /// 加载图片数据（参考LogoModule实现）
  Future<Uint8List?> _loadImageFromUrl(String url) async {
    try {
      // 验证URL格式
      if (url.isEmpty) {
        dev.log('图片URL为空', level: 900);
        return null;
      }

      final response = await http
          .get(Uri.parse(url))
          // 超时时长
          .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        dev.log('图片加载失败: $url - HTTP ${response.statusCode}', level: 900);
      }
    } catch (e) {
      dev.log('图片加载失败: $url - $e', level: 900);
    }
    return null;
  }

  /// 构建占位符
  pw.Widget _buildPlaceholder(ImageContent content, CellRenderContext context) {
    return pw.Container(
      padding: context.config.cellPadding,
      alignment: context.config.dataAlignment,
      child: pw.Text(
        content.displayText,
        style: pw.TextStyle(
          fontSize:
              context.config.dataFontSize ??
              context.pdfContext.theme.defaultFontSize,
          color: PdfColors.grey,
          font: DefaultTheme.getFontByWeight(400),
        ),
      ),
    );
  }
}

/// 单元格渲染器工厂
class CellRendererFactory {
  static final Map<CellContentType, CellRenderer> _renderers = {
    CellContentType.text: TextCellRenderer(),
    CellContentType.image: ImageCellRenderer(),
  };

  /// 获取渲染器
  static CellRenderer? getRenderer(CellContentType type) {
    return _renderers[type];
  }

  /// 注册自定义渲染器
  static void registerRenderer(CellContentType type, CellRenderer renderer) {
    _renderers[type] = renderer;
  }
}
