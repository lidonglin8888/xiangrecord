# HarmonyOS promptAction.showToast 异常处理修复

## 问题描述

在 `AddRecord.ets` 文件的 `submitRecord` 方法中，`Logger.info('API', '记录已保存到云端！')` 成功执行后，后续的代码（包括 `promptAction.showToast`、状态重置和页面跳转）没有执行。

## 根本原因

根据 HarmonyOS 官方文档和社区反馈，`promptAction.showToast` 可能抛出以下异常：

### 错误码 100001: UI execution context not found

<mcreference link="https://ost.51cto.com/posts/22746" index="2">2</mcreference> 这个错误通常发生在以下情况：

1. **异步操作后调用**: 在 `await` 异步操作后，UI 上下文可能已经发生变化
2. **预览器环境**: <mcreference link="http://bbs.itying.com/topic/6705ca9dbb648a00d0986f82" index="4">4</mcreference> 预览器环境不支持完整的 UI 上下文
3. **UI 上下文不明确**: <mcreference link="https://m.seaxiang.com/blog/785e46f43b55448998e15c42ccd4fe9b" index="5">5</mcreference> 在 UI 上下文不明确的地方使用

## 解决方案

### 1. 异常捕获包装

将 `promptAction.showToast` 调用包装在 try-catch 块中，确保即使 Toast 显示失败也不会影响后续代码执行：

```typescript
// 安全地显示成功提示
try {
  promptAction.showToast({
    message: RecordManager.isApiMode() ? '记录已保存到云端！🎉' : '记录保存成功！🎉',
    duration: 2000
  });
} catch (toastError) {
  Logger.error('UI', `显示成功提示失败: ${toastError}`);
}
```

### 2. 错误处理最佳实践

<mcreference link="https://ost.51cto.com/posts/22746" index="2">2</mcreference> 官方推荐的错误处理方式：

```typescript
try {
  promptAction.showToast({
    message: 'Message Info',
    duration: 2000
  });
} catch (error) {
  console.error(`showToast args error code is ${error.code}, message is ${error.message}`);
}
```

### 3. 替代方案（如果问题持续）

如果 `promptAction.showToast` 持续出现问题，可以考虑使用 UIContext 方式：

<mcreference link="http://bbs.itying.com/topic/6705ca9dbb648a00d0986f82" index="4">4</mcreference>

```typescript
let context: UIContext = this.getUIContext() as UIContext;
let promptAction = context.getPromptAction();
promptAction.showToast({ message: data });
```

## 修复后的代码结构

```typescript
try {
  await RecordManager.saveRecord(record);
  Logger.info('API', '记录已保存到云端！')
  
  // 安全地显示成功提示
  try {
    promptAction.showToast({
      message: RecordManager.isApiMode() ? '记录已保存到云端！🎉' : '记录保存成功！🎉',
      duration: 2000
    });
  } catch (toastError) {
    Logger.error('UI', `显示成功提示失败: ${toastError}`);
  }
  
  this.isSubmitting = false; // 重置提交状态
  
  setTimeout(() => {
    router.back();
  }, 1000);
} catch (error) {
  Logger.error('API', `保存记录失败: ${error}`);
  
  // 安全地显示失败提示
  try {
    promptAction.showToast({
      message: '保存失败，请重试',
      duration: 2000
    });
  } catch (toastError) {
    Logger.error('UI', `显示失败提示失败: ${toastError}`);
  }
  
  this.isSubmitting = false;
}
```

## 预防措施

1. **始终包装 UI 操作**: 将所有 `promptAction` 调用包装在 try-catch 中
2. **添加日志记录**: 记录 Toast 显示失败的情况，便于调试
3. **确保核心逻辑不依赖 UI**: 状态重置和页面跳转不应依赖 Toast 的成功显示
4. **测试不同环境**: 在真机和预览器中都进行测试

## 验证方法

1. 重新执行创建记录操作
2. 检查日志输出，确认：
   - `Logger.info('API', '记录已保存到云端！')` 执行
   - 状态重置 `this.isSubmitting = false` 执行
   - 页面跳转 `router.back()` 执行
   - 如果 Toast 失败，应该看到错误日志

## 参考资料

- <mcreference link="https://ost.51cto.com/posts/22746" index="2">2</mcreference> HarmonyOS API：@ohos.promptAction (弹窗)
- <mcreference link="http://bbs.itying.com/topic/6705ca9dbb648a00d0986f82" index="4">4</mcreference> promptAction.showToast UI execution context not found 解决方案
- <mcreference link="https://m.seaxiang.com/blog/785e46f43b55448998e15c42ccd4fe9b" index="5">5</mcreference> HarmonyOS promptAction 官方文档