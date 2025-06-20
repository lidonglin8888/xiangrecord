import { RecordManager, PoopRecord } from '../model/RecordModel';
import { Logger } from '../utils/Logger';
import { NetworkDiagnostic } from '../utils/NetworkDiagnostic';
import { RecordItem } from '../components/RecordItem';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Index {
  @State records: PoopRecord[] = [];
  @State showWelcome: boolean = true;
  @State isLoading: boolean = false;
  @State isApiMode: boolean = false;
  @State connectionStatus: string = '检查中...';

  aboutToAppear() {
    this.checkApiMode();
    this.loadRecords();
    // 3秒后隐藏欢迎动画
    setTimeout(() => {
      this.showWelcome = false;
    }, 3000);
  }

  checkApiMode() {
    this.isApiMode = RecordManager.isApiMode();
    this.checkConnection();
  }

  async checkConnection() {
    if (this.isApiMode) {
      Logger.ui('开始检查API连接...');
      try {
        const isConnected = await RecordManager.checkApiConnection();
        this.connectionStatus = isConnected ? '已连接' : '连接失败';
        Logger.ui(`连接状态: ${this.connectionStatus}`);
        
        if (!isConnected) {
          Logger.error('UI', 'API连接失败，开始网络诊断...');
          
          // 执行网络诊断
          const diagnosticResults = await NetworkDiagnostic.runFullDiagnostic();
          const report = NetworkDiagnostic.generateReport(diagnosticResults);
          Logger.error('UI', '网络诊断报告:');
          Logger.error('UI', report);
          
          // 输出简化的错误信息到控制台
          Logger.error('UI', '连接失败原因分析:');
          diagnosticResults.forEach((result, index) => {
            if (!result.success) {
              Logger.error('UI', `${index + 1}. ${result.message}`);
              if (result.suggestions) {
                result.suggestions.forEach(suggestion => {
                  Logger.error('UI', `   建议: ${suggestion}`);
                });
              }
            }
          });
        }
      } catch (error) {
        Logger.error('UI', '检查连接时发生错误:', error);
        this.connectionStatus = '检查失败';
      }
    } else {
      this.connectionStatus = '本地模式';
      Logger.ui('当前为本地模式');
    }
  }

  toggleApiMode() {
    this.isApiMode = !this.isApiMode;
    RecordManager.setApiMode(this.isApiMode);
    
    if (this.isApiMode) {
      this.checkConnection();
      this.syncData();
    }
    
    this.loadRecords();
  }

  async syncData() {
    if (!this.isApiMode) return;
    
    try {
      // 同步本地数据到服务器
      await RecordManager.syncToServer();
      // 从服务器同步数据到本地
      await RecordManager.syncFromServer();
      this.loadRecords();
    } catch (error) {
      console.error('同步失败:', error);
    }
  }

  async loadRecords() {
    this.isLoading = true;
    try {
      this.records = await RecordManager.getAllRecords();
    } catch (error) {
      console.error('加载记录失败:', error);
      promptAction.showToast({
        message: '加载记录失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      if (this.showWelcome) {
        this.WelcomeAnimation()
      } else {
        this.MainContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8E7')
  }

  @Builder
  WelcomeAnimation() {
    Column() {
      Text('💩')
        .fontSize(80)
        .animation({
          duration: 1000,
          curve: Curve.EaseInOut,
          iterations: -1,
          playMode: PlayMode.Alternate
        })
        .scale({ x: 1.2, y: 1.2 })
      
      Text('便便记录小助手')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8B4513')
        .margin({ top: 20 })
      
      Text('记录每一次的小确幸~')
        .fontSize(16)
        .fontColor('#CD853F')
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MainContent() {
    Column() {
      // 顶部标题区域
      this.HeaderSection()
      
      // 快捷操作区域
      this.QuickActionSection()
      
      // 最近记录区域
      this.RecentRecordsSection()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 20 })
  }

  @Builder
  HeaderSection() {
    Column() {
      Row() {
        Column() {
          Text('便便日记')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8B4513')
          
          Text('今天的你还好吗？')
            .fontSize(14)
            .fontColor('#CD853F')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        Text('💩')
          .fontSize(40)
          .animation({
            duration: 2000,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate
          })
          .rotate({ angle: 10 })
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // API模式切换
      Row() {
        Text('云端同步')
          .fontSize(14)
          .fontColor('#8B4513')
        
        Blank()
        
        Toggle({ type: ToggleType.Switch, isOn: this.isApiMode })
          .selectedColor('#FF9500')
          .switchPointColor('#FFFFFF')
          .onChange((isOn: boolean) => {
            this.toggleApiMode();
          })
        
        Text(this.connectionStatus)
          .fontSize(12)
          .fontColor(this.connectionStatus === '已连接' ? '#32CD32' : '#FF4444')
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ horizontal: 16, vertical: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 20 })
    }
  }

  @Builder
  QuickActionSection() {
    Column() {
      Text('快捷操作')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })
      
      Row() {
        // 新增记录按钮
        Button() {
          Column() {
            Text('📝')
              .fontSize(32)
            Text('新增记录')
              .fontSize(14)
              .fontColor('#8B4513')
              .margin({ top: 8 })
          }
        }
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .width('48%')
        .height(100)
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddRecord' });
        })
        
        Blank()
        
        // 历史记录按钮
        Button() {
          Column() {
            Text('📊')
              .fontSize(32)
            Text('历史记录')
              .fontSize(14)
              .fontColor('#8B4513')
              .margin({ top: 8 })
          }
        }
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .width('48%')
        .height(100)
        .onClick(() => {
          router.pushUrl({ url: 'pages/HistoryList' });
        })
      }
      .width('100%')
    }
    .margin({ bottom: 24 })
  }

  @Builder
  RecentRecordsSection() {
    Column() {
      Row() {
        Text('最近记录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#8B4513')
        
        Blank()
        
        Text('查看全部')
          .fontSize(14)
          .fontColor('#FF9500')
          .onClick(() => {
            router.pushUrl({ url: 'pages/HistoryList' });
          })
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      if (this.isLoading) {
        LoadingProgress()
          .color('#FF9500')
          .width(40)
          .height(40)
          .margin({ top: 20 })
      } else if (this.records.length === 0) {
        Column() {
          Text('🌟')
            .fontSize(48)
          Text('还没有记录哦')
            .fontSize(16)
            .fontColor('#CD853F')
            .margin({ top: 12 })
          Text('点击上方按钮开始记录吧~')
            .fontSize(14)
            .fontColor('#DEB887')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ vertical: 40 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List() {
          ForEach(this.records.slice(0, 3), (record: PoopRecord) => {
            ListItem() {
              RecordItem({ record: record })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/RecordDetail',
                    params: { recordId: record.id }
                  });
                })
            }
          })
        }
        .width('100%')
        .divider({ strokeWidth: 1, color: '#F0F0F0' })
      }
    }
    .layoutWeight(1)
  }
}