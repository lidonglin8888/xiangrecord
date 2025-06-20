import { ShareUtils } from '../utils/ShareUtils';
import { common } from '@kit.AbilityKit';
import prompt from '@ohos.prompt';
import router from '@ohos.router';
import { TopNavigation } from '../components/TopNavigation';
import { PoopRecord } from '../model/RecordModel';

@Entry
@Component
struct ShareTestPage {
  private context = getContext(this) as common.UIAbilityContext;
  
  // 测试用的便便记录数据
  private testRecord: PoopRecord = {
    id: 999,
    date: new Date(),
    time: '14:30',
    mood: 'happy',
    color: 'brown',
    shape: 'normal',
    size: 'medium',
    moisture: 'normal',
    texture: 'smooth',
    smell: 'normal',
    notes: '这是一条测试分享功能的便便记录',
    userId: '1'
  };

  build() {
    Column() {
      TopNavigation({
        title: '分享功能测试',
        showBackButton: true,
        onBack: () => {
          router.back();
        }
      })
      
      Scroll() {
        Column() {
          Text('分享功能测试')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })
          
          // 测试记录卡片
          Column() {
            Text('测试记录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 12 })
            
            Text(`时间: ${this.testRecord.date} ${this.testRecord.time}`)
              .fontSize(16)
              .margin({ bottom: 8 })
            
            Text(`心情: 😊 开心`)
              .fontSize(16)
              .margin({ bottom: 8 })
            
            Text(`特征: 棕色 · 正常 · 中等`)
              .fontSize(16)
              .margin({ bottom: 8 })
            
            Text(`备注: ${this.testRecord.notes}`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 16 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 20 })
          .id('testRecordCard')
          
          // 分享按钮组
          Column() {
            Text('分享测试')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16 })
            
            Button('分享文本')
              .width('100%')
              .height(48)
              .backgroundColor('#007AFF')
              .borderRadius(8)
              .margin({ bottom: 12 })
              .onClick(() => {
                this.shareText();
              })
            
            Button('分享记录（文本）')
              .width('100%')
              .height(48)
              .backgroundColor('#34C759')
              .borderRadius(8)
              .margin({ bottom: 12 })
              .onClick(() => {
                this.shareRecordText();
              })
            
            Button('分享记录（含截图）')
              .width('100%')
              .height(48)
              .backgroundColor('#FF9500')
              .borderRadius(8)
              .margin({ bottom: 12 })
              .onClick(() => {
                this.shareRecordWithImage();
              })
            
            Button('分享组件截图')
              .width('100%')
              .height(48)
              .backgroundColor('#AF52DE')
              .borderRadius(8)
              .onClick(() => {
                this.shareComponentSnapshot();
              })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  async shareText() {
    try {
      await ShareUtils.shareText(
        '这是一条测试分享功能的文本消息 📝\n\n来自便便记录小助手 💩',
        '测试分享'
      );
    } catch (error) {
      console.error('分享文本失败:', error);
      prompt.showToast({
        message: '分享失败，请重试',
        duration: 2000
      });
    }
  }
  
  async shareRecordText() {
    try {
      await ShareUtils.shareRecord(this.testRecord);
    } catch (error) {
      console.error('分享记录失败:', error);
      prompt.showToast({
        message: '分享失败，请重试',
        duration: 2000
      });
    }
  }
  
  async shareRecordWithImage() {
    try {
      // shareRecord now only supports text, so we call shareComponentSnapshot directly
      await ShareUtils.shareComponentSnapshot('testRecordCard', '便便记录截图');
    } catch (error) {
      console.error('分享记录失败:', error);
      prompt.showToast({
        message: '分享失败，请重试',
        duration: 2000
      });
    }
  }
  
  async shareComponentSnapshot() {
    try {
      await ShareUtils.shareComponentSnapshot('testRecordCard', '便便记录截图');
    } catch (error) {
      console.error('分享截图失败:', error);
      prompt.showToast({
        message: '分享失败，请重试',
        duration: 2000
      });
    }
  }
}