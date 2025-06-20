import router from '@ohos.router';
import { TopNavigation } from '../components/TopNavigation';

@Entry
@Component
struct PrivacyPolicyPage {
  build() {
    Column() {
      // 顶部导航
      TopNavigation({
        title: '隐私政策',
        showBackButton: true
      })
      
      // 隐私政策内容
      Scroll() {
        Column() {
          this.PolicyContent()
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
  PolicyContent() {
    Column() {
      Text('便便记录小助手隐私政策')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8B4513')
        .margin({ bottom: 20 })
      
      Column() {
        this.SectionTitle('引言')
        this.SectionContent('我们深知个人信息对您的重要性，并会尽全力保护您的个人信息安全可靠。我们致力于维持您对我们的信任，恪守以下原则，保护您的个人信息：权责一致原则、目的明确原则、选择同意原则、最少够用原则、确保安全原则、主体参与原则、公开透明原则等。')
        
        this.SectionTitle('1. 我们收集的信息')
        this.SectionContent('为了向您提供更好的服务，我们可能会收集以下信息：\n\n• 账户信息：用户名、密码、邮箱、手机号码\n• 健康记录：便便记录数据、时间、颜色、形状等\n• 设备信息：设备型号、操作系统版本、设备标识符\n• 使用信息：应用使用频率、功能使用情况\n• 位置信息：仅在您明确授权时收集')
        
        this.SectionTitle('2. 信息使用目的')
        this.SectionContent('我们收集您的个人信息主要用于：\n\n• 提供健康记录服务\n• 数据同步和备份\n• 改善用户体验\n• 统计分析和产品优化\n• 安全防护和风险控制\n• 法律法规要求的其他用途')
        
        this.SectionTitle('3. 信息存储和保护')
        this.SectionContent('• 数据加密：所有敏感数据采用AES-256加密存储\n• 访问控制：严格限制数据访问权限\n• 安全传输：使用HTTPS协议保护数据传输\n• 定期备份：定期备份数据以防丢失\n• 安全审计：定期进行安全评估和漏洞扫描')
        
        this.SectionTitle('4. 信息共享和披露')
        this.SectionContent('我们不会向第三方出售、出租或以其他方式披露您的个人信息，除非：\n\n• 获得您的明确同意\n• 法律法规要求\n• 保护用户或公众的重大利益\n• 与我们的服务提供商共享（仅限于提供服务所需）')
        
        this.SectionTitle('5. 您的权利')
        this.SectionContent('您对自己的个人信息享有以下权利：\n\n• 访问权：查看我们收集的您的个人信息\n• 更正权：更正不准确的个人信息\n• 删除权：要求删除您的个人信息\n• 限制处理权：限制我们处理您的个人信息\n• 数据可携权：获取您的个人信息副本')
        
        this.SectionTitle('6. Cookie和类似技术')
        this.SectionContent('我们可能使用Cookie和类似技术来：\n\n• 记住您的偏好设置\n• 分析应用使用情况\n• 提供个性化服务\n• 改善应用性能\n\n您可以通过设备设置管理Cookie偏好。')
        
        this.SectionTitle('7. 儿童隐私保护')
        this.SectionContent('我们非常重视儿童的隐私保护。如果您未满18周岁，请在监护人指导下使用本应用。我们不会故意收集儿童的个人信息。')
        
        this.SectionTitle('8. 隐私政策更新')
        this.SectionContent('我们可能会不时更新本隐私政策。重大变更将通过应用内通知或其他方式告知您。继续使用本应用即表示您接受更新后的隐私政策。')
        
        this.SectionTitle('9. 联系我们')
        this.SectionContent('如果您对本隐私政策有任何疑问、意见或建议，请通过以下方式联系我们：\n\n• 应用内"提需求"功能\n• 邮箱：privacy@pooprecord.com\n• 地址：[公司地址]')
        
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