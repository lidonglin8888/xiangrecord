import { RecordManager, PoopRecord, COLOR_OPTIONS, SMELL_OPTIONS, MOISTURE_OPTIONS, SHAPE_OPTIONS, SIZE_OPTIONS, TEXTURE_OPTIONS, MOOD_OPTIONS } from '../model/RecordModel';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TopNavigation } from '../components/TopNavigation';

interface InfoItem {
  label: string;
  value: string;
  icon: string;
}

interface RouterParams {
  record: PoopRecord;
}

@Entry
@Component
struct RecordDetail {
  @State record: PoopRecord | null = null;

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.record) {
      this.record = params.record;
    }
  }

  build() {
    Column() {
      if (this.record) {
        this.RecordContent()
      } else {
        this.ErrorContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8E7')
  }

  @Builder
  RecordContent() {
    Column() {
      // 顶部导航
      TopNavigation({ title: '记录详情' })
      
      // 记录卡片
      this.RecordCard()
      
      // 详细信息
      this.DetailSections()
      
      // 底部操作
      this.BottomActions()
    }
    .width('100%')
    .height('100%')
  }



  @Builder
  RecordCard() {
    Column() {
      // 日期时间
      Text(RecordManager.formatDate(new Date(this.record!.date)))
        .fontSize(16)
        .fontColor('#8B4513')
        .margin({ bottom: 4 })
      
      Text(this.record!.time)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF9500')
        .margin({ bottom: 16 })
      
      // 心情大图标
      Text(this.getMoodEmoji(this.record!.mood))
        .fontSize(80)
        .margin({ bottom: 16 })
      
      Text(this.getMoodLabel(this.record!.mood))
        .fontSize(18)
        .fontColor('#8B4513')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .margin({ left: 16, right: 16, bottom: 20 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  DetailSections() {
    Scroll() {
      Column() {
        // 基本信息
        this.InfoSection('基本特征', [
          { label: '颜色', value: this.getColorInfo(), icon: '🎨' },
          { label: '形状', value: this.getShapeInfo(), icon: '🔄' },
          { label: '大小', value: this.getSizeInfo(), icon: '📏' }
        ] as InfoItem[])
        
        // 质地信息
        this.InfoSection('质地特征', [
          { label: '干湿度', value: this.getMoistureInfo(), icon: '💧' },
          { label: '质地', value: this.getTextureInfo(), icon: '✋' },
          { label: '气味', value: this.getSmellInfo(), icon: '👃' }
        ] as InfoItem[])
        
        // 备注信息
        if (this.record!.notes && this.record!.notes.trim() !== '') {
          this.NotesSection()
        }
      }
    }
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  InfoSection(title: string, items: InfoItem[]) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })
      
      ForEach(items, (item: InfoItem) => {
        Row() {
          Text(item.icon)
            .fontSize(20)
            .width(30)
          
          Text(item.label)
            .fontSize(14)
            .fontColor('#8B4513')
            .width(60)
          
          Text(item.value)
            .fontSize(14)
            .fontColor('#CD853F')
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  NotesSection() {
    Column() {
      Text('备注')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })
      
      Text(this.record!.notes!)
        .fontSize(14)
        .fontColor('#CD853F')
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  BottomActions() {
    Row() {
      Button('删除记录')
        .width(100)
        .height(44)
        .backgroundColor('#FF3B30')
        .fontColor('#FFFFFF')
        .borderRadius(22)
        .onClick(() => {
          this.showDeleteConfirm();
        })
      
      Blank()
      
      Button('分享记录')
        .width(100)
        .height(44)
        .backgroundColor('#34C759')
        .fontColor('#FFFFFF')
        .borderRadius(22)
        .onClick(() => {
          this.shareRecord();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 30 })
  }

  @Builder
  ErrorContent() {
    Column() {
      Text('😵')
        .fontSize(80)
        .margin({ bottom: 20 })
      
      Text('记录不存在')
        .fontSize(18)
        .fontColor('#8B4513')
        .margin({ bottom: 8 })
      
      Text('该记录可能已被删除')
        .fontSize(14)
        .fontColor('#CD853F')
        .margin({ bottom: 30 })
      
      Button('返回首页')
        .backgroundColor('#FF9500')
        .fontColor('#FFFFFF')
        .borderRadius(20)
        .onClick(() => {
          router.clear();
          router.pushUrl({ url: 'pages/Index' });
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 获取各种信息的方法
  getMoodEmoji(mood: string): string {
    const option = MOOD_OPTIONS.find(opt => opt.value === mood);
    return option ? option.emoji : '😊';
  }

  getMoodLabel(mood: string): string {
    const option = MOOD_OPTIONS.find(opt => opt.value === mood);
    return option ? option.label : mood;
  }

  getColorInfo(): string {
    const option = COLOR_OPTIONS.find(opt => opt.value === this.record!.color);
    return option ? option.label : this.record!.color;
  }

  getShapeInfo(): string {
    const option = SHAPE_OPTIONS.find(opt => opt.value === this.record!.shape);
    return option ? option.label : this.record!.shape;
  }

  getSizeInfo(): string {
    const option = SIZE_OPTIONS.find(opt => opt.value === this.record!.size);
    return option ? option.label : this.record!.size;
  }

  getMoistureInfo(): string {
    const option = MOISTURE_OPTIONS.find(opt => opt.value === this.record!.moisture);
    return option ? option.label : this.record!.moisture;
  }

  getTextureInfo(): string {
    const option = TEXTURE_OPTIONS.find(opt => opt.value === this.record!.texture);
    return option ? option.label : this.record!.texture;
  }

  getSmellInfo(): string {
    const option = SMELL_OPTIONS.find(opt => opt.value === this.record!.smell);
    return option ? option.label : this.record!.smell;
  }

  showDeleteConfirm() {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这条记录吗？删除后无法恢复。',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF3B30',
        action: async () => {
          const success = await RecordManager.deleteRecord(this.record!.id);
          if (success) {
            promptAction.showToast({
              message: '删除成功',
              duration: 1500
            });
            router.back();
          } else {
            promptAction.showToast({
              message: '删除失败',
              duration: 1500
            });
          }
        }
      }
    });
  }

  shareRecord() {
    const shareText = `我的便便记录 📊\n` +
      `时间: ${RecordManager.formatDate(new Date(this.record!.date))} ${this.record!.time}\n` +
      `心情: ${this.getMoodLabel(this.record!.mood)}\n` +
      `特征: ${this.getColorInfo()} · ${this.getShapeInfo()} · ${this.getSizeInfo()}\n` +
      `来自便便记录小助手 💩`;
    
    promptAction.showToast({
      message: '分享功能开发中...',
      duration: 2000
    });
  }
}