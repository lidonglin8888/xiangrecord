import { ApiService } from '../service/ApiService';
import { Logger } from '../utils/Logger';
import { UserManager, AppMode } from './UserModel';

// 排泄物记录数据模型
export interface PoopRecord {
  id: number;
  userId?: string; // 用户ID，访客模式下为空
  date: Date;
  time: string;
  color: string; // 颜色
  smell: string; // 气味
  moisture: string; // 干湿度
  shape: string; // 形状
  size: string; // 大小
  texture: string; // 质地
  notes?: string; // 备注
  mood: string; // 心情
}

// 选项类型定义
export interface ColorOption {
  value: string;
  label: string;
  color: string;
}

export interface SmellOption {
  value: string;
  label: string;
  emoji: string;
}

export interface MoistureOption {
  value: string;
  label: string;
  emoji: string;
}

export interface ShapeOption {
  value: string;
  label: string;
  emoji: string;
}

export interface SizeOption {
  value: string;
  label: string;
  emoji: string;
}

export interface TextureOption {
  value: string;
  label: string;
  emoji: string;
}

export interface MoodOption {
  value: string;
  label: string;
  emoji: string;
}

// 颜色选项
export const COLOR_OPTIONS: ColorOption[] = [
  { value: 'brown', label: '棕色🤎', color: '#8B4513' },
  { value: 'yellow', label: '黄色💛', color: '#FFD700' },
  { value: 'green', label: '绿色💚', color: '#32CD32' },
  { value: 'black', label: '黑色🖤', color: '#2F2F2F' },
  { value: 'red', label: '红色❤️', color: '#FF4444' },
  { value: 'white', label: '白色🤍', color: '#F5F5F5' }
];

// 气味选项
export const SMELL_OPTIONS: SmellOption[] = [
  { value: 'normal', label: '正常😊', emoji: '😊' },
  { value: 'mild', label: '轻微😐', emoji: '😐' },
  { value: 'strong', label: '浓烈😷', emoji: '😷' },
  { value: 'sweet', label: '甜味🍯', emoji: '🍯' },
  { value: 'sour', label: '酸味🍋', emoji: '🍋' }
];

// 干湿度选项
export const MOISTURE_OPTIONS: MoistureOption[] = [
  { value: 'dry', label: '干燥🏜️', emoji: '🏜️' },
  { value: 'normal', label: '正常💧', emoji: '💧' },
  { value: 'wet', label: '湿润🌊', emoji: '🌊' },
  { value: 'watery', label: '水样💦', emoji: '💦' }
];

// 形状选项
export const SHAPE_OPTIONS: ShapeOption[] = [
  { value: 'sausage', label: '香肠型🌭', emoji: '🌭' },
  { value: 'lumpy', label: '块状🧱', emoji: '🧱' },
  { value: 'cracked', label: '裂纹型🍪', emoji: '🍪' },
  { value: 'soft', label: '软糊状🍦', emoji: '🍦' },
  { value: 'liquid', label: '液体状🥤', emoji: '🥤' },
  { value: 'pellets', label: '颗粒状🫘', emoji: '🫘' }
];

// 大小选项
export const SIZE_OPTIONS: SizeOption[] = [
  { value: 'small', label: '小🤏', emoji: '🤏' },
  { value: 'medium', label: '中等👌', emoji: '👌' },
  { value: 'large', label: '大👍', emoji: '👍' },
  { value: 'huge', label: '超大🤯', emoji: '🤯' }
];

// 质地选项
export const TEXTURE_OPTIONS: TextureOption[] = [
  { value: 'smooth', label: '光滑✨', emoji: '✨' },
  { value: 'rough', label: '粗糙🪨', emoji: '🪨' },
  { value: 'soft', label: '柔软🧸', emoji: '🧸' },
  { value: 'hard', label: '坚硬💎', emoji: '💎' },
  { value: 'sticky', label: '粘稠🍯', emoji: '🍯' }
];

// 心情选项
export const MOOD_OPTIONS: MoodOption[] = [
  { value: 'happy', label: '开心😄', emoji: '😄' },
  { value: 'normal', label: '正常😐', emoji: '😐' },
  { value: 'tired', label: '疲惫😴', emoji: '😴' },
  { value: 'uncomfortable', label: '不适😣', emoji: '😣' },
  { value: 'relieved', label: '舒畅😌', emoji: '😌' },
  { value: 'worried', label: '担心😰', emoji: '😰' }
];

// 记录管理类
export class RecordManager {
  private static readonly STORAGE_KEY = 'poop_records';
  private static readonly API_MODE_KEY = 'api_mode';
  private static apiMode: boolean = false;

  // 初始化
  static init() {
    this.apiMode = AppStorage.get(this.API_MODE_KEY) as boolean || false;
  }

  // 设置API模式
  static setApiMode(enabled: boolean) {
    this.apiMode = enabled;
    AppStorage.setOrCreate(this.API_MODE_KEY, enabled);
  }

  // 获取API模式状态
  static isApiMode(): boolean {
    return this.apiMode;
  }

  // 检查API连接
  static async checkApiConnection(): Promise<boolean> {
    if (!this.apiMode) return true;
    
    try {
      return await ApiService.checkConnection();
    } catch (error) {
      Logger.error('RecordManager', '检查API连接失败:', error);
      return false;
    }
  }

