import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AuthService, RegisterRequest, VerificationCodeRequest } from '../service/AuthService';
import { UserManager } from '../model/UserModel';
import { Logger } from '../utils/Logger';

@Entry
@Component
struct RegisterPage {
  @State phone: string = '';
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State verificationCode: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State countdown: number = 0;
  @State canSendCode: boolean = true;
  @State agreedToTerms: boolean = false;
  @State toastMessage: string = '';
  @State @Watch('onToastFlagChange') showToastFlag: boolean = false;
  private countdownTimer?: number;
  private routerTimer?: number;

  aboutToAppear() {
    Logger.info('UI', 'RegisterPage appeared');
  }

  aboutToDisappear() {
    // 清理定时器，防止内存泄漏和UI上下文错误
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = undefined;
    }
    if (this.routerTimer) {
      clearTimeout(this.routerTimer);
      this.routerTimer = undefined;
    }
    Logger.info('UI', 'RegisterPage disappeared');
  }

  /**
   * 发送验证码
   */
  async sendVerificationCode() {
    if (!this.validatePhone()) {
      return;
    }

    this.isLoading = true;
    try {
      const request: VerificationCodeRequest = {
        phone: this.phone,
        type: 'register'
      };
      
      const response = await AuthService.sendVerificationCode(request);
      
      if (response.code === 200) {
        this.startCountdown();
        this.toastMessage = response.message;
        this.showToastFlag = !this.showToastFlag;
      } else {
        this.toastMessage = response.message;
        this.showToastFlag = !this.showToastFlag;
      }
    } catch (error) {
      Logger.error('REGISTER', 'Send verification code failed:', error);
      this.toastMessage = '发送验证码失败，请稍后重试';
      this.showToastFlag = !this.showToastFlag;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 开始倒计时
   */
  startCountdown() {
    this.countdown = 60;
    this.canSendCode = false;
    
    // 清理之前的定时器
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
    }
    
    this.countdownTimer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        if (this.countdownTimer) {
          clearInterval(this.countdownTimer);
          this.countdownTimer = undefined;
        }
        this.canSendCode = true;
      }
    }, 1000);
  }

  /**
   * 注册
   */
  async register() {
    if (!this.validateForm()) {
      return;
    }

    this.isLoading = true;
    try {
      const request: RegisterRequest = {
        phone: this.phone,
        username: this.username,
        password: this.password,
        verificationCode: this.verificationCode
      };
      
      const response = await AuthService.register(request);
      
      if (response.code === 200) {
        this.toastMessage = response.message;
        this.showToastFlag = !this.showToastFlag;
        
        // 注册成功后返回登录页面
        this.routerTimer = setTimeout(() => {
          try {
            router.back();
          } catch (error) {
            Logger.error('REGISTER', 'Router back failed:', error.message);
          }
        }, 1500);
      } else {
        this.toastMessage = response.message;
        this.showToastFlag = !this.showToastFlag;
      }
    } catch (error) {
      Logger.error('REGISTER', 'Registration failed:', error);
      this.toastMessage = '注册失败，请稍后重试';
      this.showToastFlag = !this.showToastFlag;
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 验证手机号
   */
  validatePhone(): boolean {
    if (!this.phone) {
      this.toastMessage = '请输入手机号';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(this.phone)) {
      this.toastMessage = '请输入正确的手机号';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    return true;
  }

  /**
   * 验证用户名
   */
  validateUsername(): boolean {
    if (!this.username) {
      this.toastMessage = '请输入用户名';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    if (this.username.length < 2 || this.username.length > 20) {
      this.toastMessage = '用户名长度应在2-20个字符之间';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    const usernameRegex = /^[a-zA-Z0-9\u4e00-\u9fa5_-]+$/;
    if (!usernameRegex.test(this.username)) {
      this.toastMessage = '用户名只能包含中文、英文、数字、下划线和横线';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    return true;
  }

  /**
   * 验证密码
   */
  validatePassword(): boolean {
    if (!this.password) {
      this.toastMessage = '请输入密码';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    if (this.password.length < 6 || this.password.length > 20) {
      this.toastMessage = '密码长度应在6-20个字符之间';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    const passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$/;
    if (!passwordRegex.test(this.password)) {
      this.toastMessage = '密码必须包含字母和数字';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    return true;
  }

  /**
   * 验证确认密码
   */
  validateConfirmPassword(): boolean {
    if (!this.confirmPassword) {
      this.toastMessage = '请确认密码';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    if (this.password !== this.confirmPassword) {
      this.toastMessage = '两次输入的密码不一致';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    return true;
  }

  /**
   * 验证验证码
   */
  validateVerificationCode(): boolean {
    if (!this.verificationCode) {
      this.toastMessage = '请输入验证码';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    if (this.verificationCode.length !== 6) {
      this.toastMessage = '请输入6位验证码';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    return true;
  }

  /**
   * 验证表单
   */
  validateForm(): boolean {
    if (!this.validatePhone()) return false;
    if (!this.validateUsername()) return false;
    if (!this.validatePassword()) return false;
    if (!this.validateConfirmPassword()) return false;
    if (!this.validateVerificationCode()) return false;

    if (!this.agreedToTerms) {
      this.toastMessage = '请同意用户协议和隐私政策';
      this.showToastFlag = !this.showToastFlag;
      return false;
    }

    return true;
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
        
        Text('注册账号')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位，保持标题居中
        Text('')
          .width(60)
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
              .width(60)
              .height(60)
              .margin({ bottom: 12 })
            
            Text('创建新账号')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8B4513')
              .margin({ bottom: 6 })
            
            Text('请填写以下信息完成注册')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ bottom: 30 })
          }
          .margin({ top: 20 })

          // 表单内容
          Column() {
            // 手机号输入
            Column() {
              Text('手机号 *')
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
            .margin({ bottom: 16 })

            // 用户名输入
            Column() {
              Text('用户名 *')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              TextInput({ placeholder: '请输入用户名（2-20个字符）' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .border({ width: 1, color: '#E0E0E0' })
                .maxLength(20)
                .onChange((value: string) => {
                  this.username = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 密码输入
            Column() {
              Text('密码 *')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              Row() {
                TextInput({ placeholder: '请输入密码（6-20位，包含字母和数字）' })
                  .layoutWeight(1)
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E0E0E0' })
                  .type(this.showPassword ? InputType.Normal : InputType.Password)
                  .maxLength(20)
                  .onChange((value: string) => {
                    this.password = value;
                  })
                
                /*Button(this.showPassword ? '隐藏' : '显示')
                  .fontSize(14)
                  .fontColor('#666666')
                  .backgroundColor(Color.Transparent)
                  .width(60)
                  .height(48)
                  .onClick(() => {
                    this.showPassword = !this.showPassword;
                  })*/
              }
              .width('100%')
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 确认密码输入
            Column() {
              Text('确认密码 *')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              Row() {
                TextInput({ placeholder: '请再次输入密码' })
                  .layoutWeight(1)
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E0E0E0' })
                  .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
                  .maxLength(20)
                  .onChange((value: string) => {
                    this.confirmPassword = value;
                  })
                
                /*Button(this.showConfirmPassword ? '隐藏' : '显示')
                  .fontSize(14)
                  .fontColor('#666666')
                  .backgroundColor(Color.Transparent)
                  .width(60)
                  .height(48)
                  .onClick(() => {
                    this.showConfirmPassword = !this.showConfirmPassword;
                  })*/
              }
              .width('100%')
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 验证码输入
            Column() {
              Text('验证码 *')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              Row() {
                TextInput({ placeholder: '请输入6位验证码' })
                  .layoutWeight(1)
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E0E0E0' })
                  .type(InputType.Number)
                  .maxLength(6)
                  .onChange((value: string) => {
                    this.verificationCode = value;
                  })
                
                Button(this.canSendCode ? '发送验证码' : `${this.countdown}s`)
                  .fontSize(14)
                  .fontColor(this.canSendCode ? '#8B4513' : '#999999')
                  .backgroundColor(Color.Transparent)
                  .border({ width: 1, color: this.canSendCode ? '#8B4513' : '#E0E0E0', radius: 8 })
                  .width(100)
                  .height(48)
                  .enabled(this.canSendCode && !this.isLoading)
                  .onClick(() => this.sendVerificationCode())
              }
              .width('100%')
            }
            .width('100%')
            .margin({ bottom: 20 })

            // 用户协议
            Row() {
              Checkbox()
                .select(this.agreedToTerms)
                .selectedColor('#8B4513')
                .onChange((value: boolean) => {
                  this.agreedToTerms = value;
                })
              
              Row() {
                Text('我已阅读并同意')
                  .fontSize(12)
                  .fontColor('#666666')
                
                Text('《用户协议》')
                  .fontSize(12)
                  .fontColor('#8B4513')
                  .onClick(() => {
                    // 跳转到用户协议页面
                    router.pushUrl({ url: 'pages/UserAgreementPage' });
                  })
                
                Text('和')
                  .fontSize(12)
                  .fontColor('#666666')
                
                Text('《隐私政策》')
                  .fontSize(12)
                  .fontColor('#8B4513')
                  .onClick(() => {
                    // 跳转到隐私政策页面
                    router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
                  })
              }
            }
            .alignItems(VerticalAlign.Center)
            .margin({ bottom: 24 })

            // 注册按钮
            Button('注册')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#8B4513')
              .borderRadius(24)
              .enabled(!this.isLoading && this.phone.length > 0 && this.username.length > 0 && 
                      this.password.length > 0 && this.confirmPassword.length > 0 && 
                      this.verificationCode.length > 0 && this.agreedToTerms)
              .onClick(() => this.register())
            
            if (this.isLoading) {
              LoadingProgress()
                .width(32)
                .height(32)
                .margin({ top: 20 })
                .color('#8B4513')
            }

            // 登录链接
            Row() {
              Text('已有账号？')
                .fontSize(14)
                .fontColor('#999999')
              
              Text('立即登录')
                .fontSize(14)
                .fontColor('#8B4513')
                .onClick(() => {
                  router.back();
                })
            }
            .margin({ top: 24 })
          }
          .width('100%')
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
}