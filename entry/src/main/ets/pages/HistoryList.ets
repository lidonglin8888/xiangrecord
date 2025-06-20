import { RecordManager, PoopRecord, COLOR_OPTIONS, MOOD_OPTIONS } from '../model/RecordModel';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TopNavigation } from '../components/TopNavigation';
import { RecordItem } from '../components/RecordItem';

class MoodCountMap {
  private data: Map<string, number> = new Map();
  
  get(key: string): number {
    return this.data.get(key) || 0;
  }
  
  set(key: string, value: number): void {
    this.data.set(key, value);
  }
  
  entries(): IterableIterator<[string, number]> {
    return this.data.entries();
  }
}

class ShapeMapClass {
  private data: Map<string, string> = new Map([
    ['sausage', '香肠型'],
    ['lumpy', '块状'],
    ['cracked', '裂纹型'],
    ['soft', '软糊状'],
    ['liquid', '液体状'],
    ['pellets', '颗粒状']
  ]);
  
  get(key: string): string {
    return this.data.get(key) || key;
  }
}

@Entry
@Component
struct HistoryList {
  @State records: PoopRecord[] = [];
  @State filteredRecords: PoopRecord[] = [];
  @State searchText: string = '';
  @State selectedFilter: string = 'all'; // all, today, week, month
  @State showFilterDialog: boolean = false;
  @State isLoading: boolean = false;
  @State isApiMode: boolean = false;

  aboutToAppear() {
    this.checkApiMode();
    this.loadRecords();
  }

  checkApiMode() {
    this.isApiMode = RecordManager.isApiMode();
  }

