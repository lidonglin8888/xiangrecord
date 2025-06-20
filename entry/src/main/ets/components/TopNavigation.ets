import router from '@ohos.router';

/**
 * 通用顶部导航组件
 * @param title 页面标题
 * @param showBackButton 是否显示返回按钮，默认为true
 * @param rightIcon 右侧图标，默认为💩
 * @param onBack 自定义返回事件，默认为router.back()
 * @param onRightIconClick 右侧图标点击事件
 * @param rightIconClickable 右侧图标是否可点击，默认为false
 */
@Component
export struct TopNavigation {
  @Prop title: string = '';
  @Prop showBackButton: boolean = true;
  @Prop rightIcon: string = '💩';
  @Prop rightIconClickable: boolean = false;
  private onBack?: () => void;
  private onRightIconClick?: () => void;

  build() {
    Row() {
      if (this.showBackButton) {
        Button('<')
          .backgroundColor(Color.Transparent)
          .fontColor('#8B4513')
          .fontSize(18)
          .onClick(() => {
            if (this.onBack) {
              this.onBack();
            } else {
              router.back();
            }
          })
      }
      
      Blank()
      
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
      
      Blank()
      
      if (this.rightIconClickable) {
        Button(this.rightIcon)
          .backgroundColor(Color.Transparent)
          .fontSize(24)
          .onClick(() => {
            if (this.onRightIconClick) {
              this.onRightIconClick();
            }
          })
      } else {
        Text(this.rightIcon)
          .fontSize(24)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 20, bottom: 10 })
  }
}