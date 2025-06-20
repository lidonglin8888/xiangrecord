import { RecordManager, PoopRecord, COLOR_OPTIONS, SMELL_OPTIONS, MOISTURE_OPTIONS, SHAPE_OPTIONS, SIZE_OPTIONS, TEXTURE_OPTIONS, MOOD_OPTIONS } from '../model/RecordModel';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { 
  ColorOption,
  SmellOption
} from '../model/RecordModel';
import { Logger } from '../utils/Logger';
import { TopNavigation } from '../components/TopNavigation';

interface StepInfo {
  title: string;
  emoji: string;
  key: string;
}

interface OptionInterface {
  value: string;
  label: string;
  emoji: string;
}

@Entry
@Component
struct AddRecord {
  @State selectedColor: string = '';
  @State selectedSmell: string = '';
  @State selectedMoisture: string = '';
  @State selectedShape: string = '';
  @State selectedSize: string = '';
  @State selectedTexture: string = '';
  @State selectedMood: string = '';
  @State notes: string = '';
  @State currentStep: number = 0;
  @State isSubmitting: boolean = false;

  private steps: StepInfo[] = [
    { title: '颜色', emoji: '🎨', key: 'color' },
    { title: '气味', emoji: '👃', key: 'smell' },
    { title: '干湿度', emoji: '💧', key: 'moisture' },
    { title: '形状', emoji: '🔄', key: 'shape' },
    { title: '大小', emoji: '📏', key: 'size' },
    { title: '质地', emoji: '✋', key: 'texture' },
    { title: '心情', emoji: '😊', key: 'mood' },
    { title: '备注', emoji: '📝', key: 'notes' }
  ];

