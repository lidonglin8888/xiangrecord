import { RecordManager, PoopRecord } from '../model/RecordModel';
import { UserManager, AppMode } from '../model/UserModel';
import { RecordItem } from '../components/RecordItem';
import { Logger } from '../utils/Logger';
import { NetworkDiagnostic } from '../utils/NetworkDiagnostic';
import router from '@ohos.router';
import prompt from '@ohos.prompt';
import { router as arkRouter } from '@kit.ArkUI';

// 定义功能项接口
interface FunctionItem {
  icon: string;
  title: string;
  action: () => void | Promise<void>;
}

@Entry
@Component
struct MainTabs {
  @State currentTabIndex: number = 0;
  @State records: PoopRecord[] = [];
  @State showWelcome: boolean = true;
  @State isLoading: boolean = false;
  @State isApiMode: boolean = false;
  @State connectionStatus: string = '检查中...';

  async aboutToAppear() {
    // 初始化用户管理器，读取上次的模式
    await UserManager.initialize();
    
    // 检查当前模式并处理相应逻辑
    await this.checkAppMode();
    
    this.checkApiMode();
    this.loadRecords();
    // 3秒后隐藏欢迎动画
    setTimeout(() => {
      this.showWelcome = false;
    }, 3000);
  }

  // 页面重新显示时检查模式状态
  async onPageShow() {
    Logger.info('UI', 'MainTabs page shown, checking app mode');
    // 重新检查应用模式，处理从其他页面返回的情况
    await this.checkAppMode();
    this.checkApiMode();
    // 重新加载记录以确保数据同步
    this.loadRecords();
  }

  // 检查应用模式并处理相应逻辑
  async checkAppMode() {
    // 检查用户登录状态，根据登录状态自动设置模式
    if (UserManager.isLoggedIn()) {
      // 用户已登录，自动切换到云端模式
      if (UserManager.getCurrentMode() !== AppMode.CLOUD) {
        await UserManager.switchToCloudMode();
        Logger.info('UI', '用户已登录，自动切换到云端模式');
      }
      // 设置为API模式
      RecordManager.setApiMode(true);
      this.isApiMode = true;
      Logger.ui('云端模式且用户已登录，设置为API模式');
    } else {
      // 用户未登录，自动切换到本地模式
      if (UserManager.getCurrentMode() !== AppMode.GUEST) {
        await UserManager.switchToGuestMode();
        Logger.info('UI', '用户未登录，自动切换到本地模式');
      }
      // 设置为本地模式
      RecordManager.setApiMode(false);
      this.isApiMode = false;
      Logger.ui('访客模式，设置为本地模式');
    }
    
    const currentMode = UserManager.getCurrentMode();
    Logger.info('UI', `当前应用模式: ${currentMode}`);
  }

  checkApiMode() {
    this.isApiMode = RecordManager.isApiMode();
    this.checkConnection();
  }

  async checkConnection() {
    if (this.isApiMode) {
      // 检查API连接状态
      Logger.ui('开始检查API连接...');
      try {
        const isConnected = await RecordManager.checkApiConnection();
        this.connectionStatus = isConnected ? '已连接' : '连接失败';
        Logger.ui(`API连接状态: ${this.connectionStatus}`);
      } catch (error) {
        this.connectionStatus = '连接失败';
        Logger.error('UI', 'API连接检查失败:', error);
      }
    } else {
      this.connectionStatus = '本地模式';
    }
  }

  async toggleApiMode() {
    try {
      router.push({
        url: 'pages/ModeSwitchPage'
      });
    } catch (error) {
      Logger.error('UI', 'Failed to navigate to mode switch page:', error);
    }
  }

