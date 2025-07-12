import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/module_config.dart';
import 'package:pdf_export_print/src/core/pdf_context.dart';
import 'package:pdf_export_print/src/data/module_data.dart';

/// PDF模块抽象基类
abstract class PDFModule {
  /// 模块唯一标识符
  String get moduleId;

  /// 模块优先级，数值越小优先级越高
  int get priority;

  /// 模块配置
  ModuleConfig get config;

  /// 渲染模块内容
  ///
  /// ### 参数
  /// - [data] 模块数据
  /// - [context] PDF上下文
  /// ### 返回值
  /// 返回渲染后的Widget列表
  Future<List<pw.Widget>> render(ModuleData data, PDFContext context);

  /// 检查是否可以渲染该数据
  ///
  /// ### 参数
  /// - [data] 模块数据
  /// ### 返回值
  /// 如果可以渲染返回true，否则返回false
  bool canRender(ModuleData data);
}
