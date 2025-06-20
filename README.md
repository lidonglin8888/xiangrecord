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

## 技术架构 🏗️

### 核心技术
- **开发框架**：HarmonyOS Next ArkTS
- **UI框架**：ArkUI
- **数据存储**：AppStorage (本地持久化存储)
- **状态管理**：@State、@Prop装饰器
- **路由导航**：Router API

### 开发环境
- **DevEco Studio**: 5.0.3.900 或更高版本
- **HarmonyOS SDK**: API 12 或更高版本
- **Node.js**: 18.x 或更高版本

### 构建命令
```bash
node "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
```

## 项目结构

```
entry/src/main/ets/
├── model/
│   └── RecordModel.ets          # 数据模型和管理类
├── pages/
│   ├── Index.ets                # 主页面
│   ├── AddRecord.ets            # 新增记录页面
│   ├── HistoryList.ets          # 历史记录列表页面
│   └── RecordDetail.ets         # 记录详情页面
├── components/                  # 组件目录
├── utils/                       # 工具类
└── resources/                   # 资源文件
```

## 许可证 📄

本项目采用 MIT 许可证

## 联系方式 📧

- 作者：lidonglin8888
- GitHub：[@lidonglin8888](https://github.com/lidonglin8888)

---

**注意**：本应用仅用于个人健康记录，不能替代专业医疗建议。