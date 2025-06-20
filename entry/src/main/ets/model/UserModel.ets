import { Logger } from '../utils/Logger';
import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';
import ContextManager from '../utils/ContextManager';

// 用户信息接口
export interface User {
  id: string;
  username: string;
  email?: string;
  phone?: string;
  avatar?: string;
  loginType: LoginType;
  createTime?: Date;
  lastLoginTime?: Date;
  huaweiId?: string;
  wechatId?: string;
  createdAt?: Date;
}

// 登录类型枚举
export enum LoginType {
  HUAWEI = 'huawei',
  WECHAT = 'wechat',
  PHONE = 'phone'
}

// 应用模式枚举
export enum AppMode {
  GUEST = 'guest',    // 访客模式
  CLOUD = 'cloud'     // 云端模式
}

// 登录凭证接口
export interface LoginCredentials {
  loginType: LoginType;
  token?: string;
  phone?: string;
  password?: string;
  code?: string; // 验证码
  huaweiId?: string;
  wechatId?: string;
}

// 用户认证管理器
export class UserManager {
  private static readonly USER_KEY = 'current_user';
  private static readonly MODE_KEY = 'app_mode';
  private static readonly TOKEN_KEY = 'auth_token';
  private static readonly REFRESH_TOKEN_KEY = 'refresh_token';
  private static readonly GUEST_DATA_KEY = 'guest_data_synced';
  
  private static currentUser: User | null = null;
  private static currentMode: AppMode = AppMode.GUEST;
  private static authToken: string | null = null;
  private static refreshToken: string | null = null;

  // 初始化用户管理器
  static async initialize(): Promise<void> {
    try {
      const context = getContext();
      const dataPreferences = await preferences.getPreferences(context, 'user_data');
      
      // 加载应用模式，如果标记为空则默认使用本地模式（访客模式）
      const savedMode: preferences.ValueType = await dataPreferences.get(UserManager.MODE_KEY, null);
      if (savedMode === null || savedMode === undefined) {
        // 首次启动或标记为空，默认使用本地模式
        UserManager.currentMode = AppMode.GUEST;
        await UserManager.saveMode(); // 保存默认模式
        Logger.info('USER', 'First launch or empty mode flag, defaulting to local mode (GUEST)');
      } else {
        // 将savedMode转换为字符串进行比较
        const modeString = String(savedMode);
        // 验证保存的模式是否有效
        if (modeString === AppMode.GUEST || modeString === AppMode.CLOUD) {
          UserManager.currentMode = modeString as AppMode;
        } else {
          // 无效模式，默认使用访客模式
          UserManager.currentMode = AppMode.GUEST;
          await UserManager.saveMode();
          Logger.warn('USER', 'Invalid saved mode, defaulting to GUEST mode');
        }
      }
      
      // 加载用户信息
      const savedUser: preferences.ValueType = await dataPreferences.get(UserManager.USER_KEY, null);
      if (savedUser && typeof savedUser === 'string') {
        UserManager.currentUser = JSON.parse(savedUser);
      }
      
      // 加载认证令牌
      const savedToken: preferences.ValueType = await dataPreferences.get(UserManager.TOKEN_KEY, null);
      if (savedToken && typeof savedToken === 'string') {
        UserManager.authToken = savedToken;
      }
      
      // 加载刷新令牌
      const savedRefreshToken: preferences.ValueType = await dataPreferences.get(UserManager.REFRESH_TOKEN_KEY, null);
      if (savedRefreshToken && typeof savedRefreshToken === 'string') {
        UserManager.refreshToken = savedRefreshToken;
      }
      
      Logger.info('USER', `UserManager initialized - mode: ${UserManager.currentMode}, hasUser: ${!!UserManager.currentUser}, hasToken: ${!!UserManager.authToken}, hasRefreshToken: ${!!UserManager.refreshToken}`);
    } catch (error) {
      Logger.error('USER', 'Failed to initialize UserManager:', error);
      // 发生错误时也默认使用本地模式
      UserManager.currentMode = AppMode.GUEST;
    }
  }

