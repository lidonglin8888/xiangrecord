import router from '@ohos.router';
import { TopNavigation } from '../components/TopNavigation';
import promptAction from '@ohos.promptAction';

// 定义反馈类型选项接口
interface FeedbackTypeOption {
  value: string;
  label: string;
}

// 定义设备信息接口
interface DeviceInfo {
  platform: string;
  version: string;
}

// 定义反馈数据接口
interface FeedbackData {
  type: string;
  title: string;
  content: string;
  contact: string;
  timestamp: string;
  deviceInfo: DeviceInfo;
}

@Entry
@Component
struct FeedbackPage {
  @State feedbackType: string = 'suggestion';
  @State title: string = '';
  @State content: string = '';
  @State contact: string = '';
  @State contactInfo: string = '';
  @State isSubmitting: boolean = false;
  
  private feedbackTypes: FeedbackTypeOption[] = [
    { value: 'suggestion', label: '功能建议' },
    { value: 'bug', label: 'Bug反馈' },
    { value: 'improvement', label: '体验优化' },
    { value: 'other', label: '其他问题' }
  ];

  build() {
    Column() {
      // 顶部导航
      TopNavigation({
        title: '提需求',
        showBackButton: true
      })
      
      // 反馈表单
      Scroll() {
        Column() {
          this.FeedbackForm()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8E7')
  }

  @Builder
  FeedbackForm() {
    Column() {
      Text('我们重视您的每一个建议')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .margin({ bottom: 8 })
      
      Text('您的反馈将帮助我们不断改进产品体验')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 24 })
      
      Column() {
        // 反馈类型选择
        this.FormSection('反馈类型', () => {
          this.FeedbackTypeSelector()
        })
        
        // 标题输入
        this.FormSection('问题标题', () => {
          TextInput({ placeholder: '请简要描述您的问题或建议' })
            .width('100%')
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
            .fontSize(14)
            .onChange((value: string) => {
              this.title = value;
            })
        })
        
        // 详细描述
        this.FormSection('详细描述', () => {
          TextArea({ placeholder: '请详细描述您遇到的问题或建议，包括具体的操作步骤、期望的结果等' })
            .width('100%')
            .height(120)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding(12)
            .fontSize(14)
            .onChange((value: string) => {
              this.content = value;
            })
        })
        
        // 联系方式
        this.FormSection('联系方式（可选）', () => {
          // Column() {
          //   TextInput({ placeholder: '请输入手机号或邮箱（可选）' })
          //     .width('100%')
          //     .height(48)
          //     .backgroundColor('#F8F8F8')
          //     .borderRadius(8)
          //     .padding({ left: 16, right: 16 })
          //     .fontSize(16)
          //     .onChange((value: string) => {
          //        this.contactInfo = value;
          //      });
          //
          //    if (this.contactInfo.length > 0) {
          //     Text('我们会通过此联系方式向您反馈处理结果')
          //       .fontSize(12)
          //       .fontColor('#999999')
          //       .margin({ top: 8 });
          //   }
          // }
          // .alignItems(HorizontalAlign.Start)
        })
        
        // 提交按钮
        Button(this.isSubmitting ? '提交中...' : '提交反馈')
          .width('100%')
          .height(48)
          .backgroundColor(this.canSubmit() ? '#8B4513' : '#CCCCCC')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .borderRadius(24)
          .margin({ top: 32 })
          .enabled(this.canSubmit() && !this.isSubmitting)
          .onClick(() => {
            this.submitFeedback();
          })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(20)
    }
    .width('100%')
  }

  @Builder
  FormSection(title: string, content: () => void) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })
      
      Column() {

      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  @Builder
  FeedbackTypeSelector() {
    Row() {
      ForEach(this.feedbackTypes, (type: FeedbackTypeOption) => {
        Text(type.label)
          .fontSize(14)
          .fontColor(this.feedbackType === type.value ? '#FFFFFF' : '#8B4513')
          .backgroundColor(this.feedbackType === type.value ? '#8B4513' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .margin({ right: 12 })
          .onClick(() => {
            this.feedbackType = type.value;
          })
      })
    }
    .width('100%')
  }

  canSubmit(): boolean {
    return this.title.trim().length > 0 && this.content.trim().length > 0;
  }

  async submitFeedback() {
    if (!this.canSubmit()) {
      promptAction.showToast({
        message: '请填写完整的反馈信息',
        duration: 2000
      });
      return;
    }

    this.isSubmitting = true;

    try {
      // 模拟提交反馈
      await this.mockSubmitFeedback();
      
      promptAction.showToast({
        message: '反馈提交成功，感谢您的建议！',
        duration: 2000
      });
      
      // 延迟返回上一页
      setTimeout(() => {
        router.back();
      }, 1500);
      
    } catch (error) {
      promptAction.showToast({
        message: '提交失败，请稍后重试',
        duration: 2000
      });
    } finally {
      this.isSubmitting = false;
    }
  }

  private async mockSubmitFeedback(): Promise<void> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        // 模拟网络请求
        const deviceInfo: DeviceInfo = {
          platform: 'HarmonyOS',
          version: '1.2.0'
        };
        
        const feedback: FeedbackData = {
          type: this.feedbackType,
          title: this.title,
          content: this.content,
          contact: this.contactInfo,
          timestamp: new Date().toISOString(),
          deviceInfo: deviceInfo
        };
        
        console.log('Feedback submitted:', JSON.stringify(feedback));
        
        // 90% 成功率
        if (Math.random() > 0.1) {
          resolve();
        } else {
          reject(new Error('Network error'));
        }
      }, 2000);
    });
  }
}