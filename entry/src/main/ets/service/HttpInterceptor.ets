import http from '@ohos.net.http';
import { Logger } from '../utils/Logger';
import { UserManager } from '../model/UserModel';
import { NetworkConfig } from '../config/NetworkConfig';
import { AuthService } from './AuthService';

/**
 * 请求配置接口
 */
export interface RequestConfig {
  url: string;
  method: http.RequestMethod;
  data?: Object;
  headers?: Record<string, string>;
  retryCount?: number;
}

/**
 * 响应接口
 */
export interface HttpResponse {
  code: number;
  message: string;
  data?: object;
}

/**
 * 队列项接口
 */
interface QueueItem {
  resolve: (value: HttpResponse) => void;
  reject: (reason: Error) => void;
  config: RequestConfig;
}

/**
 * HTTP错误接口
 */
interface HttpError extends Error {
  responseCode?: number;
  response?: http.HttpResponse;
}

// Token刷新结果接口
interface RefreshTokenResult {
  success: boolean;
  message?: string;
}

// Token刷新响应数据接口
interface RefreshTokenResponseData {
  token: string;
  refreshToken: string;
}

// Token刷新响应接口
interface RefreshTokenResponse {
  code: number;
  data: RefreshTokenResponseData;
}

// 刷新Token请求体接口
interface RefreshTokenRequest {
  refreshToken: string;
}

// 请求头接口
interface RequestHeaders {
  'Content-Type': string;
  'Accept': string;
}

/**
 * HTTP请求拦截器
 * 处理403错误，自动刷新token并重试请求
 */
export class HttpInterceptor {
  private static readonly MAX_RETRY_COUNT = 1; // 最大重试次数
  private static isRefreshing = false; // 是否正在刷新token
  private static failedQueue: Array<QueueItem> = []; // 失败请求队列

  /**
   * 发起HTTP请求（带拦截器）
   */
  static async request<T>(config: RequestConfig): Promise<T> {
    return new Promise<T>((resolve: (value: T) => void, reject: (reason: Error) => void) => {
      HttpInterceptor.executeRequest<T>(config)
        .then(resolve)
        .catch((error: Error) => {
          // 检查是否是403错误
          if (HttpInterceptor.is403Error(error)) {
            HttpInterceptor.handle403Error(config, resolve, reject);
          } else {
            reject(error);
          }
        });
    });
  }

