# 便便记录小助手 💩

一个可爱俏皮的HarmonyOS Next排泄物记录应用，帮助用户记录和追踪每次排泄的详细情况。

## 功能特点 ✨

### 1. 记录功能
- **多维度记录**：颜色、气味、干湿度、形状、大小、质地、心情等
- **分步式录入**：友好的分步引导界面，降低录入复杂度
- **可爱的界面**：使用emoji和温暖的色彩，营造轻松愉快的使用体验
- **实时保存**：本地存储，数据安全可靠

### 2. 查看功能
- **历史记录列表**：按时间倒序展示所有记录
- **搜索筛选**：支持按关键词搜索和时间筛选（今天/一周/一月）
- **详细信息**：点击记录查看完整的详细信息
- **统计概览**：显示总记录数、今日记录数、常见心情等统计信息

### 3. 管理功能
- **删除记录**：支持单条记录删除，带确认提示
- **分享功能**：可以分享记录摘要（开发中）
- **数据持久化**：使用AppStorage进行本地数据存储

## 界面设计 🎨

### 设计理念
- **可爱俏皮**：大量使用emoji表情和圆润的设计元素
- **年轻化**：明亮的配色方案，橙色主色调配合温暖的背景色
- **用户友好**：清晰的导航结构，直观的操作流程

### 配色方案
- 主色调：`#FF9500` (橙色)
- 背景色：`#FFF8E7` (温暖米色)
- 辅助色：`#8B4513` (棕色文字)
- 卡片背景：`#FFFFFF` (纯白)

## 技术架构 🏗️

### 项目结构
```
entry/src/main/ets/
├── model/
│   └── RecordModel.ets          # 数据模型和管理类
├── pages/
│   ├── Index.ets                # 主页面
│   ├── AddRecord.ets            # 新增记录页面
│   ├── HistoryList.ets          # 历史记录列表页面
│   └── RecordDetail.ets         # 记录详情页面
└── resources/                   # 资源文件
```

### 核心组件

#### 1. RecordModel.ets
- **PoopRecord接口**：定义记录数据结构
- **选项常量**：预定义的颜色、气味、形状等选项
- **RecordManager类**：数据存储和管理的核心类

#### 2. 页面组件
- **Index.ets**：主页面，包含欢迎动画、快捷操作、最近记录
- **AddRecord.ets**：分步式表单，引导用户完成记录
- **HistoryList.ets**：记录列表，支持搜索和筛选
- **RecordDetail.ets**：详细信息展示和操作

## 数据模型 📊

### PoopRecord 接口
```typescript
interface PoopRecord {
  id: string;          // 唯一标识
  date: Date;          // 记录日期
  time: string;        // 记录时间
  color: string;       // 颜色
  smell: string;       // 气味
  moisture: string;    // 干湿度
  shape: string;       // 形状
  size: string;        // 大小
  texture: string;     // 质地
  notes?: string;      // 备注（可选）
  mood: string;        // 心情
}
```

### 选项配置
每个维度都有预定义的选项，包含：
- `value`：存储值
- `label`：显示文本
- `emoji`：对应的emoji表情
- `color`：颜色值（仅颜色选项）

## 使用说明 📱

### 1. 添加记录
1. 点击主页的"新增记录"按钮
2. 按照步骤选择各个维度的特征
3. 可选择添加备注
4. 点击"完成记录"保存

### 2. 查看历史
1. 点击主页的"历史记录"按钮
2. 在列表中浏览所有记录
3. 使用搜索框或时间筛选功能
4. 点击记录查看详细信息

### 3. 管理记录
1. 在详情页面可以删除记录
2. 支持分享记录摘要（开发中）

## 开发环境 🛠️

### 技术栈
- **开发平台**：DevEco Studio
- **开发语言**：ArkTS
- **UI框架**：ArkUI
- **目标平台**：HarmonyOS Next
- **数据存储**：AppStorage (本地存储)

### 环境要求
- DevEco Studio 5.1.1+
- HarmonyOS SDK 5.1.1+
- Node.js 18+

### 构建命令
```bash
# 构建应用
node "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
```

## 项目特色 🌟

### 1. 用户体验
- **零学习成本**：直观的图标和文字说明
- **快速录入**：分步式界面，每步只需简单选择
- **视觉愉悦**：温暖的配色和可爱的emoji

### 2. 数据管理
- **本地存储**：数据安全，无需联网
- **持久化**：应用重启后数据不丢失
- **结构化**：规范的数据模型，便于扩展

### 3. 功能完整
- **记录**：全面的维度覆盖
- **查看**：多种查看和筛选方式
- **管理**：删除、分享等操作

## 后续规划 🚀

### 短期目标
- [ ] 完善分享功能
- [ ] 添加数据导出功能
- [ ] 优化界面动画效果
- [ ] 添加更多统计图表

### 长期目标
- [ ] 云端同步功能
- [ ] 多用户支持
- [ ] 健康建议功能
- [ ] 数据分析报告

## 贡献指南 🤝

欢迎提交Issue和Pull Request！

### 开发流程
1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 发起 Pull Request

### 代码规范
- 使用 TypeScript 严格模式
- 遵循 ArkTS 编码规范
- 添加必要的注释
- 保持代码整洁

## 许可证 📄

MIT License

## 联系方式 📧

如有问题或建议，请通过以下方式联系：
- GitHub Issues
- Email: [your-email@example.com]

---

**让记录变得有趣！** 💩✨