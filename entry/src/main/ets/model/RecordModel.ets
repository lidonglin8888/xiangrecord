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
  { value: 'small', label: '小🐭', emoji: '🐭' },
  { value: 'medium', label: '中🐰', emoji: '🐰' },
  { value: 'large', label: '大🐻', emoji: '🐻' },
  { value: 'extra_large', label: '超大🦣', emoji: '🦣' }
];

// 质地选项
export const TEXTURE_OPTIONS: TextureOption[] = [
  { value: 'smooth', label: '光滑✨', emoji: '✨' },
  { value: 'rough', label: '粗糙🪨', emoji: '🪨' },
  { value: 'sticky', label: '粘稠🍯', emoji: '🍯' },
  { value: 'fluffy', label: '蓬松☁️', emoji: '☁️' }
];

// 心情选项
export const MOOD_OPTIONS: MoodOption[] = [
  { value: 'happy', label: '开心😄', emoji: '😄' },
  { value: 'relieved', label: '舒畅😌', emoji: '😌' },
  { value: 'normal', label: '一般😐', emoji: '😐' },
  { value: 'uncomfortable', label: '不适😣', emoji: '😣' },
  { value: 'painful', label: '痛苦😖', emoji: '😖' }
];


// 数据存储管理类
export class RecordManager {
  private static readonly GUEST_STORAGE_KEY = 'guest_poop_records';
  private static readonly CLOUD_STORAGE_KEY = 'cloud_poop_records';
  private static readonly USE_API_KEY = 'use_api_mode';
  private static readonly SYNC_STATUS_KEY = 'sync_status';
  
  // 获取当前模式对应的存储键
  private static getStorageKey(): string {
    return UserManager.isGuestMode() ? RecordManager.GUEST_STORAGE_KEY : RecordManager.CLOUD_STORAGE_KEY;
  }

  // 获取是否使用API模式
  static isApiMode(): boolean {
    return AppStorage.get<boolean>(RecordManager.USE_API_KEY) || false;
  }

  // 设置API模式
  static setApiMode(useApi: boolean): void {
    AppStorage.setOrCreate(RecordManager.USE_API_KEY, useApi);
  }

  // 获取本地记录
  static getLocalRecords(): PoopRecord[] {
    try {
      const storageKey = RecordManager.getStorageKey();
      const recordsStr = AppStorage.get<string>(storageKey) || '[]';
      const records = JSON.parse(recordsStr) as PoopRecord[];
      // 转换日期字符串为Date对象
      return records.map(record => {
        const newRecord: PoopRecord = {
          id: record.id,
          date: new Date(record.date),
          time: record.time,
          color: record.color,
          smell: record.smell,
          moisture: record.moisture,
          shape: record.shape,
          size: record.size,
          texture: record.texture,
          notes: record.notes,
          mood: record.mood
        };
        return newRecord;
      });
    } catch (error) {
      console.error('获取本地记录失败:', error);
      return [];
    }
  }

  // 保存本地记录
  static saveLocalRecords(records: PoopRecord[]): boolean {
    try {
      const storageKey = RecordManager.getStorageKey();
      const recordsStr = JSON.stringify(records);
      AppStorage.setOrCreate(storageKey, recordsStr);
      return true;
    } catch (error) {
      console.error('保存本地记录失败:', error);
      return false;
    }
  }

  // 获取访客模式记录（用于数据同步）
  static getGuestRecords(): PoopRecord[] {
    try {
      const recordsStr = AppStorage.get<string>(RecordManager.GUEST_STORAGE_KEY) || '[]';
      const records = JSON.parse(recordsStr) as PoopRecord[];
      return records.map(record => {
        const newRecord: PoopRecord = {
          id: record.id,
          userId: record.userId,
          date: new Date(record.date),
          time: record.time,
          color: record.color,
          smell: record.smell,
          moisture: record.moisture,
          shape: record.shape,
          size: record.size,
          texture: record.texture,
          notes: record.notes,
          mood: record.mood
        };
        return newRecord;
      });
    } catch (error) {
      console.error('获取访客记录失败:', error);
      return [];
    }
  }