  async syncData() {
    if (!this.isApiMode) {
      prompt.showToast({
        message: '当前为本地模式，无需同步',
        duration: 2000
      });
      return;
    }

    prompt.showToast({
      message: '开始同步数据...',
      duration: 1000
    });

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
      prompt.showToast({
        message: '加载记录失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 主要内容区域
      if (this.currentTabIndex === 0) {
        this.RecordTabContent()
      } else {
        this.ProfileTabContent()
      }
      
      // 底部Tab栏
      this.BottomTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8E7')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  RecordTabContent() {
    Column() {
      if (this.showWelcome) {
        this.WelcomeAnimation()
      } else {
        this.MainContent()
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  ProfileTabContent() {
    Column() {
      // 顶部用户信息区域
      this.UserInfoSection()
      
      // 功能列表
      this.FunctionListSection()
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 20 })
  }

  @Builder
  UserInfoSection() {
    Column() {
      Row() {
        Text('我的')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8B4513')
        
        Blank()
        
        Text('⚙️')
          .fontSize(24)
      }
      .width('100%')
      .margin({ bottom: 30 })
      
      // 用户状态卡片
      Row() {
        Column() {
          if (UserManager.isLoggedIn()) {
            Text('👤')
              .fontSize(40)
              .margin({ bottom: 8 })
            Text('已登录用户')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#8B4513')
            Text(this.isApiMode ? '云端模式' : '本地模式')
              .fontSize(12)
              .fontColor('#CD853F')
              .margin({ top: 4 })
          } else {
            Text('👤')
              .fontSize(40)
              .margin({ bottom: 8 })
            Text('访客模式')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#8B4513')
            Text('点击登录享受更多功能')
              .fontSize(12)
              .fontColor('#CD853F')
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        if (!UserManager.isLoggedIn()) {
          Button('登录')
            .fontSize(14)
            .height(32)
            .backgroundColor('#FF9500')
            .onClick(() => {
              router.push({ url: 'pages/LoginPage' });
            })
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ bottom: 30 })
    }
    .width('100%')
  }

  // 获取账户管理功能项
  private getAccountItems(): FunctionItem[] {
    return [
      { icon: '👤', title: '个人信息', action: (): void => this.navigateToPersonalInfo() },
      { icon: '🚪', title: '退出登录', action: () => this.logout() },
      { icon: '🗑️', title: '注销账号', action: (): void => this.deleteAccount() }
    ];
  }

  // 获取登录功能项
  private getLoginItems(): FunctionItem[] {
    return [
      { icon: '🔑', title: '注册', action: (): void => this.navigateToRegister() },
      { icon: '🚪', title: '登录', action: (): void => this.navigateToLogin() }
    ];
  }

  // 获取应用信息功能项
  private getAppInfoItems(): FunctionItem[] {
    return [
      { icon: '📄', title: '用户协议', action: (): void => this.showUserAgreement() },
      { icon: '🔒', title: '隐私政策', action: (): void => this.showPrivacyPolicy() },
      { icon: '📝', title: '更新日志', action: (): void => this.showUpdateLog() },
      { icon: '💡', title: '提需求', action: (): void => this.submitFeedback() }
    ];
  }

  @Builder
  FunctionListSection() {
    Column() {
      // 账户管理
      if (UserManager.isLoggedIn()) {
        this.FunctionGroup('账户管理', this.getAccountItems())
      } else {
        this.FunctionGroup('账户', this.getLoginItems())
      }
      
      // 应用信息
      this.FunctionGroup('应用信息', this.getAppInfoItems())
    }
    .width('100%')
  }

  @Builder
  FunctionGroup(title: string, items: FunctionItem[]) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })
      
      Column() {
        ForEach(items, (item: FunctionItem, index: number) => {
          Row() {
            Text(item.icon)
              .fontSize(20)
              .margin({ right: 12 })
            
            Text(item.title)
              .fontSize(16)
              .fontColor('#8B4513')
              .layoutWeight(1)
            
            Text('›')
              .fontSize(20)
              .fontColor('#DEB887')
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .onClick(() => item.action())
          
          if (index < items.length - 1) {
            Divider()
              .color('#F0F0F0')
              .margin({ left: 48 })
          }
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 20 })
    }
    .width('100%')
  }

  @Builder
  BottomTabBar() {
    Row() {
      // 记录Tab
      Column() {
        Text(this.currentTabIndex === 0 ? '📝' : '📝')
          .fontSize(24)
          .fontColor(this.currentTabIndex === 0 ? '#FF9500' : '#8B4513')
        Text('记录')
          .fontSize(12)
          .fontColor(this.currentTabIndex === 0 ? '#FF9500' : '#8B4513')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentTabIndex = 0;
      })
      
      // 我的Tab
      Column() {
        Text(this.currentTabIndex === 1 ? '👤' : '👤')
          .fontSize(24)
          .fontColor(this.currentTabIndex === 1 ? '#FF9500' : '#8B4513')
        Text('我的')
          .fontSize(12)
          .fontColor(this.currentTabIndex === 1 ? '#FF9500' : '#8B4513')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentTabIndex = 1;
      })
    }
    .width('100%')
    .height(80)
    .backgroundColor('#FFFFFF')
    .border({ width: { top: 1 }, color: '#F0F0F0' })
    .padding({ top: 8, bottom: 8 })
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
      
      // API模式状态栏
      // Row() {
      //   Text(this.isApiMode ? '🌐 云端模式' : '📱 本地模式')
      //     .fontSize(12)
      //     .fontColor(this.isApiMode ? '#007AFF' : '#8B4513')
      //
      //   Text('|')
      //     .fontSize(12)
      //     .fontColor('#DEB887')
      //     .margin({ left: 8, right: 8 })
      //
      //   Text(this.connectionStatus)
      //     .fontSize(12)
      //     .fontColor(this.connectionStatus === '已连接' ? '#34C759' :
      //               this.connectionStatus === '连接失败' ? '#FF3B30' : '#8B4513')
      //
      //   Blank()
      //
      //   Button('切换模式')
      //     .fontSize(10)
      //     .height(24)
      //     .backgroundColor(this.isApiMode ? '#FF9500' : '#007AFF')
      //     .onClick(() => {
      //       this.toggleApiMode();
      //     })
      // }
      // .width('100%')
      // .margin({ top: 12 })
    }
    .width('100%')
    .margin({ bottom: 30 })
  }

  @Builder
  QuickActionSection() {
    Column() {
      Text('快捷操作')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })
      
      Row() {
        // 新增记录按钮
        Button() {
          Column() {
            Text('📝')
              .fontSize(32)
            Text('新增记录')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .margin({ top: 8 })
          }
        }
        .width(100)
        .height(100)
        .backgroundColor('#FF9500')
        .borderRadius(16)
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddRecord' });
        })
        