  build() {
    Column() {
      // 顶部导航
      TopNavigation({ title: '新增记录' })
      
      // 进度指示器
      this.ProgressIndicator()
      
      // 步骤内容
      this.StepContent()
      
      // 底部按钮
      this.BottomButtons()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8E7')
  }



  private scroller: Scroller = new Scroller();

  @Builder
  ProgressIndicator() {
    Column() {
      Scroll(this.scroller) {
        Row() {
          ForEach(this.steps, (step: StepInfo, index: number) => {
            Row() {
              Stack() {
                Circle({ width: 28, height: 28 })
                  .fill(index <= this.currentStep ? '#FF9500' : '#E5E5E5')
                
                Text((index + 1).toString())
                  .fontSize(12)
                  .fontColor(index <= this.currentStep ? '#FFFFFF' : '#999999')
              }
              .id(`step_${index}`)
              
              if (index < this.steps.length - 1) {
                Line()
                  .width(15)
                  .height(2)
                  .backgroundColor(index < this.currentStep ? '#FF9500' : '#E5E5E5')
                  .margin({ left: 3, right: 3 })
              }
            }
            .width(50)
          })
        }
        .justifyContent(FlexAlign.Start)
        .padding({ left: 8, right: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .onAppear(() => {
        this.scrollToCurrentStep();
      })
      
      Text(`${this.currentStep + 1}/${this.steps.length} - ${this.steps[this.currentStep].title}`)
        .fontSize(16)
        .fontColor('#8B4513')
        .margin({ top: 16 })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 20 })
  }

  private scrollToCurrentStep() {
    // 延迟执行以确保UI已更新
    setTimeout(() => {
      // 计算当前步骤应该滚动到的位置，使其居中显示
      const stepWidth = 50; // 每个步骤的宽度（包括间距）
      const lineWidth = 15; // 连接线宽度
      const margin = 6; // 左右边距
      const totalStepWidth = stepWidth + lineWidth + margin;
      const containerWidth = 320; // 容器可视宽度
      
      // 计算目标位置：当前步骤的中心位置 - 容器宽度的一半
      const currentStepCenter = this.currentStep * totalStepWidth + (stepWidth / 2);
      const targetPosition = currentStepCenter - (containerWidth / 2);
      
      // 确保滚动位置不会超出边界
      const totalContentWidth = this.steps.length * totalStepWidth;
      const maxScroll = Math.max(0, totalContentWidth - containerWidth);
      const scrollPosition = Math.max(0, Math.min(targetPosition, maxScroll));
      
      // 使用动画滚动
      this.scroller.scrollTo({
        xOffset: scrollPosition,
        yOffset: 0,
        animation: {
          duration: 300,
          curve: Curve.EaseInOut
        }
      });
    }, 50);
  }

  @Builder
  StepContent() {
    Column() {
      Text(this.steps[this.currentStep].emoji)
        .fontSize(60)
        .margin({ bottom: 20 })
      
      Text(`选择${this.steps[this.currentStep].title}`)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .margin({ bottom: 30 })
      
      if (this.currentStep === 0) {
        this.ColorSelection()
      } else if (this.currentStep === 1) {
        this.SmellSelection()
      } else if (this.currentStep === 2) {
        this.MoistureSelection()
      } else if (this.currentStep === 3) {
        this.ShapeSelection()
      } else if (this.currentStep === 4) {
        this.SizeSelection()
      } else if (this.currentStep === 5) {
        this.TextureSelection()
      } else if (this.currentStep === 6) {
        this.MoodSelection()
      } else if (this.currentStep === 7) {
        this.NotesInput()
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ColorSelection() {
    Grid() {
      ForEach(COLOR_OPTIONS, (option: ColorOption) => {
        GridItem() {
          Column() {
            Circle({ width: 50, height: 50 })
              .fill(option.color)
              .border({
                width: this.selectedColor === option.value ? 3 : 1,
                color: this.selectedColor === option.value ? '#FF9500' : '#E5E5E5'
              })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            
            Text(option.label)
              .fontSize(12)
              .fontColor('#8B4513')
              .margin({ top: 8 })
          }
          .onClick(() => {
            this.selectedColor = option.value;
            // 强制触发UI重新渲染
            this.forceUIUpdate();
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(20)
    .columnsGap(20)
    .width('100%')
  }

  @Builder
  SmellSelection() {
    Grid() {
      ForEach(SMELL_OPTIONS, (option: SmellOption) => {
        GridItem() {
          Column() {
            Text(option.emoji)
              .fontSize(40)
              .padding(16)
              .backgroundColor(this.selectedSmell === option.value ? '#FF9500' : '#FFFFFF')
              .borderRadius(16)
              .border({
                width: this.selectedSmell === option.value ? 2 : 1,
                color: this.selectedSmell === option.value ? '#FF9500' : '#E5E5E5'
              })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            
            Text(option.label)
              .fontSize(12)
              .fontColor('#8B4513')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            this.selectedSmell = option.value;
            // 强制触发UI重新渲染
            this.forceUIUpdate();
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  @Builder
  MoistureSelection() {
    Grid() {
      ForEach(MOISTURE_OPTIONS, (option: OptionInterface) => {
        GridItem() {
          Column() {
            Text(option.emoji)
              .fontSize(40)
              .padding(16)
              .backgroundColor(this.selectedMoisture === option.value ? '#FF9500' : '#FFFFFF')
              .borderRadius(16)
              .border({
                width: this.selectedMoisture === option.value ? 2 : 1,
                color: this.selectedMoisture === option.value ? '#FF9500' : '#E5E5E5'
              })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            
            Text(option.label)
              .fontSize(12)
              .fontColor('#8B4513')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            this.selectedMoisture = option.value;
            // 强制触发UI重新渲染
            this.forceUIUpdate();
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  @Builder
  ShapeSelection() {
    Grid() {
      ForEach(SHAPE_OPTIONS, (option: OptionInterface) => {
        GridItem() {
          Column() {
            Text(option.emoji)
              .fontSize(40)
              .padding(16)
              .backgroundColor(this.selectedShape === option.value ? '#FF9500' : '#FFFFFF')
              .borderRadius(16)
              .border({
                width: this.selectedShape === option.value ? 2 : 1,
                color: this.selectedShape === option.value ? '#FF9500' : '#E5E5E5'
              })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            
            Text(option.label)
              .fontSize(12)
              .fontColor('#8B4513')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            this.selectedShape = option.value;
            // 强制触发UI重新渲染
            this.forceUIUpdate();
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  @Builder
  SizeSelection() {
    Grid() {
      ForEach(SIZE_OPTIONS, (option: OptionInterface) => {
        GridItem() {
          Column() {
            Text(option.emoji)
              .fontSize(40)
              .padding(16)
              .backgroundColor(this.selectedSize === option.value ? '#FF9500' : '#FFFFFF')
              .borderRadius(16)
              .border({
                width: this.selectedSize === option.value ? 2 : 1,
                color: this.selectedSize === option.value ? '#FF9500' : '#E5E5E5'
              })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            
            Text(option.label)
              .fontSize(12)
              .fontColor('#8B4513')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            this.selectedSize = option.value;
            // 强制触发UI重新渲染
            this.forceUIUpdate();
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  @Builder
  TextureSelection() {
    Grid() {
      ForEach(TEXTURE_OPTIONS, (option: OptionInterface) => {
        GridItem() {
          Column() {
            Text(option.emoji)
              .fontSize(40)
              .padding(16)
              .backgroundColor(this.selectedTexture === option.value ? '#FF9500' : '#FFFFFF')
              .borderRadius(16)
              .border({
                width: this.selectedTexture === option.value ? 2 : 1,
                color: this.selectedTexture === option.value ? '#FF9500' : '#E5E5E5'
              })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            
            Text(option.label)
              .fontSize(12)
              .fontColor('#8B4513')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            this.selectedTexture = option.value;
            // 强制触发UI重新渲染
            this.forceUIUpdate();
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  @Builder
  MoodSelection() {
    Grid() {
      ForEach(MOOD_OPTIONS, (option: OptionInterface) => {
        GridItem() {
          Column() {
            Text(option.emoji)
              .fontSize(40)
              .padding(16)
              .backgroundColor(this.selectedMood === option.value ? '#FF9500' : '#FFFFFF')
              .borderRadius(16)
              .border({
                width: this.selectedMood === option.value ? 2 : 1,
                color: this.selectedMood === option.value ? '#FF9500' : '#E5E5E5'
              })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
            
            Text(option.label)
              .fontSize(12)
              .fontColor('#8B4513')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            this.selectedMood = option.value;
            // 强制触发UI重新渲染
            this.forceUIUpdate();
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  @Builder
  OptionGrid(options: Array<OptionInterface>, selectedValue: string, onSelect: (value: string) => void) {
    Grid() {
      ForEach(options, (option: OptionInterface) => {
        GridItem() {
          Column() {
            Text(option.emoji)
              .fontSize(40)
              .padding(16)
              .backgroundColor(selectedValue === option.value ? '#FF9500' : '#FFFFFF')
              .borderRadius(16)
              .border({
                width: selectedValue === option.value ? 2 : 1,
                color: selectedValue === option.value ? '#FF9500' : '#E5E5E5'
              })
              .animation({
                duration: 200,
                curve: Curve.EaseInOut
              })
              .opacity(this.uiUpdateTrigger >= 0 ? 1 : 1) // 引用触发器确保UI更新
            
            Text(option.label)
              .fontSize(12)
              .fontColor('#8B4513')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            // 立即更新状态并强制刷新UI
            onSelect(option.value);
            // 强制触发UI重新渲染
            this.forceUIUpdate();
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  @State private uiUpdateTrigger: number = 0;

  private forceUIUpdate() {
    // 通过更新触发器强制UI重新渲染
    this.uiUpdateTrigger++;
  }

  @Builder
  NotesInput() {
    Column() {
      TextArea({ placeholder: '记录一些特别的感受或备注...' })
        .width('100%')
        .height(120)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .padding(16)
        .fontSize(16)
        .onChange((value: string) => {
          this.notes = value;
        })
      
      Text('可选项，不填写也没关系哦~')
        .fontSize(12)
        .fontColor('#CD853F')
        .margin({ top: 8 })
    }
    .width('100%')
  }

  @Builder
  BottomButtons() {
    Row() {
      if (this.currentStep > 0) {
        Button('上一步')
          .width('45%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#8B4513')
          .onClick(() => {
            this.currentStep--;
            this.scrollToCurrentStep();
          })
      }
      
      Blank()
      
      if (this.currentStep < this.steps.length - 1) {
        Button('下一步')
          .width('45%')
          .height(44)
          .backgroundColor('#FF9500')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.currentStep++;
            this.scrollToCurrentStep();
          })
      } else {
        Button(this.isSubmitting ? '提交中...' : '完成记录')
          .width('45%')
          .height(44)
          .backgroundColor('#FF9500')
          .fontColor('#FFFFFF')
          .enabled(!this.isSubmitting)
          .onClick(() => {
            this.submitRecord();
          })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 20, bottom: 20 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  canProceed(): boolean {
    switch (this.currentStep) {
      case 0: return this.selectedColor !== '';
      case 1: return this.selectedSmell !== '';
      case 2: return this.selectedMoisture !== '';
      case 3: return this.selectedShape !== '';
      case 4: return this.selectedSize !== '';
      case 5: return this.selectedTexture !== '';
      case 6: return this.selectedMood !== '';
      case 7: return true; // 备注是可选的
      default: return false;
    }
  }

  async submitRecord() {
    if (this.isSubmitting) return;
    
    this.isSubmitting = true;
    
    const now = new Date();
    const record: PoopRecord = {
      id: 0,
      date: now,
      time: RecordManager.formatTime(now),
      color: this.selectedColor,
      smell: this.selectedSmell,
      moisture: this.selectedMoisture,
      shape: this.selectedShape,
      size: this.selectedSize,
      texture: this.selectedTexture,
      mood: this.selectedMood,
      notes: this.notes
    };
    Logger.info('API', 'submitRecord 保存成功')
    try {
      await RecordManager.saveRecord(record);
      Logger.info('API', '记录已保存到云端！')
      
      // 安全地显示成功提示
      try {
        promptAction.showToast({
          message: RecordManager.isApiMode() ? '记录已保存到云端！🎉' : '记录保存成功！🎉',
          duration: 2000
        });
      } catch (toastError) {
        Logger.error('UI', `显示成功提示失败: ${toastError}`);
      }
      
      this.isSubmitting = false; // 重置提交状态
      
      setTimeout(() => {
        router.back();
      }, 1000);
    } catch (error) {
      Logger.error('API', `保存记录失败: ${error}`);
      
      // 安全地显示失败提示
      try {
        promptAction.showToast({
          message: '保存失败，请重试',
          duration: 2000
        });
      } catch (toastError) {
        Logger.error('UI', `显示失败提示失败: ${toastError}`);
      }
      
      this.isSubmitting = false;
    }
  }
}