  async loadRecords() {
    this.isLoading = true;
    try {
      this.records = await RecordManager.getAllRecords();
      this.applyFilter();
    } catch (error) {
      console.error('加载记录失败:', error);
      promptAction.showToast({
        message: '加载记录失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  applyFilter() {
    let filtered = [...this.records];
    
    // 时间筛选
    if (this.selectedFilter !== 'all') {
      const now = new Date();
      const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      
      filtered = filtered.filter(record => {
        const recordDate = new Date(record.date);
        
        switch (this.selectedFilter) {
          case 'today':
            return recordDate >= today;
          case 'week':
            const weekAgo = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
            return recordDate >= weekAgo;
          case 'month':
            const monthAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);
            return recordDate >= monthAgo;
          default:
            return true;
        }
      });
    }
    
    // 搜索筛选
    if (this.searchText.trim() !== '') {
      const searchLower = this.searchText.toLowerCase();
      filtered = filtered.filter(record => 
        record.color.toLowerCase().includes(searchLower) ||
        record.mood.toLowerCase().includes(searchLower) ||
        record.shape.toLowerCase().includes(searchLower) ||
        (record.notes && record.notes.toLowerCase().includes(searchLower))
      );
    }
    
    this.filteredRecords = filtered;
  }

  build() {
    Column() {
      // 顶部导航
      this.TopNavigation()
      
      // 搜索和筛选
      this.SearchAndFilter()
      
      // 统计信息
      this.StatisticsSection()
      
      // 记录列表
      this.RecordsList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8E7')
  }

  @Builder
  TopNavigation() {
    Column() {
      TopNavigation({ 
        title: '历史记录',
        rightIcon: '🔄',
        rightIconClickable: true,
        onRightIconClick: () => {
          this.loadRecords();
        }
      })
      
      // API模式状态栏
      Row() {
        Text(this.isApiMode ? '🌐 云端模式' : '📱 本地模式')
          .fontSize(12)
          .fontColor(this.isApiMode ? '#007AFF' : '#8B4513')
        
        Blank()
        
        if (this.isLoading) {
          Text('加载中...')
            .fontSize(12)
            .fontColor('#8B4513')
        } else {
          Text(`共 ${this.records.length} 条记录`)
            .fontSize(12)
            .fontColor('#8B4513')
        }
      }
      .width('100%')
      .margin({ top: 8 })
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
  }

  @Builder
  SearchAndFilter() {
    Column() {
      // 搜索框
      // Row() {
      //   TextInput({ placeholder: '搜索记录...' })
      //     .layoutWeight(1)
      //     .height(40)
      //     .backgroundColor('#FFFFFF')
      //     .borderRadius(20)
      //     .padding({ left: 16, right: 16 })
      //     .onChange((value: string) => {
      //       this.searchText = value;
      //       this.applyFilter();
      //     })
      //
      //   Button('筛选')
      //     .width(60)
      //     .height(40)
      //     .backgroundColor('#FF9500')
      //     .fontColor('#FFFFFF')
      //     .borderRadius(20)
      //     .margin({ left: 8 })
      //     .onClick(() => {
      //       this.showFilterDialog = true;
      //     })
      // }
      // .width('100%')
      
      // 筛选标签
      if (this.selectedFilter !== 'all') {
        Row() {
          Text(this.getFilterLabel())
            .fontSize(12)
            .fontColor('#FF9500')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#FFF0E6')
            .borderRadius(12)
          
          Text('×')
            .fontSize(14)
            .fontColor('#FF9500')
            .margin({ left: 4 })
            .onClick(() => {
              this.selectedFilter = 'all';
              this.applyFilter();
            })
        }
        .margin({ top: 8 })
        .alignSelf(ItemAlign.Start)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  StatisticsSection() {
    Row() {
      Column() {
        Text(this.filteredRecords.length.toString())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF9500')
        Text('总记录')
          .fontSize(12)
          .fontColor('#8B4513')
      }
      .layoutWeight(1)
      
      Column() {
        Text(this.getTodayCount().toString())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#34C759')
        Text('今日记录')
          .fontSize(12)
          .fontColor('#8B4513')
      }
      .layoutWeight(1)
      
      Column() {
        Text(this.getMostFrequentMood())
          .fontSize(24)
        Text('常见心情')
          .fontSize(12)
          .fontColor('#8B4513')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  RecordsList() {
    if (this.filteredRecords.length === 0) {
      Column() {
        Text('🔍')
          .fontSize(48)
          .margin({ bottom: 16 })
        
        Text(this.searchText ? '没有找到匹配的记录' : '还没有记录哦~')
          .fontSize(16)
          .fontColor('#CD853F')
        
        if (!this.searchText) {
          Button('去添加第一条记录')
            .backgroundColor('#FF9500')
            .fontColor('#FFFFFF')
            .borderRadius(20)
            .margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddRecord' });
            })
        }
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      List() {
        ForEach(this.filteredRecords, (record: PoopRecord) => {
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
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  RecordItem(record: PoopRecord) {
    Row() {
      Column() {
        Text(RecordManager.formatDate(new Date(record.date)))
          .fontSize(12)
          .fontColor('#8B4513')
        Text(record.time)
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
          Text(this.getMoodEmoji(record.mood))
            .fontSize(16)
            .margin({ left: 8 })
        }
        
        Text(`${this.getColorLabel(record.color)} · ${this.getShapeLabel(record.shape)}`)
          .fontSize(12)
          .fontColor('#CD853F')
          .margin({ top: 4 })
        
        if (record.notes) {
          Text(record.notes.length > 20 ? record.notes.substring(0, 20) + '...' : record.notes)
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
        
        Button('删除')
          .fontSize(10)
          .width(40)
          .height(24)
          .backgroundColor('#FF3B30')
          .fontColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 8 })
          .onClick(() => {
            this.showDeleteConfirm(record);
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 8 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/RecordDetail',
        params: { record: record }
      });
    })
  }

  getFilterLabel(): string {
    switch (this.selectedFilter) {
      case 'today': return '今天';
      case 'week': return '最近一周';
      case 'month': return '最近一月';
      default: return '全部';
    }
  }

  getTodayCount(): number {
    const today = new Date();
    const todayStr = RecordManager.formatDate(today);
    return this.records.filter(record => 
      RecordManager.formatDate(new Date(record.date)) === todayStr
    ).length;
  }

  getMostFrequentMood(): string {
    if (this.records.length === 0) return '😊';
    
    const moodCount = new MoodCountMap();
    this.records.forEach(record => {
      const currentCount = moodCount.get(record.mood);
      moodCount.set(record.mood, currentCount + 1);
    });
    
    let maxCount = 0;
    let mostFrequent = 'happy';
    for (const entry of moodCount.entries()) {
      const mood = entry[0];
      const count = entry[1];
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = mood;
      }
    }
    
    return this.getMoodEmoji(mostFrequent);
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
    // 简化显示，只返回中文部分
    const shapeMap = new ShapeMapClass();
    return shapeMap.get(shape);
  }

  showDeleteConfirm(record: PoopRecord) {
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
            const success = await RecordManager.deleteRecord(record.id);
            if (success) {
              this.loadRecords();
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
}