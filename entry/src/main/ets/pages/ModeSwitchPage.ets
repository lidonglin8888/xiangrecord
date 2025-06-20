import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { UserManager, AppMode } from '../model/UserModel';
import { RecordManager } from '../model/RecordModel';
import { AuthService } from '../service/AuthService';
import { Logger } from '../utils/Logger';

@Entry
@Component
struct ModeSwitchPage {
  @State currentMode: AppMode = AppMode.GUEST;
  @State isLoading: boolean = false;
  @State guestRecordCount: number = 0;
  @State hasGuestData: boolean = false;
  @State isGuestDataSynced: boolean = false;

  aboutToAppear() {
    this.loadCurrentState();
  }

  async loadCurrentState() {
    this.currentMode = UserManager.getCurrentMode();
    
    // 检查访客数据
    const guestRecords = RecordManager.getGuestRecords();
    this.guestRecordCount = guestRecords.length;
    this.hasGuestData = this.guestRecordCount > 0;
    
    // 检查访客数据是否已同步
    this.isGuestDataSynced = await UserManager.isGuestDataSynced();
  }

  // 切换到云端模式
  async switchToCloudMode() {
    try {
      // 跳转到登录页面
      router.pushUrl({
        url: 'pages/LoginPage'
      });
    } catch (error) {
      Logger.error('MODE_SWITCH', 'Failed to navigate to login page:', error);
      promptAction.showToast({
        message: '跳转失败',
        duration: 2000
      });
    }
  }

  // 继续使用访客模式
  continueGuestMode() {
    router.back();
  }

  // 同步访客数据到云端
  async syncGuestDataToCloud() {
    if (!UserManager.isLoggedIn()) {
      promptAction.showToast({
        message: '请先登录',
        duration: 2000
      });
      return;
    }

    this.isLoading = true;
    try {
      const success = await RecordManager.syncGuestDataToCloud();
      if (success) {
        this.isGuestDataSynced = true;
        promptAction.showToast({
          message: `成功同步 ${this.guestRecordCount} 条记录到云端`,
          duration: 3000
        });
      } else {
        promptAction.showToast({
          message: '同步失败，请稍后重试',
          duration: 2000
        });
      }
    } catch (error) {
      Logger.error('MODE_SWITCH', 'Failed to sync guest data:', error);
      promptAction.showToast({
        message: '同步失败：' + error.message,
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 清空访客数据
  showClearGuestDataDialog() {
    AlertDialog.show({
      title: '清空访客数据',
      message: `确定要清空 ${this.guestRecordCount} 条访客记录吗？此操作不可恢复。`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定清空',
        fontColor: '#FF4444',
        action: () => {
          this.clearGuestData();
        }
      }
    });
  }

  async clearGuestData() {
    try {
      const success = RecordManager.clearGuestRecords();
      if (success) {
        this.guestRecordCount = 0;
        this.hasGuestData = false;
        await UserManager.resetGuestDataSyncStatus();
        this.isGuestDataSynced = false;
        
        promptAction.showToast({
          message: '访客数据已清空',
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '清空失败',
          duration: 2000
        });
      }
    } catch (error) {
      Logger.error('MODE_SWITCH', 'Failed to clear guest data:', error);
      promptAction.showToast({
        message: '清空失败：' + error.message,
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('返回')
          .fontSize(16)
          .fontColor('#666666')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.continueGuestMode())
        Text('模式选择')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Text('')
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // 当前模式显示
          Column() {
            Text('当前模式')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 8 })
            
            Text(this.currentMode === AppMode.GUEST ? '访客模式' : '云端模式')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.currentMode === AppMode.GUEST ? '#FF6B35' : '#8B4513')
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 20 })

          // 访客模式卡片
          Column() {
            Row() {
              Column() {
                Text('🏠 访客模式')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF6B35')
                  .margin({ bottom: 4 })
                
                Text('数据仅保存在本地设备')
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              if (this.currentMode === AppMode.GUEST) {
                Text('当前模式')
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#FF6B35')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(10)
              }
            }
            .width('100%')
            .margin({ bottom: 16 })

            Text('• 无需注册登录，立即使用\n• 数据保存在本地，隐私安全\n• 不支持多设备同步\n• 卸载应用后数据丢失')
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(20)

            if (this.currentMode !== AppMode.GUEST) {
              Button('切换到访客模式')
                .width('100%')
                .height(40)
                .fontSize(14)
                .fontColor('#FF6B35')
                .backgroundColor('#FFF5F0')
                .borderRadius(20)
                .border({ width: 1, color: '#FF6B35' })
                .margin({ top: 16 })
                .onClick(() => {
                  UserManager.switchToGuestMode();
                  this.currentMode = AppMode.GUEST;
                })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({
            width: this.currentMode === AppMode.GUEST ? 2 : 1,
            color: this.currentMode === AppMode.GUEST ? '#FF6B35' : '#E0E0E0'
          })
          .margin({ bottom: 16 })

          // 云端模式卡片
          Column() {
            Row() {
              Column() {
                Text('☁️ 云端模式')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#8B4513')
                  .margin({ bottom: 4 })
                
                Text('数据同步到云端，多设备共享')
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              if (this.currentMode === AppMode.CLOUD) {
                Text('当前模式')
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#8B4513')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(10)
              }
            }
            .width('100%')
            .margin({ bottom: 16 })

            Text('• 支持多种登录方式\n• 数据云端备份，永不丢失\n• 多设备实时同步\n• 更多高级功能')
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(20)

            if (this.currentMode !== AppMode.CLOUD) {
              Button('切换到云端模式')
                .width('100%')
                .height(40)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#8B4513')
                .borderRadius(20)
                .margin({ top: 16 })
                .onClick(() => this.switchToCloudMode())
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({
            width: this.currentMode === AppMode.CLOUD ? 2 : 1,
            color: this.currentMode === AppMode.CLOUD ? '#8B4513' : '#E0E0E0'
          })
          .margin({ bottom: 20 })

          // 访客数据管理
          if (this.hasGuestData) {
            Column() {
              Text('访客数据管理')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 16 })
              
              Row() {
                Text('📊')
                  .fontSize(20)
                  .margin({ right: 12 })
                
                Column() {
                  Text(`${this.guestRecordCount} 条记录`)
                    .fontSize(16)
                    .fontColor('#333333')
                    .alignSelf(ItemAlign.Start)
                  
                  Text(this.isGuestDataSynced ? '已同步到云端' : '尚未同步')
                    .fontSize(12)
                    .fontColor(this.isGuestDataSynced ? '#4CAF50' : '#FF9800')
                    .alignSelf(ItemAlign.Start)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 16 })

              if (UserManager.isLoggedIn() && !this.isGuestDataSynced) {
                Button(this.isLoading ? '同步中...' : '同步到云端')
                  .width('100%')
                  .height(40)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#4CAF50')
                  .borderRadius(20)
                  .enabled(!this.isLoading)
                  .margin({ bottom: 8 })
                  .onClick(() => this.syncGuestDataToCloud())
              }

              Button('清空访客数据')
                .width('100%')
                .height(40)
                .fontSize(14)
                .fontColor('#FF4444')
                .backgroundColor('#FFEBEE')
                .borderRadius(20)
                .border({ width: 1, color: '#FF4444' })
                .onClick(() => this.showClearGuestDataDialog())
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ bottom: 20 })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      }
      .layoutWeight(1)
      .backgroundColor('#F8F8F8')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}