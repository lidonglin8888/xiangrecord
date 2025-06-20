import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { image } from '@kit.ImageKit';
import { componentSnapshot } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import prompt from '@ohos.prompt';
import fs from '@ohos.file.fs';
import { PoopRecord } from '../model/RecordModel';

// 定义选项接口
interface OptionItem {
  value: string;
  label: string;
}

// 定义分享选项接口
interface ShareOptions {
  previewMode: systemShare.SharePreviewMode;
  selectionMode: systemShare.SelectionMode;
}

/**
 * 分享工具类
 * 提供文本分享、图片分享等功能
 */
export class ShareUtils {
  
  static async shareText(text: string, title?: string, context?: common.UIAbilityContext): Promise<void> {
    try {
      const sharedData = new systemShare.SharedData({
        utd: uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
        content: text
      });
      
      const controller = new systemShare.ShareController(sharedData);
      
      const targetContext = context || ShareUtils.getContext();
      await controller.show(targetContext, {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      });
      
      prompt.showToast({
        message: '分享成功',
        duration: 2000
      });
    } catch (error) {
      console.error('分享文本失败:', error);
      prompt.showToast({
        message: '分享失败',
        duration: 2000
      });
    }
  }

  static async shareImage(imageUri: string, title?: string, context?: common.UIAbilityContext): Promise<void> {
    try {
      const sharedData = new systemShare.SharedData({
        utd: uniformTypeDescriptor.UniformDataType.IMAGE,
        content: imageUri
      });
      
      const controller = new systemShare.ShareController(sharedData);
      
      const targetContext = context || ShareUtils.getContext();
      await controller.show(targetContext, {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      });
      
      prompt.showToast({
        message: '分享成功',
        duration: 2000
      });
    } catch (error) {
      console.error('分享图片失败:', error);
      prompt.showToast({
        message: '分享失败',
        duration: 2000
      });
    }
  }

  static async shareComponentSnapshot(componentId: string, title?: string, context?: common.UIAbilityContext): Promise<void> {
    try {
      // 获取组件截图
      const pixelMap = await componentSnapshot.get(componentId);
      const imageUri = await ShareUtils.savePixelMapToFile(pixelMap);
      
      const sharedData = new systemShare.SharedData({
        utd: uniformTypeDescriptor.UniformDataType.IMAGE,
        content: imageUri
      });
      
      const controller = new systemShare.ShareController(sharedData);
      
      const targetContext = context || ShareUtils.getContext();
      await controller.show(targetContext, {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      });
      
      prompt.showToast({
        message: '分享成功',
        duration: 2000
      });
    } catch (error) {
      console.error('分享组件截图失败:', error);
      prompt.showToast({
        message: '分享失败',
        duration: 2000
      });
    }
  }

  static async shareRecord(record: PoopRecord, componentId?: string, context?: common.UIAbilityContext): Promise<void> {
    try {
      const recordText = ShareUtils.formatRecordText(record);
      
      const sharedData = new systemShare.SharedData({
        utd: uniformTypeDescriptor.UniformDataType.PLAIN_TEXT,
        content: recordText
      });
      
      const controller = new systemShare.ShareController(sharedData);
      
      await controller.show(ShareUtils.getContext(), {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      });
      
      prompt.showToast({
        message: '分享成功',
        duration: 2000
      });
    } catch (error) {
      console.error('分享记录失败:', error);
      prompt.showToast({
        message: '分享失败',
        duration: 2000
      });
    }
  }

  private static formatRecordText(record: PoopRecord): string {
    return `我的便便记录 📊\n` +
      `时间: ${ShareUtils.formatDate(record.date)} ${record.time}\n` +
      `心情: ${ShareUtils.getMoodLabel(record.mood)}\n` +
      `特征: ${ShareUtils.getColorLabel(record.color)} · ${ShareUtils.getShapeLabel(record.shape)} · ${ShareUtils.getSizeLabel(record.size)}\n` +
      `来自便便记录小助手 💩`;
  }

  private static getContext(): common.UIAbilityContext {
    // 获取当前应用上下文
    return getContext() as common.UIAbilityContext;
  }

  private static async savePixelMapToFile(pixelMap: image.PixelMap): Promise<string> {
    try {
      // 创建图片打包器
      const imagePackerApi = image.createImagePacker();
      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: 90
      };
      
      // 将PixelMap打包为图片数据
      const imageData = await imagePackerApi.packing(pixelMap, packOpts);
      
      // 获取应用缓存目录
      const context = ShareUtils.getContext();
      const cacheDir = context.cacheDir;
      const fileName = `share_image_${Date.now()}.jpg`;
      const filePath = `${cacheDir}/${fileName}`;
      
      // 将图片数据写入文件
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, imageData);
      fs.closeSync(file);
      
      // 返回文件URI
      return `file://${filePath}`;
    } catch (err) {
      console.error('保存图片文件失败:', err);
      throw new Error(`保存图片文件失败: ${err}`);
    }
  }

  // 辅助方法
  private static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private static getMoodLabel(mood: string): string {
    const MOOD_OPTIONS: OptionItem[] = [
      { value: 'happy', label: '😊 开心' },
      { value: 'normal', label: '😐 一般' },
      { value: 'tired', label: '😴 疲惫' },
      { value: 'uncomfortable', label: '😣 不适' }
    ];
    const option = MOOD_OPTIONS.find(opt => opt.value === mood);
    return option ? option.label : mood;
  }

  private static getColorLabel(color: string): string {
    const COLOR_OPTIONS: OptionItem[] = [
      { value: 'brown', label: '棕色' },
      { value: 'yellow', label: '黄色' },
      { value: 'green', label: '绿色' },
      { value: 'black', label: '黑色' },
      { value: 'red', label: '红色' }
    ];
    const option = COLOR_OPTIONS.find(opt => opt.value === color);
    return option ? option.label : color;
  }

  private static getShapeLabel(shape: string): string {
    const SHAPE_OPTIONS: OptionItem[] = [
      { value: 'normal', label: '正常' },
      { value: 'hard', label: '硬块' },
      { value: 'soft', label: '软便' },
      { value: 'loose', label: '稀便' },
      { value: 'watery', label: '水样' }
    ];
    const option = SHAPE_OPTIONS.find(opt => opt.value === shape);
    return option ? option.label : shape;
  }

  private static getSizeLabel(size: string): string {
    const SIZE_OPTIONS: OptionItem[] = [
      { value: 'small', label: '小' },
      { value: 'medium', label: '中' },
      { value: 'large', label: '大' }
    ];
    const option = SIZE_OPTIONS.find(opt => opt.value === size);
    return option ? option.label : size;
  }
}