  // 获取所有记录
  static async getAllRecords(): Promise<PoopRecord[]> {
    if (this.apiMode) {
      try {
        const userMode = UserManager.getCurrentMode();
        if (userMode === AppMode.GUEST) {
          // 访客模式，从本地获取
          return this.getLocalRecords();
        } else {
          // 登录模式，从API获取
          const userId = UserManager.getCurrentUserId();
          if (userId) {
            return await ApiService.getRecords(userId);
          }
        }
      } catch (error) {
        Logger.error('RecordManager', '从API获取记录失败，回退到本地:', error);
        return this.getLocalRecords();
      }
    }
    
    return this.getLocalRecords();
  }

  // 从本地存储获取记录
  private static getLocalRecords(): PoopRecord[] {
    try {
      const recordsStr = AppStorage.get(this.STORAGE_KEY) as string;
      if (recordsStr) {
        const records = JSON.parse(recordsStr) as PoopRecord[];
        return records.map(record => ({
          ...record,
          date: new Date(record.date)
        })).sort((a, b) => b.date.getTime() - a.date.getTime());
      }
    } catch (error) {
      Logger.error('RecordManager', '解析本地记录失败:', error);
    }
    return [];
  }

  // 保存记录到本地
  private static saveLocalRecords(records: PoopRecord[]) {
    try {
      AppStorage.setOrCreate(this.STORAGE_KEY, JSON.stringify(records));
    } catch (error) {
      Logger.error('RecordManager', '保存本地记录失败:', error);
    }
  }

  // 添加新记录
  static async addRecord(record: Omit<PoopRecord, 'id'>): Promise<boolean> {
    try {
      const newRecord: PoopRecord = {
        ...record,
        id: Date.now() // 使用时间戳作为ID
      };

      if (this.apiMode) {
        const userMode = UserManager.getCurrentMode();
        if (userMode !== AppMode.GUEST) {
          // 登录模式，保存到API
          const userId = UserManager.getCurrentUserId();
          if (userId) {
            newRecord.userId = userId;
            const success = await ApiService.addRecord(newRecord);
            if (success) {
              return true;
            }
          }
        }
      }

      // 保存到本地
      const records = this.getLocalRecords();
      records.unshift(newRecord);
      this.saveLocalRecords(records);
      return true;
    } catch (error) {
      Logger.error('RecordManager', '添加记录失败:', error);
      return false;
    }
  }

  // 删除记录
  static async deleteRecord(id: number): Promise<boolean> {
    try {
      if (this.apiMode) {
        const userMode = UserManager.getCurrentMode();
        if (userMode !== AppMode.GUEST) {
          // 登录模式，从API删除
          const success = await ApiService.deleteRecord(id);
          if (success) {
            return true;
          }
        }
      }

      // 从本地删除
      const records = this.getLocalRecords();
      const filteredRecords = records.filter(record => record.id !== id);
      this.saveLocalRecords(filteredRecords);
      return true;
    } catch (error) {
      Logger.error('RecordManager', '删除记录失败:', error);
      return false;
    }
  }

  // 同步数据到服务器
  static async syncToServer(): Promise<boolean> {
    if (!this.apiMode) return true;
    
    try {
      const userMode = UserManager.getCurrentMode();
      if (userMode === AppMode.GUEST) return true;
      
      const userId = UserManager.getCurrentUserId();
      if (!userId) return false;
      
      const localRecords = this.getLocalRecords();
      const userRecords = localRecords.filter(record => !record.userId || record.userId === userId);
      
      for (const record of userRecords) {
        record.userId = userId;
        await ApiService.addRecord(record);
      }
      
      return true;
    } catch (error) {
      Logger.error('RecordManager', '同步到服务器失败:', error);
      return false;
    }
  }

  // 从服务器同步数据
  static async syncFromServer(): Promise<boolean> {
    if (!this.apiMode) return true;
    
    try {
      const userMode = UserManager.getCurrentMode();
      if (userMode === AppMode.GUEST) return true;
      
      const userId = UserManager.getCurrentUserId();
      if (!userId) return false;
      
      const serverRecords = await ApiService.getRecords(userId);
      const localRecords = this.getLocalRecords();
      
      // 合并记录，避免重复
      const mergedRecords = [...serverRecords];
      for (const localRecord of localRecords) {
        if (!serverRecords.find(r => r.id === localRecord.id)) {
          mergedRecords.push(localRecord);
        }
      }
      
      this.saveLocalRecords(mergedRecords);
      return true;
    } catch (error) {
      Logger.error('RecordManager', '从服务器同步失败:', error);
      return false;
    }
  }

  // 获取统计信息
  static async getStatistics(): Promise<{
    total: number;
    today: number;
    thisWeek: number;
    thisMonth: number;
    commonMood: string;
  }> {
    const records = await this.getAllRecords();
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekStart = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const todayRecords = records.filter(r => r.date >= today);
    const weekRecords = records.filter(r => r.date >= weekStart);
    const monthRecords = records.filter(r => r.date >= monthStart);

    // 统计最常见的心情
    const moodCount: { [key: string]: number } = {};
    records.forEach(record => {
      moodCount[record.mood] = (moodCount[record.mood] || 0) + 1;
    });
    
    const commonMood = Object.keys(moodCount).reduce((a, b) => 
      moodCount[a] > moodCount[b] ? a : b, 'normal'
    );

    return {
      total: records.length,
      today: todayRecords.length,
      thisWeek: weekRecords.length,
      thisMonth: monthRecords.length,
      commonMood
    };
  }
}

// 初始化记录管理器
RecordManager.init();