  // 获取当前应用模式
  static getCurrentMode(): AppMode {
    return UserManager.currentMode;
  }

  // 是否为访客模式
  static isGuestMode(): boolean {
    return UserManager.currentMode === AppMode.GUEST;
  }

  // 是否为云端模式
  static isCloudMode(): boolean {
    return UserManager.currentMode === AppMode.CLOUD;
  }

  // 获取当前用户
  static getCurrentUser(): User | null {
    return UserManager.currentUser;
  }

  // 获取认证令牌
  static getAuthToken(): string | null {
    return UserManager.authToken;
  }

  // 获取刷新令牌
  static getRefreshToken(): string | null {
    return UserManager.refreshToken;
  }

  // 是否已登录
  static isLoggedIn(): boolean {
    return UserManager.currentUser !== null && UserManager.authToken !== null;
  }

  // 切换到访客模式
  static async switchToGuestMode(): Promise<void> {
    try {
      UserManager.currentMode = AppMode.GUEST;
      await UserManager.saveMode();
      Logger.info('USER', 'Switched to guest mode');
    } catch (error) {
      Logger.error('USER', 'Failed to switch to guest mode:', error);
      throw new Error(`Failed to switch to guest mode: ${error}`);
    }
  }

  // 切换到云端模式（需要登录）
  static async switchToCloudMode(): Promise<void> {
    try {
      if (!UserManager.isLoggedIn()) {
        throw new Error('Must login before switching to cloud mode');
      }
      UserManager.currentMode = AppMode.CLOUD;
      await UserManager.saveMode();
      Logger.info('USER', 'Switched to cloud mode');
    } catch (error) {
      Logger.error('USER', 'Failed to switch to cloud mode:', error);
      throw new Error(`Failed to switch to cloud mode: ${error}`);
    }
  }

  /**
   * 保存用户信息和token
   */
  static async saveUser(user: User, token: string, refreshToken?: string): Promise<void> {
    try {
      UserManager.currentUser = user;
      UserManager.authToken = token;
      if (refreshToken) {
        UserManager.refreshToken = refreshToken;
      }
      
      await UserManager.saveUserData();
      
      Logger.info('USER', `User saved successfully - userId: ${user.id}, loginType: ${user.loginType}`);
    } catch (error) {
      Logger.error('USER', 'Save user failed:', error);
      throw new Error(`Save user failed: ${error}`);
    }
  }

  /**
   * 更新tokens
   */
  static async updateTokens(newToken: string, newRefreshToken?: string): Promise<void> {
    try {
      UserManager.authToken = newToken;
      if (newRefreshToken) {
        UserManager.refreshToken = newRefreshToken;
      }
      
      await UserManager.saveUserData();
      
      Logger.info('USER', 'Tokens updated successfully');
    } catch (error) {
      Logger.error('USER', 'Update tokens failed:', error);
      throw new Error(`Update tokens failed: ${error}`);
    }
  }

  // 用户登录（保留兼容性，建议直接使用AuthService）
  static async login(credentials: LoginCredentials): Promise<User> {
    try {
      // 这里应该使用AuthService进行登录
      const user: User = {
        id: 'user_' + Date.now(),
        username: credentials.phone || credentials.huaweiId || credentials.wechatId || 'Unknown',
        phone: credentials.phone,
        huaweiId: credentials.huaweiId,
        wechatId: credentials.wechatId,
        loginType: credentials.loginType,
        createdAt: new Date()
      };
      
      await UserManager.saveUser(user, 'mock_token_' + Date.now());
      
      Logger.info('USER', `User logged in successfully - userId: ${user.id}, loginType: ${user.loginType}`);
      return user;
    } catch (error) {
      Logger.error('USER', 'Login failed:', error);
      throw new Error(`Login failed: ${error}`);
    }
  }

  // 用户登出
  static async logout(): Promise<void> {
    try {
      UserManager.currentUser = null;
      UserManager.authToken = null;
      UserManager.refreshToken = null;
      UserManager.currentMode = AppMode.GUEST;
      
      await UserManager.clearUserData();
      Logger.info('USER', 'User logged out successfully');
    } catch (error) {
      Logger.error('USER', 'Logout failed:', error);
      throw new Error(`Logout failed: ${error}`);
    }
  }