  // 清空访客模式记录
  static clearGuestRecords(): boolean {
    try {
      AppStorage.setOrCreate(RecordManager.GUEST_STORAGE_KEY, '[]');
      return true;
    } catch (error) {
      console.error('清空访客记录失败:', error);
      return false;
    }
  }

  // 获取所有记录（支持API和本地模式）
  static async getAllRecords(): Promise<PoopRecord[]> {
    if (RecordManager.isApiMode()) {
      try {
        const result = await ApiService.getAllRecords(1, 100); // 获取前100条记录
        return result.records;
      } catch (error) {
        console.error('API获取记录失败，切换到本地模式:', error);
        return RecordManager.getLocalRecords();
      }
    } else {
      return RecordManager.getLocalRecords();
    }
  }

  // 添加记录（支持API和本地模式）
  static async addRecord(record: PoopRecord): Promise<boolean> {
    // 在云端模式下添加用户ID
    if (UserManager.isCloudMode() && UserManager.getCurrentUser()) {
      record.userId = UserManager.getCurrentUser()!.id;
    }
    
    if (RecordManager.isApiMode()) {
      try {
        await ApiService.createRecord(record);
        // API添加成功后，也添加到本地
        const localRecords = RecordManager.getLocalRecords();
        localRecords.unshift(record);
        RecordManager.saveLocalRecords(localRecords);
        return true;
      } catch (error) {
        console.error('API添加记录失败:', error);
        return false;
      }
    } else {
      const records = RecordManager.getLocalRecords();
      records.unshift(record);
      return RecordManager.saveLocalRecords(records);
    }
  }

  // 保存记录（支持API和本地模式）
  static async saveRecord(record: PoopRecord): Promise<boolean> {
    if (RecordManager.isApiMode()) {
      try {
        await ApiService.createRecord(record);
        // API保存成功后，也保存到本地作为备份
        const localRecords = RecordManager.getLocalRecords();
        localRecords.unshift(record);
        RecordManager.saveLocalRecords(localRecords);
        return true;
      } catch (error) {
        console.error('API保存记录失败，保存到本地:', error);
        // API失败时保存到本地
        const localRecords = RecordManager.getLocalRecords();
        localRecords.unshift(record);
        return RecordManager.saveLocalRecords(localRecords);
      }
    } else {
      const records = RecordManager.getLocalRecords();
      records.unshift(record);
      return RecordManager.saveLocalRecords(records);
    }
  }

  // 删除记录（支持API和本地模式）
  static async deleteRecord(id: number): Promise<boolean> {
    if (RecordManager.isApiMode()) {
      try {
        await ApiService.deleteRecord(id);
        // API删除成功后，也从本地删除
        const localRecords = RecordManager.getLocalRecords();
        const filteredRecords = localRecords.filter(record => record.id !== id);
        RecordManager.saveLocalRecords(filteredRecords);
        return true;
      } catch (error) {
        console.error('API删除记录失败:', error);
        return false;
      }
    } else {
      const records = RecordManager.getLocalRecords();
      const filteredRecords = records.filter(record => record.id !== id);
      return RecordManager.saveLocalRecords(filteredRecords);
    }
  }

  // 更新记录（支持API和本地模式）
  static async updateRecord(id: number, record: PoopRecord): Promise<boolean> {
    if (RecordManager.isApiMode()) {
      try {
        await ApiService.updateRecord(id, record);
        // API更新成功后，也更新本地记录
        const localRecords = RecordManager.getLocalRecords();
        const index = localRecords.findIndex(r => r.id === id);
        if (index !== -1) {
          localRecords[index] = record;
          RecordManager.saveLocalRecords(localRecords);
        }
        return true;
      } catch (error) {
        console.error('API更新记录失败:', error);
        return false;
      }
    } else {
      const records = RecordManager.getLocalRecords();
      const index = records.findIndex(r => r.id === id);
      if (index !== -1) {
        records[index] = record;
        return RecordManager.saveLocalRecords(records);
      }
      return false;
    }
  }

