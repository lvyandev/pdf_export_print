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

    // 按 sort 值升序排列，null值排在最后，相同 sort 值保持原始顺序（稳定排序）
    final sortedFields = List<TableField>.from(fields);
    sortedFields.sort((a, b) {
      // null值排在最后
      if (a.sort == null && b.sort == null) return 0;
      if (a.sort == null) return 1; // a排在后面
      if (b.sort == null) return -1; // b排在后面

      // 都不为null时，按升序排列（数值越小越靠前）
      return a.sort!.compareTo(b.sort!);
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
    int currentFieldCount = 0;

    // 获取每行最大字段数（如果配置中有）
    final int maxFieldsPerRow = config is MainTableConfig
        ? (config as MainTableConfig).fieldsPerRow
        : 3; // 默认每行3个字段

    for (final field in fields) {
      // 获取字段的有效宽度百分比
      final fieldWidth = field.getEffectiveWidthPercent();

      // 检查当前行是否还能容纳这个字段（基于百分比和字段数量）
      final bool rowFullByWidth = currentRowSpan + fieldWidth > 1.0;
      final bool rowFullByCount = currentFieldCount >= maxFieldsPerRow;

      if (rowFullByWidth || rowFullByCount) {
        // 当前行已满，开始新行
        if (currentRow.isNotEmpty) {
          rows.add(currentRow);
          currentRow = [];
          currentRowSpan = 0.0;
          currentFieldCount = 0;
        }
      }

      currentRow.add(field);
      currentRowSpan += fieldWidth;
      currentFieldCount++;

      // 如果当前行正好填满，开始新行
      if (currentRowSpan >= 1.0 || currentFieldCount >= maxFieldsPerRow) {
        rows.add(currentRow);
        currentRow = [];
        currentRowSpan = 0.0;
        currentFieldCount = 0;
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
    final List<pw.Widget> widgets = [];

    // 计算当前行所有字段的总宽度
    double totalRowWidth = 0.0;
    for (final field in fields) {
      totalRowWidth += field.getEffectiveWidthPercent();
    }

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];

      // 获取字段的有效宽度百分比
      final fieldWidth = field.getEffectiveWidthPercent();

      // 将 widthPercent 转换为 flex 值（基于6等份网格系统）
      final fieldFlex = (fieldWidth * 6).round().clamp(2, 6); // 最小2份，确保有内容空间

      // 在字段内部，标题固定占1份，内容占剩余份数
      // 标题始终占据 1/6 宽度（固定不变）
      final labelFlex = 1;
      // 内容占据：字段总份数 - 标题份数(1)，最小为1
      final contentFlex = (fieldFlex - 1).clamp(1, 5);

      // 将整个字段作为一个单元，按照 widthPercent 占据行内空间
      widgets.add(
        pw.Expanded(
          flex: fieldFlex,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 标题部分（固定占1份）
              pw.Expanded(
                flex: labelFlex,
                child: pw.Container(
                  height: rowHeight,
                  padding: config.cellPadding,
                  decoration: (showBorder && config.showInnerBorder)
                      ? pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(
                              color:
                                  config.borderColor ??
                                  context.theme.borderColor,
                              width:
                                  config.borderWidth ??
                                  context.theme.borderWidth,
                            ),
                          ),
                        )
                      : null,
                  child: _buildLabelCell(field, context),
                ),
              ),
              // 内容部分（占剩余份数）
              pw.Expanded(
                flex: contentFlex,
                child: pw.Container(
                  height: rowHeight,
                  padding: config.cellPadding,
                  decoration: (showBorder && config.showInnerBorder)
                      ? pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(
                              color:
                                  config.borderColor ??
                                  context.theme.borderColor,
                              width:
                                  config.borderWidth ??
                                  context.theme.borderWidth,
                            ),
                          ),
                        )
                      : null,
                  child: _buildContentCell(field, context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 如果当前行的总宽度小于1.0，添加空白填充
    if (totalRowWidth < 1.0) {
      final remainingWidth = 1.0 - totalRowWidth;
      final remainingFlex = (remainingWidth * 6).round();
      if (remainingFlex > 0) {
        widgets.add(
          pw.Expanded(
            flex: remainingFlex,
            child: pw.Container(), // 空白填充
          ),
        );
      }
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

      // 获取字段的有效宽度百分比
      final fieldWidth = field.getEffectiveWidthPercent();

      // 标题固定占据 1/6 页面宽度
      final labelWidth = pageWidth / 6.0;

      // 内容宽度 = 字段总宽度 - 标题宽度
      final fieldTotalWidth = pageWidth * fieldWidth;
      final contentWidth = fieldTotalWidth - labelWidth;

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
