import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/pdf_context.dart';
import 'package:pdf_export_print/src/core/module_descriptor.dart';

/// PDF模块抽象基类
abstract class PDFModule {
  PDFModule(this.config);

  /// 模块配置
  final BaseModuleConfig config;

  /// 模块描述符
  ModuleDescriptor get descriptor;

  /// 渲染模块内容
  ///
  /// ### 参数
  /// - [descriptor] 模块描述符
  /// - [context] PDF上下文
  /// ### 返回值
  /// 返回渲染后的Widget列表
  Future<List<pw.Widget>> render(
    ModuleDescriptor descriptor,
    PDFContext context,
  );

  /// 检查是否可以渲染该数据
  ///
  /// ### 参数
  /// - [descriptor] 模块描述符
  /// ### 返回值
  /// 如果可以渲染返回true，否则返回false
  bool canRender(ModuleDescriptor descriptor);
}
