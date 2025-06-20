import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { UserManager, LoginType, AppMode } from '../model/UserModel';
import { AuthService, LoginResponse, RegisterResponse } from '../service/AuthService';
import { Logger } from '../utils/Logger';

@Entry
@Component
struct LoginPage {
  @State currentTab: number = 0; // 0: 华为账号, 1: 微信, 2: 手机号
  @State phone: string = '';
  @State password: string = '';
  @State verificationCode: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;
  @State countdown: number = 0;
  @State canSendCode: boolean = true;

  aboutToAppear() {
    Logger.info('UI', 'LoginPage appeared');
  }

  async handleHuaweiLogin() {
    // 跳转到华为账号登录页面
    try {
      router.pushUrl({
        url: 'pages/HuaweiLoginPage'
      });
    } catch (error) {
      Logger.error('LOGIN', 'Navigate to Huawei login page failed:', error);
      promptAction.showToast({
        message: '跳转失败，请稍后重试',
        duration: 2000
      });
    }
  }

  async handleWechatLogin() {
    this.isLoading = true;
    try {
      // 模拟微信授权码获取
      const authCode = 'wechat_auth_' + Date.now();
      
      const response: LoginResponse = await AuthService.loginWithWechat(authCode);
      
      if (response.code === 200 && response.user && response.token) {
        // 保存用户信息和token
        await UserManager.saveUser(response.user, response.token);
        await UserManager.switchToCloudMode();
        
        try {
          this.getUIContext().getPromptAction().showToast({
            message: response.message,
            duration: 2000
          });
        } catch (error) {
          console.error('showToast error:', error);
        }
        
        // 登录成功后跳转到主页面，确保触发模式检查
        router.replaceUrl({
          url: 'pages/MainTabs'
        });
      } else {
        try {
          this.getUIContext().getPromptAction().showToast({
            message: response.message,
            duration: 2000
          });
        } catch (error) {
          console.error('showToast error:', error);
        }
      }
    } catch (error) {
      Logger.error('LOGIN', 'WeChat login failed:', error);
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '微信登录失败，请稍后重试',
          duration: 2000
        });
      } catch (error) {
        console.error('showToast error:', error);
      }
    } finally {
      this.isLoading = false;
    }
  }

  // 手机号密码登录
  async loginWithPhone() {
    if (!this.validatePhoneInput()) {
      return;
    }

    this.isLoading = true;
    try {
      const response: LoginResponse = await AuthService.loginWithPhone(this.phone, this.password);
      
      if (response.code === 200 && response.user && response.token) {
        // 保存用户信息和token
        await UserManager.saveUser(response.user, response.token);
        await UserManager.switchToCloudMode();
        
        try {
          this.getUIContext().getPromptAction().showToast({
            message: response.message,
            duration: 2000
          });
        } catch (error) {
          console.error('showToast error:', error);
        }
        
        // 登录成功后跳转到主页面，确保触发模式检查
        router.replaceUrl({
          url: 'pages/MainTabs'
        });
      } else {
        try {
          this.getUIContext().getPromptAction().showToast({
            message: response.message,
            duration: 2000
          });
        } catch (error) {
          console.error('showToast error:', error);
        }
      }
    } catch (error) {
      Logger.error('LOGIN', 'Phone login failed:', error);
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '登录失败，请稍后重试',
          duration: 2000
        });
      } catch (error) {
        console.error('showToast error:', error);
      }
    } finally {
      this.isLoading = false;
    }
  }

  // 发送验证码
  async sendVerificationCode() {
    if (!this.phone || this.phone.length !== 11) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '请输入正确的手机号',
          duration: 2000
        });
      } catch (error) {
        console.error('showToast error:', error);
      }
      return;
    }

    try {
      // TODO: 调用发送验证码API
      this.startCountdown();
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '验证码已发送',
          duration: 2000
        });
      } catch (error) {
        console.error('showToast error:', error);
      }
    } catch (error) {
      Logger.error('LOGIN', 'Send verification code failed:', error);
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '发送验证码失败',
          duration: 2000
        });
      } catch (error) {
        console.error('showToast error:', error);
      }
    }
  }

  // 开始倒计时
  startCountdown() {
    this.countdown = 60;
    this.canSendCode = false;
    
    const timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(timer);
        this.canSendCode = true;
      }
    }, 1000);
  }

  // 验证手机号输入
  validatePhoneInput(): boolean {
    if (!this.phone) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '请输入手机号',
          duration: 2000
        });
      } catch (error) {
        console.error('showToast error:', error);
      }
      return false;
    }

    if (this.phone.length !== 11) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '请输入正确的手机号',
          duration: 2000
        });
      } catch (error) {
        console.error('showToast error:', error);
      }
      return false;
    }

    if (!this.password) {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: '请输入密码',
          duration: 2000
        });
      } catch (error) {
        console.error('showToast error:', error);
      }
      return false;
    }

    return true;
  }

  // 返回访客模式
  async backToGuest() {
    await UserManager.switchToGuestMode();
    router.back();
  }

  // 切换到本地模式（访客模式）
  async switchToLocalMode() {
    try {
      await UserManager.switchToGuestMode();
      promptAction.showToast({
        message: '已切换到本地模式',
        duration: 2000
      });
      // 返回到主页面
      router.back();
    } catch (error) {
      Logger.error('LOGIN', 'Switch to local mode failed:', error);
      promptAction.showToast({
        message: '切换失败，请稍后重试',
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
          .onClick(() => {
            router.back();
          })
        
        Text('登录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 右上角本地模式按钮
        Button('本地模式')
          .fontSize(14)
          .fontColor('#8B4513')
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: '#8B4513', radius: 12 })
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => this.switchToLocalMode())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)

      Scroll() {
        Column() {
          // Logo和标题
          Column() {
            Image($r('app.media.startIcon'))
              .width(80)
              .height(80)
              .margin({ bottom: 16 })
            
            Text('香香记录')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8B4513')
              .margin({ bottom: 8 })
            
            Text('记录每一次的健康状态')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 40 })
          }
          .margin({ top: 40 })

          // 登录方式选择
          Tabs({ barPosition: BarPosition.Start }) {
            TabContent() {
              this.HuaweiLoginContent()
            }
            .tabBar('华为账号')

            TabContent() {
              this.WechatLoginContent()
            }
            .tabBar('微信登录')

            TabContent() {
              this.PhoneLoginContent()
            }
            .tabBar('手机号登录')
          }
          .width('100%')
          .height(400)
          .barMode(BarMode.Fixed)
          .onChange((index: number) => {
            this.currentTab = index;
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
      }
      .layoutWeight(1)
      .backgroundColor('#F8F8F8')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  // 华为账号登录内容
  @Builder
  HuaweiLoginContent() {
    Column() {
      Text('使用华为账号一键登录')
        .fontSize(16)
        .fontColor('#333333')
        .margin({ top: 40, bottom: 40 })
      
      Button('华为账号一键登录')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF6B35')
        .borderRadius(24)
        .enabled(!this.isLoading)
        .onClick(() => this.handleHuaweiLogin())
      
      if (this.isLoading) {
        LoadingProgress()
          .width(32)
          .height(32)
          .margin({ top: 20 })
          .color('#FF6B35')
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  // 微信登录内容
  @Builder
  WechatLoginContent() {
    Column() {
      Text('使用微信账号登录')
        .fontSize(16)
        .fontColor('#333333')
        .margin({ top: 40, bottom: 40 })
      
      Button('微信登录')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#07C160')
        .borderRadius(24)
        .enabled(!this.isLoading)
        .onClick(() => this.handleWechatLogin())
      
      if (this.isLoading) {
        LoadingProgress()
          .width(32)
          .height(32)
          .margin({ top: 20 })
          .color('#07C160')
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }

  // 手机号登录内容
  @Builder
  PhoneLoginContent() {
    Column() {
      // 手机号输入
      Column() {
        Text('手机号')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        TextInput({ placeholder: '请输入手机号' })
          .width('100%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .border({ width: 1, color: '#E0E0E0' })
          .type(InputType.PhoneNumber)
          .maxLength(11)
          .onChange((value: string) => {
            this.phone = value;
          })
      }
      .width('100%')
      .margin({ top: 20, bottom: 16 })

      // 密码输入
      Column() {
        Text('密码')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })
        
        Row() {
          TextInput({ placeholder: '请输入密码' })
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#E0E0E0' })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .onChange((value: string) => {
              this.password = value;
            })
          
          // Button(this.showPassword ? '隐藏' : '显示')
          //   .fontSize(14)
          //   .fontColor('#666666')
          //   .backgroundColor(Color.Transparent)
          //   .width(60)
          //   .height(48)
          //   .onClick(() => {
          //     this.showPassword = !this.showPassword;
          //   })
        }
        .width('100%')
      }
      .width('100%')
      .margin({ bottom: 24 })

      // 登录按钮
      Button('登录')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#8B4513')
        .borderRadius(24)
        .enabled(!this.isLoading && this.phone.length > 0 && this.password.length > 0)
        .onClick(() => this.loginWithPhone())
      
      if (this.isLoading) {
        LoadingProgress()
          .width(32)
          .height(32)
          .margin({ top: 20 })
          .color('#8B4513')
      }

      // 注册链接
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#999999')
        
        Text('立即注册')
          .fontSize(14)
          .fontColor('#8B4513')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/RegisterPage'
            }).catch((error: Error) => {
              Logger.error('LOGIN', 'Navigate to register page failed:', error.message);
              try {
                this.getUIContext().getPromptAction().showToast({
                  message: '跳转失败，请稍后重试',
                  duration: 2000
                });
              } catch (error) {
                console.error('showToast error:', error);
              }
            });
          })
      }
      .margin({ top: 24 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }
}