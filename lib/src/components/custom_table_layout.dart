import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_export_print/src/configs/configs.dart';
import 'package:pdf_export_print/src/core/core.dart';
import 'package:pdf_export_print/src/data/data.dart';
import 'package:pdf_export_print/src/themes/themes.dart';

/// 自定义表格布局组件
/// 支持完美的跨列布局效果
class CustomTableLayout {
  final CustomTableConfig config;

  CustomTableLayout({required this.config});

  /// 构建自定义表格
  pw.Widget buildTable(
    List<TableField> fields,
    PDFContext context,
    bool showBorder,
  ) {
    // 安全检查：防止空字段列表
    if (fields.isEmpty) {
      return pw.Container();
    }

    // 按 sort 值降序排列，相同 sort 值保持原始顺序（稳定排序）
    final sortedFields = List<TableField>.from(fields);
    sortedFields.sort((a, b) {
      if (a.sort != b.sort) {
        return b.sort.compareTo(a.sort); // 降序：sort 值大的在前
      }
      return 0; // 相同 sort 值保持原顺序
    });

    return pw.Container(
      decoration: showBorder
          ? pw.BoxDecoration(
              border: pw.Border.all(
                color: config.borderColor ?? context.theme.borderColor,
                width: config.borderWidth ?? context.theme.borderWidth,
              ),
            )
          : null,
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min, // 防止无限高度
        children: _buildCustomRows(sortedFields, context, showBorder),
      ),
    );
  }

  /// 构建自定义行布局
  List<pw.Widget> _buildCustomRows(
    List<TableField> fields,
    PDFContext context,
    bool showBorder,
  ) {
    final List<pw.Widget> rows = [];

    // 使用智能行分配算法
    final List<List<TableField>> rowGroups = _groupFieldsIntoRows(fields);

    for (int i = 0; i < rowGroups.length; i++) {
      final rowFields = rowGroups[i];
      final isLastRow = i == rowGroups.length - 1;
      rows.add(
        _buildCustomRow(rowFields, context, config.showInnerBorder, isLastRow),
      );
    }

    return rows;
  }

  /// 智能分组字段到行
  List<List<TableField>> _groupFieldsIntoRows(List<TableField> fields) {
    final List<List<TableField>> rows = [];
    List<TableField> currentRow = [];
    double currentRowSpan = 0.0;

    for (final field in fields) {
      // 获取字段的有效宽度百分比
      final fieldWidth = field.getEffectiveWidthPercent();

      // 检查当前行是否还能容纳这个字段（基于百分比）
      if (currentRowSpan + fieldWidth > 1.0) {
        // 当前行已满，开始新行
        if (currentRow.isNotEmpty) {
          rows.add(currentRow);
          currentRow = [];
          currentRowSpan = 0.0;
        }
      }

      currentRow.add(field);
      currentRowSpan += fieldWidth;

      // 如果当前行正好填满，开始新行
      if (currentRowSpan >= 1.0) {
        rows.add(currentRow);
        currentRow = [];
        currentRowSpan = 0.0;
      }
    }

    // 添加最后一行
    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }

  /// 构建自定义行（每行独立计算高度）
  pw.Widget _buildCustomRow(
    List<TableField> fields,
    PDFContext context,
    bool showBorder,
    bool isLastRow,
  ) {
    // 为当前行独立计算最大高度
    final rowHeight = _calculateRowHeight(fields, context);

    return pw.Container(
      decoration: showBorder
          ? pw.BoxDecoration(
              border: pw.Border(
                bottom: isLastRow
                    ? pw.BorderSide.none
                    : pw.BorderSide(
                        color: config.borderColor ?? context.theme.borderColor,
                        width: config.borderWidth ?? context.theme.borderWidth,
                      ),
              ),
            )
          : null,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: _buildRowWidgets(
          fields,
          context,
          config.showInnerBorder,
          rowHeight,
        ),
      ),
    );
  }

  /// 构建行内组件（使用传入的行高度）
  List<pw.Widget> _buildRowWidgets(
    List<TableField> fields,
    PDFContext context,
    bool showBorder,
    double rowHeight, // 使用传入的行高度
  ) {
    // 使用传入的行高度，不再重复计算

    final List<pw.Widget> widgets = [];

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final isLastField = i == fields.length - 1;
      // 1/6基准宽度方案：标题固定1份，内容根据colspan计算
      final labelFlex = 1; // 标题始终占1份（1/6屏幕宽度）

      // 计算内容的flex值（基于widthPercent）
      final fieldWidth = field.getEffectiveWidthPercent();
      // 将百分比转换为flex值（1-5的范围）
      final contentFlex = (fieldWidth * 5).round().clamp(1, 5);

      // 额外安全检查：确保总flex在合理范围内
      final totalFlex = labelFlex + contentFlex;
      late final int safeLabelFlex;
      late final int safeContentFlex;

      if (totalFlex > 6) {
        // 如果超出6份，说明计算有误，回退到安全值
        safeLabelFlex = 1;
        safeContentFlex = 2; // 回退到1:2比例
      } else {
        safeLabelFlex = labelFlex;
        safeContentFlex = contentFlex;
      }

      // 标题部分
      widgets.add(
        pw.Expanded(
          flex: safeLabelFlex,
          child: pw.Container(
            height: rowHeight, // 动态计算的行高确保一致
            padding: config.cellPadding,
            decoration: (showBorder && config.showInnerBorder)
                ? pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(
                        color: config.borderColor ?? context.theme.borderColor,
                        width: config.borderWidth ?? context.theme.borderWidth,
                      ),
                    ),
                  )
                : null,
            child: _buildLabelCell(field, context),
          ),
        ),
      );

      // 内容部分
      widgets.add(
        pw.Expanded(
          flex: safeContentFlex,
          child: pw.Container(
            height: rowHeight, // 动态计算的行高确保一致
            padding: config.cellPadding,
            decoration: (showBorder && config.showInnerBorder && !isLastField)
                ? pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(
                        color: config.borderColor ?? context.theme.borderColor,
                        width: config.borderWidth ?? context.theme.borderWidth,
                      ),
                    ),
                  )
                : null,
            child: _buildContentCell(field, context),
          ),
        ),
      );
    }

    return widgets;
  }

  /// 计算行高度（预计算该行所有字段的最大内容高度）
  double _calculateRowHeight(List<TableField> fields, PDFContext context) {
    // 使用字体大小作为最小基础高度，适度增加空间
    final baseFontSize = config.labelFontSize ?? context.theme.defaultFontSize;
    double maxHeight = baseFontSize * 1.25; // 调整为1.25，提供适度的最小高度

    // 使用合理的页面宽度计算（基于A4但不硬编码具体数值）
    final pageWidth =
        context.availableWidth -
        context.margins.left -
        context.margins.right; // A4宽度减去合理边距，避免硬编码具体业务数值

    for (int fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
      final field = fields[fieldIndex];
      // 计算标题可用宽度（1/6屏幕宽度）
      final labelWidth = pageWidth / 6.0;

      // 计算内容可用宽度（根据widthPercent动态计算）
      final fieldWidth = field.getEffectiveWidthPercent();
      final contentWidth = pageWidth * fieldWidth;

      // 估算标题高度（使用实际可用宽度）
      final labelHeight = _estimateTextHeight(
        field.label,
        config.labelFontSize ?? context.theme.defaultFontSize,
        labelWidth,
        context,
      );

      // 估算内容高度（使用实际可用宽度）
      final contentHeight = _estimateTextHeight(
        field.value,
        config.contentFontSize ?? context.theme.defaultFontSize,
        contentWidth,
        context,
      );

      // 取该字段的最大高度
      final fieldHeight = [
        labelHeight,
        contentHeight,
      ].reduce((a, b) => a > b ? a : b);

      // 更新行的最大高度
      if (fieldHeight > maxHeight) {
        maxHeight = fieldHeight;
      }
    }

    // 添加padding，移除硬编码缓冲
    final paddingHeight = (config.cellPadding.top + config.cellPadding.bottom);
    final finalHeight = maxHeight + paddingHeight; // 只使用真实的padding，不添加硬编码缓冲

    return finalHeight;
  }

  /// 简化但有效的文本高度计算
  double _estimateTextHeight(
    String text,
    double fontSize,
    double availableWidth,
    PDFContext context,
  ) {
    if (text.isEmpty) {
      final emptyHeight = fontSize * 1.25; // 调整空文本高度，与最小基础高度保持一致
      return emptyHeight;
    }

    // 改进的高度计算，提高字符宽度估算精度
    final lines = text.split('\n').length; // 显式换行

    // 改进字符宽度估算：中文字符通常比英文字符宽
    final chineseCharCount = text.runes
        .where((rune) => rune > 0x4E00 && rune < 0x9FFF)
        .length;
    final englishCharCount = text.length - chineseCharCount;

    // 中文字符约为fontSize*1.0宽度，英文字符约为fontSize*0.5宽度
    final estimatedTextWidth =
        (chineseCharCount * fontSize * 1.0) +
        (englishCharCount * fontSize * 0.5);
    final estimatedLines = (estimatedTextWidth / availableWidth).ceil();

    final totalLines = [lines, estimatedLines].reduce((a, b) => a > b ? a : b);

    // 调整行高倍数，为多行文本提供适度空间
    final baseHeight = fontSize * 1.25; // 从1.4调整为1.25，提供适度垂直空间
    final calculatedHeight = totalLines * baseHeight;

    // 为多行文本增加适度的安全边距
    double finalHeight;
    if (totalLines > 3) {
      // 超过3行的文本使用适度缓冲
      finalHeight = calculatedHeight * 1.08;
    } else {
      // 短文本使用小幅缓冲
      finalHeight = calculatedHeight * 1.05;
    }

    return finalHeight;
  }

  /// 构建标题单元格
  pw.Widget _buildLabelCell(TableField field, PDFContext context) {
    return pw.Text(
      field.label,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: config.labelFontSize ?? context.theme.defaultFontSize,
        color: config.labelColor ?? context.theme.primaryColor,
        font: DefaultTheme.getFontByWeight(700),
      ),
    );
  }

  /// 构建内容单元格
  pw.Widget _buildContentCell(TableField field, PDFContext context) {
    return pw.Text(
      field.value,
      style: pw.TextStyle(
        fontSize: config.contentFontSize ?? context.theme.defaultFontSize,
        color: config.contentColor ?? context.theme.primaryColor,
        font: DefaultTheme.getFontByWeight(400),
      ),
    );
  }
}