  // 同步本地数据到服务器
  static async syncToServer(): Promise<boolean> {
    try {
      const localRecords = RecordManager.getLocalRecords();
      let successCount = 0;

      for (const record of localRecords) {
        try {
          // 在云端模式下为记录添加用户ID
          if (UserManager.isCloudMode() && UserManager.getCurrentUser()) {
            record.userId = UserManager.getCurrentUser()!.id;
          }
          await ApiService.createRecord(record);
          successCount++;
        } catch (error) {
          console.error(`同步记录失败 ${record.id}:`, error);
        }
      }

      console.log(`同步完成: ${successCount}/${localRecords.length} 条记录`);
      return successCount > 0;
    } catch (error) {
      console.error('同步到服务器失败:', error);
      return false;
    }
  }

  // 同步访客数据到云端
  static async syncGuestDataToCloud(): Promise<boolean> {
    try {
      if (!UserManager.isCloudMode() || !UserManager.getCurrentUser()) {
        throw new Error('Must be in cloud mode with logged in user');
      }

      const guestRecords = RecordManager.getGuestRecords();
      if (guestRecords.length === 0) {
        Logger.info('RECORD', 'No guest data to sync');
        return true;
      }

      let successCount = 0;
      const currentUser = UserManager.getCurrentUser()!;

      for (const record of guestRecords) {
        try {
          // 为访客记录添加用户ID
          const cloudRecord: PoopRecord = {
            id: record.id,
            userId: currentUser.id,
            date: record.date,
            time: record.time,
            color: record.color,
            smell: record.smell,
            moisture: record.moisture,
            shape: record.shape,
            size: record.size,
            texture: record.texture,
            notes: record.notes,
            mood: record.mood
          };
          
          if (RecordManager.isApiMode()) {
            await ApiService.createRecord(cloudRecord);
          }
          
          // 添加到云端本地存储
          const cloudRecords = RecordManager.getLocalRecords();
          cloudRecords.unshift(cloudRecord);
          RecordManager.saveLocalRecords(cloudRecords);
          
          successCount++;
        } catch (error) {
          Logger.error('SYNC', `Failed to sync guest record ${record.id}:`, error);
        }
      }

      Logger.info('RECORD', `Guest data sync completed: ${successCount}/${guestRecords.length} records`);
      
      if (successCount > 0) {
        // 标记访客数据已同步
        await UserManager.markGuestDataSynced();
      }
      
      return successCount > 0;
    } catch (error) {
      Logger.error('SYNC', 'Failed to sync guest data to cloud:', error);
      return false;
    }
  }

  // 从服务器同步数据到本地
  static async syncFromServer(): Promise<boolean> {
    try {
      const result = await ApiService.getAllRecords(1, 1000); // 获取所有记录
      RecordManager.saveLocalRecords(result.records);
      console.log(`从服务器同步了 ${result.records.length} 条记录`);
      return true;
    } catch (error) {
      console.error('从服务器同步失败:', error);
      return false;
    }
  }

  // 生成唯一ID
  static generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }

  // 格式化日期
  static formatDate(date: Date): string {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate())
      .padStart(2, '0')}`;
  }

  // 格式化时间
  static formatTime(date: Date): string {
    return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
  }

  // 检查网络连接状态
  static async checkApiConnection(): Promise<boolean> {
    Logger.network('RECORD', '开始检查API连接...');
    try {
      await ApiService.getAllRecords();
      Logger.network('RECORD', 'API连接检查成功');
      return true;
    } catch (error) {
      Logger.error('RECORD', 'API连接检查失败:', String(error));
      Logger.error('RECORD', '请检查: 1.网络连接 2.服务器状态 3.IP地址配置');
      return false;
    }
  }
}