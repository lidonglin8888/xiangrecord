import router from '@ohos.router';
import { TopNavigation } from '../components/TopNavigation';

@Entry
@Component
struct UpdateLogPage {
  @State updateLogs: UpdateLog[] = [
    {
      version: 'v1.2.0',
      date: '2024-06-17',
      type: 'major',
      features: [
        '🎉 全新底部Tab栏设计，操作更便捷',
        '👤 新增"我的"页面，个人信息管理更完善',
        '🔐 完善用户登录注册流程',
        '📱 优化界面布局，提升用户体验'
      ],
      fixes: [
        '🐛 修复数据同步偶尔失败的问题',
        '🐛 修复记录详情页面显示异常',
        '🐛 优化内存使用，提升应用稳定性'
      ]
    },
    {
      version: 'v1.1.5',
      date: '2024-06-10',
      type: 'minor',
      features: [
        '📊 新增数据统计图表',
        '🔄 优化云端同步机制',
        '🎨 界面细节优化'
      ],
      fixes: [
        '🐛 修复登录状态异常问题',
        '🐛 修复部分机型适配问题'
      ]
    },
    {
      version: 'v1.1.0',
      date: '2024-06-01',
      type: 'major',
      features: [
        '☁️ 新增云端数据同步功能',
        '🔑 支持华为账号、微信、手机号登录',
        '📱 新增本地模式和云端模式切换',
        '🔒 增强数据安全保护'
      ],
      fixes: [
        '🐛 修复记录时间显示问题',
        '🐛 优化应用启动速度'
      ]
    },
    {
      version: 'v1.0.5',
      date: '2024-05-20',
      type: 'patch',
      features: [
        '📝 优化记录添加流程',
        '🎯 改进用户引导体验'
      ],
      fixes: [
        '🐛 修复历史记录排序问题',
        '🐛 修复部分文字显示异常',
        '🐛 提升应用稳定性'
      ]
    },
    {
      version: 'v1.0.0',
      date: '2024-05-01',
      type: 'major',
      features: [
        '🎉 便便记录小助手正式发布！',
        '📝 支持便便记录添加和编辑',
        '📊 提供历史记录查看',
        '💾 本地数据存储',
        '🎨 精美的界面设计'
      ],
      fixes: []
    }
  ];

  build() {
    Column() {
      // 顶部导航
      TopNavigation({
        title: '更新日志',
        showBackButton: true
      })
      
      // 更新日志内容
      Scroll() {
        Column() {
          this.UpdateLogContent()
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
  UpdateLogContent() {
    Column() {
      Text('版本更新历史')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8B4513')
        .margin({ bottom: 20 })
      
      ForEach(this.updateLogs, (log: UpdateLog, index: number) => {
        this.UpdateLogItem(log, index === 0)
      })
    }
    .width('100%')
  }

  @Builder
  UpdateLogItem(log: UpdateLog, isLatest: boolean) {
    Column() {
      // 版本头部
      Row() {
        Column() {
          Row() {
            Text(log.version)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8B4513')
            
            if (isLatest) {
              Text('最新')
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF9500')
                .borderRadius(10)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .margin({ left: 8 })
            }
            
            Text(this.getVersionTypeText(log.type))
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor(this.getVersionTypeColor(log.type))
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .margin({ left: 8 })
          }
          
          Text(log.date)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 新功能
      if (log.features.length > 0) {
        Column() {
          Text('✨ 新功能')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#34C759')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          ForEach(log.features, (feature: string) => {
            Text(feature)
              .fontSize(14)
              .fontColor('#333333')
              .margin({ bottom: 4, left: 16 })
              .alignSelf(ItemAlign.Start)
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 16 })
      }
      
      // 问题修复
      if (log.fixes.length > 0) {
        Column() {
          Text('🔧 问题修复')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF9500')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          ForEach(log.fixes, (fix: string) => {
            Text(fix)
              .fontSize(14)
              .fontColor('#333333')
              .margin({ bottom: 4, left: 16 })
              .alignSelf(ItemAlign.Start)
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(20)
    .margin({ bottom: 16 })
  }

  getVersionTypeText(type: string): string {
    switch (type) {
      case 'major':
        return '重大更新';
      case 'minor':
        return '功能更新';
      case 'patch':
        return '修复更新';
      default:
        return '更新';
    }
  }

  getVersionTypeColor(type: string): string {
    switch (type) {
      case 'major':
        return '#FF3B30';
      case 'minor':
        return '#007AFF';
      case 'patch':
        return '#34C759';
      default:
        return '#8E8E93';
    }
  }
}

// 更新日志接口
interface UpdateLog {
  version: string;
  date: string;
  type: 'major' | 'minor' | 'patch';
  features: string[];
  fixes: string[];
}