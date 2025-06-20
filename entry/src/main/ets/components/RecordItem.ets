import { RecordManager, PoopRecord, COLOR_OPTIONS, MOOD_OPTIONS } from '../model/RecordModel';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { common } from '@kit.AbilityKit';
import { ShareUtils } from '../utils/ShareUtils';

@Component
export struct RecordItem {
  @Prop record: PoopRecord;
  @Prop showNotes: boolean = true;
  @Prop showDeleteAction: boolean = false;
  @Prop showShareAction: boolean = false;
  @Prop asListItem: boolean = true; // 新增属性，控制是否作为ListItem
  onDelete?: (record: PoopRecord) => void;
  onRefresh?: () => void;

  build() {
    if (this.asListItem) {
      ListItem() {
        this.RecordContent()
      }
      .swipeAction({
        end: this.buildSwipeActions(),
        edgeEffect: SwipeEdgeEffect.Spring
      })
    } else {
      Column() {
        this.RecordContent()
        if (this.showShareAction) {
          Row() {
            Blank()
            Button('分享记录')
              .fontSize(14)
              .fontColor('#007AFF')
              .backgroundColor('#F0F8FF')
              .borderRadius(8)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .onClick(() => {
                this.shareRecord();
              })
          }
          .width('100%')
          .margin({ top: 12 })
        }
      }
    }
  }

  @Builder
  RecordContent() {
    Row() {
      Column() {
        Text(RecordManager.formatDate(new Date(this.record.date)))
          .fontSize(12)
          .fontColor('#8B4513')
        Text(this.record.time)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#8B4513')
      }
      .alignItems(HorizontalAlign.Start)
      .width(80)
      
      Column() {
        Row() {
          Text('💩')
            .fontSize(20)
          Text(this.getMoodEmoji(this.record.mood))
            .fontSize(16)
            .margin({ left: 8 })
        }
        
        Text(`${this.getColorLabel(this.record.color)} · ${this.getShapeLabel(this.record.shape)}`)
          .fontSize(12)
          .fontColor('#CD853F')
          .margin({ top: 4 })
        
        if (this.showNotes && this.record.notes) {
          Text(this.record.notes.length > 20 ? this.record.notes.substring(0, 20) + '...' : this.record.notes)
            .fontSize(10)
            .fontColor('#DEB887')
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })
      
      Column() {
        Text('>')
          .fontSize(16)
          .fontColor('#DEB887')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      router.push({
        url: 'pages/RecordDetail',
        params: { record: this.record }
      });
    })
  }

  @Builder
  buildSwipeActions() {
    Row() {
      if (this.showShareAction) {
        this.shareButton()
      }
      if (this.showDeleteAction) {
        this.deleteButton()
      }
    }
  }

  @Builder
  shareButton() {
    Column() {
      Text('📤')
        .fontSize(18)
        .fontColor('#FFFFFF')
      Text('分享')
        .fontSize(10)
        .fontColor('#FFFFFF')
        .margin({ top: 2 })
    }
    .width(70)
    .height('50')
    .padding(8)
    .backgroundColor('#007AFF')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.shareRecord();
    })
  }

  @Builder
  deleteButton() {
    Column() {
      Text('🗑️')
        .fontSize(18)
        .fontColor('#FFFFFF')
      Text('删除')
        .fontSize(10)
        .fontColor('#FFFFFF')
        .margin({ top: 2 })
    }
    .width(70)
    .height('50')
    .padding(8)
    .backgroundColor('#FF3B30')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.showDeleteConfirm();
    })
  }

  showDeleteConfirm() {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这条记录吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF3B30',
        action: async () => {
          try {
            const success = await RecordManager.deleteRecord(this.record.id);
            if (success) {
              if (this.onDelete) {
                this.onDelete(this.record);
              }
              if (this.onRefresh) {
                this.onRefresh();
              }
              promptAction.showToast({
                message: '删除成功',
                duration: 1500
              });
            } else {
              promptAction.showToast({
                message: '删除失败，请重试',
                duration: 1500
              });
            }
          } catch (error) {
            console.error('删除记录失败:', error);
            promptAction.showToast({
              message: '删除失败，请重试',
              duration: 1500
            });
          }
        }
      }
    });
  }

  getMoodEmoji(mood: string): string {
    const option = MOOD_OPTIONS.find(opt => opt.value === mood);
    return option ? option.emoji : '😊';
  }

  getColorLabel(color: string): string {
    const option = COLOR_OPTIONS.find(opt => opt.value === color);
    return option ? option.label : color;
  }

  getShapeLabel(shape: string): string {
    const shapeMap = new Map([
      ['sausage', '香肠型'],
      ['lumpy', '块状'],
      ['cracked', '裂纹型'],
      ['soft', '软糊状'],
      ['liquid', '液体状'],
      ['pellets', '颗粒状']
    ]);
    return shapeMap.get(shape) || shape;
  }

  async shareRecord() {
    try {
      // 使用ShareUtils分享记录
      await ShareUtils.shareRecord(this.record);
    } catch (error) {
      console.error('分享失败:', error);
      promptAction.showToast({
        message: '分享失败，请重试',
        duration: 2000
      });
    }
  }
}