  // 保存应用模式
  private static async saveMode(): Promise<void> {
    try {
      const context = getContext();
      const dataPreferences = await preferences.getPreferences(context, 'user_data');
      await dataPreferences.put(UserManager.MODE_KEY, UserManager.currentMode);
      await dataPreferences.flush();
    } catch (error) {
      Logger.error('USER', 'Failed to save app mode:', error);
      throw new Error(`Failed to save app mode: ${error}`);
    }
  }

  // 保存用户数据
  private static async saveUserData(): Promise<void> {
    try {
      const context = getContext();
      const dataPreferences = await preferences.getPreferences(context, 'user_data');
      
      if (UserManager.currentUser) {
        await dataPreferences.put(UserManager.USER_KEY, JSON.stringify(UserManager.currentUser));
      }
      
      if (UserManager.authToken) {
        await dataPreferences.put(UserManager.TOKEN_KEY, UserManager.authToken);
      }
      
      if (UserManager.refreshToken) {
        await dataPreferences.put(UserManager.REFRESH_TOKEN_KEY, UserManager.refreshToken);
      }
      
      await dataPreferences.put(UserManager.MODE_KEY, UserManager.currentMode);
      await dataPreferences.flush();
    } catch (error) {
      Logger.error('USER', 'Failed to save user data:', error);
      throw new Error(`Failed to save user data: ${error}`);
    }
  }

  // 清除用户数据
  private static async clearUserData(): Promise<void> {
    try {
      const context = getContext();
      const dataPreferences = await preferences.getPreferences(context, 'user_data');
      
      await dataPreferences.delete(UserManager.USER_KEY);
      await dataPreferences.delete(UserManager.TOKEN_KEY);
      await dataPreferences.put(UserManager.MODE_KEY, AppMode.GUEST);
      await dataPreferences.flush();
    } catch (error) {
      Logger.error('USER', 'Failed to clear user data:', error);
      throw new Error(`Failed to clear user data: ${error}`);
    }
  }

  // 检查访客数据是否已同步
  static async isGuestDataSynced(): Promise<boolean> {
    try {
      const context = getContext();
      const dataPreferences = await preferences.getPreferences(context, 'user_data');
      const synced = await dataPreferences.get(UserManager.GUEST_DATA_KEY, false);
      return synced as boolean;
    } catch (error) {
      Logger.error('USER', 'Failed to check guest data sync status:', error);
      return false;
    }
  }

  // 标记访客数据已同步
  static async markGuestDataSynced(): Promise<void> {
    try {
      const context = getContext();
      const dataPreferences = await preferences.getPreferences(context, 'user_data');
      await dataPreferences.put(UserManager.GUEST_DATA_KEY, true);
      await dataPreferences.flush();
    } catch (error) {
      Logger.error('USER', 'Failed to mark guest data as synced:', error);
      throw new Error(`Failed to mark guest data as synced: ${error}`);
    }
  }

  // 重置访客数据同步状态
  static async resetGuestDataSyncStatus(): Promise<void> {
    try {
      const context = getContext();
      const dataPreferences = await preferences.getPreferences(context, 'user_data');
      await dataPreferences.put(UserManager.GUEST_DATA_KEY, false);
      await dataPreferences.flush();
    } catch (error) {
      Logger.error('USER', 'Failed to reset guest data sync status:', error);
      throw new Error(`Failed to reset guest data sync status: ${error}`);
    }
  }
}

// 获取应用上下文的辅助函数
function getContext(): common.UIAbilityContext {
  try {
    const context = ContextManager.getContext();
    if (!context) {
      throw new Error('Context is null');
    }
    return context;
  } catch (error) {
    Logger.error('USER', 'Failed to get context from ContextManager', error);
    throw new Error('Context is not available. Please ensure the context is properly initialized in EntryAbility.');
  }
}