import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction, router } from '@kit.ArkUI';

// 用户信息接口
interface UserInfo {
  openId?: string;
  unionId?: string;
  displayName?: string;
  email?: string;
  avatarUrl?: string;
}

interface GeneratedObjectLiteralInterface_1 {
  scopes: string[];
  state: string;
}

@Entry
@Component
struct HuaweiLoginPage {
  @State isLoggedIn: boolean = false;
  @State isLoading: boolean = false;
  @State userInfo: UserInfo = {};
  @State errorMessage: string = '';
  @State private toastMessage: string = '';
  @State @Watch('onToastFlagChange') private showToastFlag: boolean = false;

  build() {
    Column({ space: 20 }) {
      // 顶部导航
      Row() {
        Button() {
          Text('←')
            .fontSize(20)
            .fontColor(Color.Black)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text('华为账号登录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位符保持居中
        Row().width(40).height(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      


      // 主要内容区域
      Column({ space: 30 }) {
        // 华为Logo和标题
        Column({ space: 16 }) {
          Text('华')
            .width(80)
            .height(80)
            .borderRadius(40)
            .backgroundColor('#FF6B35')
            .fontColor(Color.White)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)

          Text('华为账号')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text('一键登录，安全便捷')
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Center)

        // 登录状态显示
        if (this.isLoggedIn) {
          Column({ space: 16 }) {
            Text('登录成功')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#00C853')

            // 用户信息卡片
            Column({ space: 12 }) {
              if (this.userInfo.displayName) {
                Row() {
                  Text('用户名：')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.userInfo.displayName)
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1)
                }
                .width('100%')
              }

              if (this.userInfo.email) {
                Row() {
                  Text('邮箱：')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.userInfo.email)
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1)
                }
                .width('100%')
              }

              if (this.userInfo.openId) {
                Row() {
                  Text('OpenID：')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(this.userInfo.openId.substring(0, 20) + '...')
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1)
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
          }
          .alignItems(HorizontalAlign.Center)
        }

        // 错误信息显示
        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#F44336')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding(12)
            .backgroundColor('#FFEBEE')
            .borderRadius(8)
        }

        // 按钮区域
        Column({ space: 16 }) {
          if (!this.isLoggedIn) {
            // 华为账号登录按钮
            Button() {
              Row({ space: 8 }) {
                if (this.isLoading) {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                    .color(Color.White)
                } else {
                  Text('华')
                    .width(20)
                    .height(20)
                    .fontSize(14)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                }
                Text(this.isLoading ? '登录中...' : '华为账号一键登录')
                  .fontSize(16)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
            .height(48)
            .backgroundColor('#FF6B35')
            .borderRadius(24)
            .enabled(!this.isLoading)
            .onClick(() => {
              this.loginWithHuawei();
            })
          } else {
            // 已登录状态的按钮
            Row({ space: 12 }) {
              Button('获取用户信息')
                .layoutWeight(1)
                .height(44)
                .backgroundColor('#2196F3')
                .borderRadius(22)
                .fontSize(14)
                .enabled(!this.isLoading)
                .onClick(() => {
                  this.getUserInfo();
                })

              Button('退出登录')
                .layoutWeight(1)
                .height(44)
                .backgroundColor('#F44336')
                .borderRadius(22)
                .fontSize(14)
                .enabled(!this.isLoading)
                .onClick(() => {
                  this.logout();
                })
            }
            .width('100%')
          }
        }
      }
      .layoutWeight(1)
      .padding({ left: 24, right: 24, top: 40 })
      .justifyContent(FlexAlign.Center)

      // 底部说明
      Column({ space: 8 }) {
        Text('登录即表示您同意')
          .fontSize(12)
          .fontColor('#999999')
        
        Row({ space: 4 }) {
          Text('《用户协议》')
            .fontSize(12)
            .fontColor('#FF6B35')
            .onClick(() => {
              // 跳转到用户协议页面
              router.pushUrl({ url: 'pages/UserAgreementPage' });
            })
          
          Text('和')
            .fontSize(12)
            .fontColor('#999999')
          
          Text('《隐私政策》')
            .fontSize(12)
            .fontColor('#FF6B35')
            .onClick(() => {
              // 跳转到隐私政策页面
              router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
            })
        }
      }
      .alignItems(HorizontalAlign.Center)
      .padding({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  /**
   * 华为账号登录
   */
  private async loginWithHuawei(): Promise<void> {
    try {
      this.isLoading = true;
      this.errorMessage = '';

      // 模拟华为账号登录（实际项目中需要集成真实的Account Kit）
      setTimeout(() => {
        // 模拟登录成功
        this.isLoggedIn = true;
        
        // 设置用户基本信息
        this.userInfo = {
          openId: 'huawei_' + Date.now().toString(),
          displayName: '华为用户',
          email: ''
        };
        
        this.toastMessage = '华为账号登录成功';
        this.showToastFlag = !this.showToastFlag;
        
        // 自动获取详细用户信息
        this.getUserInfo();
        
        this.isLoading = false;
      }, 1500);
    } catch (error) {
      console.error('华为账号登录异常:', error);
      this.errorMessage = '登录异常，请稍后重试';
      this.toastMessage = '登录异常，请稍后重试';
      this.showToastFlag = !this.showToastFlag;
      this.isLoading = false;
    }
  }

  /**
   * 获取用户详细信息
   */
  private getUserInfo(): void {
    try {
      this.isLoading = true;
      this.errorMessage = '';

      // 模拟获取用户信息（实际项目中需要调用真实API）
      setTimeout(() => {
        const newUserInfo: UserInfo = {
          openId: this.userInfo.openId,
          unionId: this.userInfo.unionId,
          displayName: '华为用户' + Math.floor(Math.random() * 1000),
          email: 'user@huawei.com',
          avatarUrl: this.userInfo.avatarUrl
        };
        this.userInfo = newUserInfo;
        
        this.toastMessage = '用户信息获取成功';
        this.showToastFlag = !this.showToastFlag;
        
        this.isLoading = false;
      }, 1000);
    } catch (error) {
      console.error('获取用户信息失败:', error);
      
      const errorMsg = '获取用户信息失败，请稍后重试';
      this.errorMessage = errorMsg;
      
      this.toastMessage = errorMsg;
      this.showToastFlag = !this.showToastFlag;
      
      this.isLoading = false;
    }
  }

  /**
   * 退出登录
   */
  private logout(): void {
    try {
      this.isLoading = true;
      this.errorMessage = '';

      // 重置本地状态
      this.isLoggedIn = false;
      this.userInfo = {};
      
      this.toastMessage = '已退出华为账号';
      this.showToastFlag = !this.showToastFlag;
    } catch (error) {
      console.error('退出登录失败:', error);
      
      const errorMsg = '退出登录失败，请稍后重试';
      this.errorMessage = errorMsg;
      
      this.toastMessage = errorMsg;
      this.showToastFlag = !this.showToastFlag;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Toast标志变化监听器
   */
  private onToastFlagChange(): void {
    if (this.toastMessage) {
      promptAction.showToast({
        message: this.toastMessage,
        duration: 2000
      });
    }
  }
}