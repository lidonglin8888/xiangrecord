import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { UserManager } from '../model/UserModel';
import { Logger } from '../utils/Logger';
import { TopNavigation } from '../components/TopNavigation';

@Entry
@Component
struct PersonalInfoPage {
  @State userInfo: UserInfo = {
    nickname: '',
    email: '',
    phone: '',
    avatar: '👤',
    joinDate: '',
    recordCount: 0
  };
  @State isEditing: boolean = false;
  @State tempNickname: string = '';
  @State tempEmail: string = '';

  aboutToAppear() {
    this.loadUserInfo();
  }

  async loadUserInfo() {
    try {
      // 这里应该从UserManager或API获取用户信息
      // 暂时使用模拟数据
      this.userInfo = {
        nickname: '便便记录者',
        email: 'user@example.com',
        phone: '138****8888',
        avatar: '👤',
        joinDate: '2024-01-01',
        recordCount: 42
      };
      this.tempNickname = this.userInfo.nickname;
      this.tempEmail = this.userInfo.email;
    } catch (error) {
      Logger.error('UI', 'Failed to load user info:', error);
      promptAction.showToast({
        message: '加载用户信息失败',
        duration: 2000
      });
    }
  }

  async saveUserInfo() {
    try {
      // 这里应该调用API保存用户信息
      this.userInfo.nickname = this.tempNickname;
      this.userInfo.email = this.tempEmail;
      this.isEditing = false;
      
      promptAction.showToast({
        message: '保存成功',
        duration: 2000
      });
    } catch (error) {
      Logger.error('UI', 'Failed to save user info:', error);
      promptAction.showToast({
        message: '保存失败',
        duration: 2000
      });
    }
  }

  cancelEdit() {
    this.tempNickname = this.userInfo.nickname;
    this.tempEmail = this.userInfo.email;
    this.isEditing = false;
  }

  build() {
    Column() {
      // 顶部导航
      TopNavigation({
        title: '个人信息',
        showBackButton: true,
        rightIcon: this.isEditing ? '💾' : '✏️',
        rightIconClickable: true,
        onRightIconClick: () => {
          if (this.isEditing) {
            this.saveUserInfo();
          } else {
            this.isEditing = true;
          }
        }
      })
      
      // 主要内容
      Scroll() {
        Column() {
          // 头像区域
          this.AvatarSection()
          
          // 基本信息
          this.BasicInfoSection()
          
          // 统计信息
          this.StatisticsSection()
          
          // 操作按钮
          if (this.isEditing) {
            this.EditActionsSection()
          }
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
  AvatarSection() {
    Column() {
      Text(this.userInfo.avatar)
        .fontSize(80)
        .margin({ bottom: 16 })
      
      if (this.isEditing) {
        Button('更换头像')
          .fontSize(14)
          .height(32)
          .backgroundColor('#FF9500')
          .onClick(() => {
            promptAction.showToast({
              message: '更换头像功能开发中...',
              duration: 2000
            });
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 30 })
  }

  @Builder
  BasicInfoSection() {
    Column() {
      Text('基本信息')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })
      
      Column() {
        // 昵称
        this.InfoItem('昵称', this.userInfo.nickname, this.tempNickname, (value: string) => {
          this.tempNickname = value;
        })
        
        Divider().color('#F0F0F0')
        
        // 邮箱
        this.InfoItem('邮箱', this.userInfo.email, this.tempEmail, (value: string) => {
          this.tempEmail = value;
        })
        
        Divider().color('#F0F0F0')
        
        // 手机号（只读）
        this.InfoItem('手机号', this.userInfo.phone, '', null, true)
        
        Divider().color('#F0F0F0')
        
        // 注册时间（只读）
        this.InfoItem('注册时间', this.userInfo.joinDate, '', null, true)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(16)
      .margin({ bottom: 30 })
    }
    .width('100%')
  }

  @Builder
  InfoItem(label: string, value: string, editValue: string, onChange: ((value: string) => void) | null, readonly: boolean = false) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#8B4513')
        .width(80)
      
      if (this.isEditing && !readonly && onChange) {
        TextInput({ text: editValue })
          .fontSize(16)
          .fontColor('#333333')
          .backgroundColor('#F8F8F8')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .layoutWeight(1)
          .onChange((value: string) => {
            onChange(value);
          })
      } else {
        Text(value)
          .fontSize(16)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  StatisticsSection() {
    Column() {
      Text('使用统计')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#8B4513')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })
      
      Row() {
        Column() {
          Text(this.userInfo.recordCount.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9500')
          Text('总记录数')
            .fontSize(14)
            .fontColor('#8B4513')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        
        Column() {
          Text('7')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#34C759')
          Text('本周记录')
            .fontSize(14)
            .fontColor('#8B4513')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        
        Column() {
          Text('30')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
          Text('连续天数')
            .fontSize(14)
            .fontColor('#8B4513')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height(80)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 30 })
    }
    .width('100%')
  }

  @Builder
  EditActionsSection() {
    Row() {
      Button('取消')
        .fontSize(16)
        .height(44)
        .backgroundColor('#F0F0F0')
        .fontColor('#8B4513')
        .layoutWeight(1)
        .onClick(() => {
          this.cancelEdit();
        })
      
      Button('保存')
        .fontSize(16)
        .height(44)
        .backgroundColor('#FF9500')
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .margin({ left: 16 })
        .onClick(() => {
          this.saveUserInfo();
        })
    }
    .width('100%')
    .margin({ top: 20 })
  }
}

// 用户信息接口
interface UserInfo {
  nickname: string;
  email: string;
  phone: string;
  avatar: string;
  joinDate: string;
  recordCount: number;
}