        // 查看历史按钮
        Button() {
          Column() {
            Text('📊')
              .fontSize(32)
            Text('历史记录')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .margin({ top: 8 })
          }
        }
        .width(100)
        .height(100)
        .backgroundColor('#34C759')
        .borderRadius(16)
        .onClick(() => {
          router.pushUrl({ url: 'pages/HistoryList' });
        })

        // 同步按钮（仅在API模式下显示）
        if (this.isApiMode) {
          Button() {
            Column() {
              Text('同步数据')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .margin({ top: 8 })
            }
          }
          .width(100)
          .height(100)
          .backgroundColor('#007AFF')
          .borderRadius(16)
          .onClick(() => {
            this.syncData();
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .margin({ bottom: 30 })
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
        
        if (this.records.length > 5) {
          Text('查看全部')
            .fontSize(16)
            .fontColor('#FF9500')
            .onClick(() => {
              router.pushUrl({ url: 'pages/HistoryList' });
            })
          Text(' ›')
            .fontSize(20)
            .fontColor('#FF9500')
            .onClick(() => {
              router.pushUrl({ url: 'pages/HistoryList' });
            })
        }
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      if (this.records.length === 0) {
        Column() {
          Text('🌟')
            .fontSize(48)
            .margin({ bottom: 16 })
          
          Text('还没有记录哦~')
            .fontSize(16)
            .fontColor('#CD853F')
          
          Text('点击上方按钮开始记录吧！')
            .fontSize(14)
            .fontColor('#DEB887')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .border({ width: 2, color: '#F0E68C', style: BorderStyle.Dashed })
      } else {
        Scroll() {
          Column() {
            ForEach(this.records.slice(0, 5), (record: PoopRecord) => {
              RecordItem({ 
                record: record, 
                asListItem: false, 
                showNotes: false, 
                showDeleteAction: false,
                showShareAction: false
              })
            })
          }
          .width('100%')
        }
        .width('100%')
        .height(300)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
  }

  // 功能方法
  navigateToPersonalInfo() {
    router.pushUrl({ url: 'pages/PersonalInfoPage' });
  }

  async logout(): Promise<void> {
    try {
      await UserManager.logout();
      prompt.showToast({
        message: '已退出登录',
        duration: 2000
      });
      // 刷新页面状态
      await this.checkAppMode();
    } catch (error) {
      Logger.error('UI', 'Logout failed:', error);
      prompt.showToast({
        message: '退出登录失败',
        duration: 2000
      });
    }
  }

  deleteAccount() {
    prompt.showToast({
      message: '注销账号功能开发中...',
      duration: 2000
    });
  }

  navigateToRegister() {
    router.pushUrl({ url: 'pages/LoginPage' });
  }

  navigateToLogin() {
    router.pushUrl({ url: 'pages/LoginPage' });
  }

  showUserAgreement() {
    router.pushUrl({ url: 'pages/UserAgreementPage' });
  }

  showPrivacyPolicy() {
    router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
  }

  showUpdateLog() {
    router.pushUrl({ url: 'pages/UpdateLogPage' });
  }

  submitFeedback() {
    router.pushUrl({ url: 'pages/FeedbackPage' });
  }

  showPersonalInfo() {
    router.pushUrl({ url: 'pages/PersonalInfoPage' });
  }
}