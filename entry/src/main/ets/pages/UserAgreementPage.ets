import router from '@ohos.router';
import { TopNavigation } from '../components/TopNavigation';

@Entry
@Component
struct UserAgreementPage {
  build() {
    Column() {
      // 顶部导航
      TopNavigation({
        title: '用户协议',
        showBackButton: true
      })
      
      // 协议内容
      Scroll() {
        Column() {
          this.AgreementContent()
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
  AgreementContent() {
    Column() {
      Text('便便记录小助手用户协议')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8B4513')
        .margin({ bottom: 20 })
      
      Column() {
        this.SectionTitle('1. 服务条款')
        this.SectionContent('欢迎使用便便记录小助手！本协议是您与我们之间关于您使用本应用服务的法律协议。请您仔细阅读本协议，您的使用行为将视为对本协议的接受。')
        
        this.SectionTitle('2. 服务内容')
        this.SectionContent('本应用为用户提供便便记录、健康数据统计、云端同步等功能。我们致力于为用户提供准确、可靠的健康记录服务。')
        
        this.SectionTitle('3. 用户义务')
        this.SectionContent('用户应当：\n• 提供真实、准确的个人信息\n• 合法合规地使用本应用\n• 不得利用本应用从事违法活动\n• 保护好自己的账号和密码')
        
        this.SectionTitle('4. 隐私保护')
        this.SectionContent('我们高度重视用户隐私保护，严格按照《隐私政策》处理用户个人信息。用户的健康数据将采用加密存储，未经用户同意不会向第三方披露。')
        
        this.SectionTitle('5. 知识产权')
        this.SectionContent('本应用的所有内容，包括但不限于文字、图片、音频、视频、软件等，均受知识产权法保护。未经许可，用户不得复制、传播或商业使用。')
        
        this.SectionTitle('6. 免责声明')
        this.SectionContent('本应用仅供健康记录参考，不能替代专业医疗建议。如有健康问题，请及时咨询专业医生。我们不对因使用本应用而产生的任何损失承担责任。')
        
        this.SectionTitle('7. 服务变更')
        this.SectionContent('我们保留随时修改或中断服务的权利，无需事先通知。重大变更将通过应用内通知或其他方式告知用户。')
        
        this.SectionTitle('8. 协议修改')
        this.SectionContent('我们有权随时修改本协议。修改后的协议将在应用内公布，继续使用本应用即视为接受修改后的协议。')
        
        this.SectionTitle('9. 争议解决')
        this.SectionContent('因本协议产生的争议，双方应友好协商解决。协商不成的，提交有管辖权的人民法院解决。')
        
        this.SectionTitle('10. 联系我们')
        this.SectionContent('如您对本协议有任何疑问，请通过应用内"提需求"功能联系我们。')
        
        Text('最后更新时间：2024年6月17日')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 30 })
          .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(20)
    }
    .width('100%')
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor('#8B4513')
      .margin({ top: 20, bottom: 8 })
      .alignSelf(ItemAlign.Start)
  }

  @Builder
  SectionContent(content: string) {
    Text(content)
      .fontSize(14)
      .fontColor('#333333')
      .lineHeight(22)
      .margin({ bottom: 12 })
  }
}