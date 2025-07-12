import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'dart:developer' as dev;

import 'style_theme.dart';

/// 默认样式主题
class DefaultTheme extends StyleTheme {
  static final Map<int, pw.Font> _chineseFonts = {};
  static bool _fontsInitialized = false;

  @override
  PdfColor get primaryColor => PdfColors.black;

  @override
  PdfColor get titleColor => PdfColors.red;

  @override
  PdfColor get borderColor => PdfColors.black;

  @override
  PdfColor get backgroundColor => PdfColors.white;

  @override
  pw.Font? get defaultFont => getFontByWeight(400);

  @override
  pw.Font? get titleFont => getFontByWeight(700);

  @override
  pw.Font? get boldFont => getFontByWeight(700);

  @override
  double get defaultFontSize => 12;

  @override
  double get titleFontSize => 16;

  @override
  double get borderWidth => 1.0;

  /// 根据字体粗细获取对应字体（精简版映射）
  static pw.Font? getFontByWeight(int weight) {
    if (!_fontsInitialized) return null;

    // 精简映射逻辑：只有Regular(400)和Bold(700)两个字重
    // weight 100-550 映射到Regular(400)
    // weight 600-900 映射到Bold(700)
    final mappedWeight = weight <= 550 ? 400 : 700;

    return _chineseFonts[mappedWeight];
  }

  /// 初始化中文字体（从assets目录动态加载）
  static Future<void> initChineseFont() async {
    if (_fontsInitialized) return;

    try {
      // 加载精简版阿里巴巴普惠体字体文件（仅Regular和Bold）
      const packageName = 'pdf_export_print'; // 可以从pubspec.yaml动态获取
      final fontFiles = {
        400:
            'packages/$packageName/assets/fonts/AlibabaPuHuiTi-3-55-Regular.ttf',
        700: 'packages/$packageName/assets/fonts/AlibabaPuHuiTi-3-85-Bold.ttf',
      };

      for (final entry in fontFiles.entries) {
        final weight = entry.key;
        final fontPath = entry.value;

        try {
          final fontData = await rootBundle.load(fontPath);
          final font = pw.Font.ttf(fontData);
          _chineseFonts[weight] = font;
        } catch (e) {
          dev.log('加载字体失败: $fontPath - $e', level: 900);
          continue;
        }
      }

      _fontsInitialized = true;

      if (_chineseFonts.isEmpty) {
        dev.log('未找到任何中文字体文件，请确保在assets/fonts/目录下添加阿里巴巴普惠体字体文件', level: 900);
        dev.log(
          '需要的字体文件: AlibabaPuHuiTi-3-55-Regular.ttf, AlibabaPuHuiTi-3-85-Bold.ttf',
          level: 800,
        );
      } else {
        dev.log('成功加载中文字体: ${_chineseFonts.keys.toList()}', level: 800);
      }
    } catch (e) {
      dev.log('中文字体加载失败: $e', level: 1000);
      _fontsInitialized = true; // 标记为已初始化，避免重复尝试
    }
  }
}
