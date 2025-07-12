# PDF Export Print 库字体配置

## 字体文件说明

此目录包含PDF组件库使用的中文字体文件。

### 支持的字体文件：

- `chinese-thin.ttf` (weight: 100)
- `chinese-light.ttf` (weight: 300)  
- `chinese-regular.ttf` (weight: 400)
- `chinese-medium.ttf` (weight: 500)
- `chinese-bold.ttf` (weight: 700)
- `chinese-black.ttf` (weight: 900)

### 其他支持的前缀：

- `NotoSansCJK-*.ttf`
- `SourceHanSans-*.ttf`
- `PingFang-*.ttf`

### 使用说明

1. 将中文字体文件放置在此目录下
2. 按照上述命名格式重命名字体文件
3. 库会自动检测并加载可用的字体
4. 根据TextStyle的fontWeight自动选择对应的字体文件

### 推荐字体

- **Google Noto Sans CJK**: https://fonts.google.com/noto/specimen/Noto+Sans+SC
- **Adobe Source Han Sans**: https://github.com/adobe-fonts/source-han-sans
- **阿里巴巴普惠体**: https://fonts.alibabagroup.com/

### 注意事项

- 字体文件会被打包到库中，影响库的大小
- 建议只包含必要的字体weight
- 字体文件需要有合适的许可证用于分发
