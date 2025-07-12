import 'package:pdf_export_print/src/data/data.dart';

/// Logo数据模型
class LogoData extends ModuleData {
  /// Logo URL
  final String logoUrl;

  /// 图片宽度
  final double? width;

  /// 图片高度
  final double? height;

  LogoData({required this.logoUrl, this.width, this.height})
    : super(
        moduleType: 'logo',
        data: {
          'logoUrl': logoUrl,
          if (width != null) 'width': width,
          if (height != null) 'height': height,
        },
      );
}