  /**
   * 执行HTTP请求
   */
  private static async executeRequest<T>(config: RequestConfig): Promise<T> {
    const httpRequest = http.createHttp();
    
    try {
      Logger.api(`发起请求: ${config.method} ${config.url}`);
      
      // 构建请求头
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      
      // 合并自定义请求头
      if (config.headers) {
        const keys = Object.keys(config.headers);
        for (let i = 0; i < keys.length; i++) {
          const key = keys[i];
          headers[key] = config.headers[key];
        }
      }
      
      // 添加认证token
      const authToken = UserManager.getAuthToken();
      if (authToken) {
        headers['Authorization'] = `Bearer ${authToken}`;
      }
      
      const options: http.HttpRequestOptions = {
        method: config.method,
        header: headers,
        connectTimeout: NetworkConfig.CONNECT_TIMEOUT,
        readTimeout: NetworkConfig.READ_TIMEOUT,
        expectDataType: http.HttpDataType.STRING,
        usingCache: false,
        priority: 1,
        usingProtocol: http.HttpProtocol.HTTP1_1
      };
      
      // 添加请求数据
      if (config.data) {
        options.extraData = typeof config.data === 'string' ? config.data : JSON.stringify(config.data);
      }
      
      const response = await httpRequest.request(config.url, options);
      
      Logger.api(`响应状态: ${response.responseCode}`);
      
      if (response.responseCode >= 200 && response.responseCode < 300) {
        let result: T;
        if (typeof response.result === 'string') {
          try {
            result = JSON.parse(response.result) as T;
          } catch {
            result = response.result as T;
          }
        } else {
          result = response.result as T;
        }
        return result;
      } else if (response.responseCode === 403) {
        // 抛出403错误，由上层处理
        const error = new Error(`HTTP 403: ${response.result}`) as HttpError;
        error.responseCode = 403;
        error.response = response;
        throw error;
      } else {
        const errorMessage = `HTTP ${response.responseCode}: ${response.result}`;
        Logger.error('HttpInterceptor', errorMessage);
        throw new Error(errorMessage);
      }
    } catch (error) {
      Logger.error('HttpInterceptor', '请求失败:', error);
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error('Unknown error occurred');
      }
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 检查是否是403错误
   */
  private static is403Error(error: Error): boolean {
    // 检查是否为403错误
    const httpError = error as HttpError;
    if (httpError.responseCode === 403) {
      return true;
    }
    // 检查错误消息中是否包含403
    return Boolean(error.message && error.message.includes('403'));
  }

  /**
   * 处理403错误
   */
  private static handle403Error<T>(
    config: RequestConfig,
    resolve: (value: T) => void,
    reject: (reason: Error) => void
  ): void {
    // 检查重试次数
    const retryCount = config.retryCount || 0;
    if (retryCount >= HttpInterceptor.MAX_RETRY_COUNT) {
      Logger.error('HttpInterceptor', '达到最大重试次数，请求失败');
      reject(new Error('Token刷新失败，请重新登录'));
      return;
    }

    // 如果正在刷新token，将请求加入队列
    if (HttpInterceptor.isRefreshing) {
      const queueItem: QueueItem = {
        resolve: resolve as (value: HttpResponse) => void,
        reject: reject,
        config: config
      };
      HttpInterceptor.failedQueue.push(queueItem);
      return;
    }

    // 开始刷新token
    HttpInterceptor.isRefreshing = true;
    HttpInterceptor.refreshTokenAndRetry(config, resolve, reject);
  }

  /**
   * 刷新token并重试请求
   */
  private static async refreshTokenAndRetry<T>(
    config: RequestConfig,
    resolve: (value: T) => void,
    reject: (reason: Error) => void
  ): Promise<void> {
    try {
      Logger.info('HttpInterceptor', '开始刷新token...');
      
      // 调用刷新token接口
      const refreshResult = await HttpInterceptor.refreshToken();
      
      if (refreshResult.success) {
        Logger.info('HttpInterceptor', 'Token刷新成功，重试原请求');
        
        // 更新配置中的重试次数
        const newConfig: RequestConfig = {
          url: config.url,
          method: config.method,
          data: config.data,
          headers: config.headers,
          retryCount: (config.retryCount || 0) + 1
        };
        
        // 重试原请求
        try {
          const result = await HttpInterceptor.executeRequest<T>(newConfig);
          resolve(result);
          
          // 处理队列中的请求
          HttpInterceptor.processFailedQueue(true);
        } catch (retryError) {
          Logger.error('HttpInterceptor', '重试请求失败:', retryError);
          const errorToReject = retryError instanceof Error ? retryError : new Error('Unknown error occurred');
          reject(errorToReject);
          HttpInterceptor.processFailedQueue(false, errorToReject);
        }
      } else {
        Logger.error('HttpInterceptor', 'Token刷新失败');
        reject(new Error('Token刷新失败，请重新登录'));
        HttpInterceptor.processFailedQueue(false, new Error('Token刷新失败'));
      }
    } catch (error) {
      Logger.error('HttpInterceptor', 'Token刷新异常:', error);
      const errorToReject = error instanceof Error ? error : new Error('Unknown error occurred');
      reject(errorToReject);
      HttpInterceptor.processFailedQueue(false, errorToReject);
    } finally {
      HttpInterceptor.isRefreshing = false;
    }
  }

  /**
   * 刷新token
   */
  private static async refreshToken(): Promise<RefreshTokenResult> {
    try {
      // 获取当前的refresh token
      const refreshToken = UserManager.getRefreshToken();
      if (!refreshToken) {
        return { success: false, message: '没有refresh token' };
      }

      // 调用后端刷新token接口
      const refreshUrl = `${NetworkConfig.getApiBaseUrl().replace('/api/records', '/api/auth/refresh')}`;
      const httpRequest = http.createHttp();
      
      try {
        const headers: RequestHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        };
        
        const requestBody: RefreshTokenRequest = { refreshToken };
        
        const options: http.HttpRequestOptions = {
          method: http.RequestMethod.POST,
          header: headers,
          extraData: JSON.stringify(requestBody),
          connectTimeout: NetworkConfig.CONNECT_TIMEOUT,
          readTimeout: NetworkConfig.READ_TIMEOUT
        };
        
        const response = await httpRequest.request(refreshUrl, options);

        if (response.responseCode === 200) {
          const result = JSON.parse(response.result as string) as RefreshTokenResponse;
          if (result.code === 200 && result.data) {
            // 更新token
            await UserManager.updateTokens(result.data.token, result.data.refreshToken);
            const successResult: RefreshTokenResult = { success: true };
            return successResult;
          }
        }
        
        const failResult: RefreshTokenResult = { success: false, message: '刷新token失败' };
        return failResult;
      } finally {
        httpRequest.destroy();
      }
    } catch (error) {
      Logger.error('HttpInterceptor', '刷新token异常:', error);
      const errorResult: RefreshTokenResult = { success: false, message: String(error) };
      return errorResult;
    }
  }

  /**
   * 处理失败队列中的请求
   */
  private static processFailedQueue(success: boolean, error?: Error): void {
    const queue: Array<QueueItem> = [];
    // 清空队列并复制到临时数组
    while (HttpInterceptor.failedQueue.length > 0) {
      const item = HttpInterceptor.failedQueue.shift();
      if (item) {
        queue.push(item);
      }
    }
    
    for (let i = 0; i < queue.length; i++) {
      const item = queue[i];
      if (success) {
        // 重试请求
        const newConfig: RequestConfig = {
          url: item.config.url,
          method: item.config.method,
          data: item.config.data,
          headers: item.config.headers,
          retryCount: (item.config.retryCount || 0) + 1
        };
        
        HttpInterceptor.executeRequest<HttpResponse>(newConfig)
          .then(item.resolve)
          .catch(item.reject);
      } else {
        item.reject(error || new Error('Token刷新失败'));
      }
    }
  }

  /**
   * 清空失败队列（用于登出时）
   */
  static clearFailedQueue(): void {
    while (HttpInterceptor.failedQueue.length > 0) {
      const item = HttpInterceptor.failedQueue.shift();
      if (item) {
        item.reject(new Error('用户已登出'));
      }
    }
    HttpInterceptor.isRefreshing = false;
  }
}