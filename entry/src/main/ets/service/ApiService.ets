import http from '@ohos.net.http';
import { PoopRecord } from '../model/RecordModel';
import { NetworkConfig } from '../config/NetworkConfig';
import { Logger } from '../utils/Logger';
import { UserManager } from '../model/UserModel';
import { HttpInterceptor } from './HttpInterceptor';
import type { RequestConfig } from './HttpInterceptor';

// API响应接口
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
  timestamp: string;
}

// 分页数据接口
interface PageData<T> {
  records: T[];
  total: number;
  page: number;
  size: number;
}

// 分页响应接口
interface PageResponse<T> {
  records: T[];
  total: number;
  page: number;
  size: number;
  success: boolean;
  message: string;
}

// 搜索参数接口
interface SearchParams {
  color?: string;
  mood?: string;
  startTime?: string;
  endTime?: string;
  page?: number;
  size?: number;
}

// 统计参数接口
interface CountParams {
  color?: string;
  mood?: string;
  startTime?: string;
  endTime?: string;
}

// 后端DTO接口（与后端保持一致）
export interface PoopRecordDTO {
  id: number;
  recordTime: string; // ISO格式时间字符串
  color: string;
  smell: string;
  moisture: string;
  shape: string;
  size: string;
  texture: string;
  mood: string;
  notes?: string;
  userId?: string; // 用户ID
}

// HTTP请求选项接口
interface HttpRequestOptions {
  method: http.RequestMethod;
  header: Record<string, string>;
  connectTimeout: number;
  readTimeout: number;
  extraData?: string;
}

// API服务类
interface GeneratedTypeLiteralInterface_1 {
  records: PoopRecord[];
  total: number;
}

interface GeneratedTypeLiteralInterface_2 {
  records: PoopRecord[];
  total: number;
}

interface GeneratedTypeLiteralInterface_3 {
  records: PoopRecord[];
  total: number;
}

interface GeneratedTypeLiteralInterface_4 {
  records: PoopRecord[];
  total: number;
}

export class ApiService {
  // 使用网络配置文件中的设置
  private static readonly BASE_URL = NetworkConfig.getApiBaseUrl();
  private static readonly TIMEOUT = NetworkConfig.CONNECT_TIMEOUT;

  // 创建HTTP请求
  private static createHttpRequest(): http.HttpRequest {
    return http.createHttp();
  }

  // 通用请求方法（使用拦截器）
  private static async request<T>(
    url: string,
    method: http.RequestMethod,
    data?: Object
  ): Promise<ApiResponse<T>> {
    try {
      Logger.api(`发起请求: ${method} ${url}`);
      if (data) {
        Logger.debug('API', '请求数据:', JSON.stringify(data));
      }

      const config: RequestConfig = {
        url,
        method,
        data
      };

      const result = await HttpInterceptor.request<ApiResponse<T>>(config);
      Logger.api('请求成功');
      return result;
    } catch (error) {
      Logger.error('API', `请求失败 - URL: ${url}`);
      Logger.error('API', '错误详情:', error instanceof Error ? error.message : String(error));
      
      // 提供更详细的错误信息和解决建议
      if (error instanceof Error) {
        Logger.error('API', `错误消息: ${error.message}`);
        
        if (error.message.includes('timeout') || error.message.includes('Timeout')) {
          Logger.error('API', '🔥 连接超时，请检查网络连接和服务器状态');
        } else if (error.message.includes('connect') || error.message.includes('Connection')) {
          Logger.error('API', '🔥 无法连接到服务器，请检查服务器地址和端口');
          Logger.error('API', `当前服务器地址: ${ApiService.BASE_URL}`);
        } else if (error.message.includes('network') || error.message.includes('Network')) {
          Logger.error('API', '🔥 网络错误，请检查网络连接');
        } else if (error.message.includes('Token刷新失败') || error.message.includes('重新登录')) {
          Logger.error('API', '🔥 认证失败，需要重新登录');
          // 可以在这里触发登出逻辑
          UserManager.logout().catch((logoutError: Error) => {
            Logger.error('API', '自动登出失败:', logoutError.message);
          });
        } else {
          Logger.error('API', '🔥 未知错误类型，请查看详细错误信息');
        }
      }
      
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      throw new Error(errorMsg);
    }
  }

  // 转换前端模型到后端DTO
  private static toDTO(record: PoopRecord): PoopRecordDTO {
    const timeParts = record.time.split(':');
    const hours = parseInt(timeParts[0]);
    const minutes = parseInt(timeParts[1]);
    const recordDateTime = new Date(record.date.getTime() + hours * 60 * 60 * 1000 + minutes * 60 * 1000);

    return {
      id: record.id,
      recordTime: recordDateTime.toISOString(),
      color: record.color,
      smell: record.smell,
      moisture: record.moisture,
      shape: record.shape,
      size: record.size,
      texture: record.texture,
      mood: record.mood,
      notes: record.notes,
      userId: record.userId // 包含用户ID
    };
  }

  // 转换后端DTO到前端模型
  private static fromDTO(dto: PoopRecordDTO): PoopRecord {
    const recordTime = new Date(dto.recordTime);
    const hours = recordTime.getHours().toString().padStart(2, '0');
    const minutes = recordTime.getMinutes().toString().padStart(2, '0');

    return {
      id: dto.id,
      date: new Date(recordTime.getFullYear(), recordTime.getMonth(), recordTime.getDate()),
      time: `${hours}:${minutes}`,
      color: dto.color,
      smell: dto.smell,
      moisture: dto.moisture,
      shape: dto.shape,
      size: dto.size,
      texture: dto.texture,
      mood: dto.mood,
      notes: dto.notes,
      userId: dto.userId // 包含用户ID
    };
  }

  // 创建记录
  static async createRecord(record: PoopRecord): Promise<PoopRecord> {
    const dto = ApiService.toDTO(record);
    const response = await ApiService.request<PoopRecordDTO>(
      ApiService.BASE_URL,
      http.RequestMethod.POST,
      dto
    );
    return ApiService.fromDTO(response.data);
  }

  // 获取单个记录
  static async getRecord(id: string): Promise<PoopRecord> {
    const response = await ApiService.request<PoopRecordDTO>(
      `${ApiService.BASE_URL}/${id}`,
      http.RequestMethod.GET
    );
    return ApiService.fromDTO(response.data);
  }

  // 更新记录
  static async updateRecord(id: number, record: PoopRecord): Promise<PoopRecord> {
    const dto = ApiService.toDTO(record);
    const response = await ApiService.request<PoopRecordDTO>(
      `${ApiService.BASE_URL}/${id}`,
      http.RequestMethod.PUT,
      dto
    );
    return ApiService.fromDTO(response.data);
  }

  // 删除记录
  static async deleteRecord(id: number): Promise<void> {
    await ApiService.request<void>(
      `${ApiService.BASE_URL}/${id}`,
      http.RequestMethod.DELETE
    );
  }

  // 获取所有记录（分页）
  static async getAllRecords(
    page: number = 1,
    size: number = 10,
    sortBy: string = 'recordTime',
    sortDir: string = 'desc'
  ): Promise<GeneratedTypeLiteralInterface_3> {
    let url = `${ApiService.BASE_URL}?page=${page}&size=${size}&sortBy=${sortBy}&sortDir=${sortDir}`;
    
    // 在云端模式下添加userId参数
    const currentUser = UserManager.getCurrentUser();
    if (currentUser) {
      url += `&userId=${encodeURIComponent(currentUser.id)}`;
    }
    
    const response = await ApiService.request<PageResponse<PoopRecordDTO>>(url, http.RequestMethod.GET);
    
    // 添加空值检查
    if (!response.data || !response.data.records) {
      Logger.error('API', 'API响应数据为空或缺少records字段');
      return {
        records: [],
        total: 0
      };
    }
    
    return {
      records: response.data.records.map((dto: PoopRecordDTO) => ApiService.fromDTO(dto)),
      total: response.data.total || 0
    };
  }

  // 搜索记录
  static async searchRecords(
    color?: string,
    mood?: string,
    startTime?: string,
    endTime?: string,
    page: number = 1,
    size: number = 10
  ): Promise<GeneratedTypeLiteralInterface_4> {
    let url = `${ApiService.BASE_URL}/search?page=${page}&size=${size}`;

    // 在云端模式下添加userId参数
    const currentUser = UserManager.getCurrentUser();
    if (currentUser) {
      url += `&userId=${encodeURIComponent(currentUser.id)}`;
    }

    if (color) {
      url += `&color=${encodeURIComponent(color)}`;
    }
    if (mood) {
      url += `&mood=${encodeURIComponent(mood)}`;
    }
    if (startTime) {
      url += `&startTime=${encodeURIComponent(startTime)}`;
    }
    if (endTime) {
      url += `&endTime=${encodeURIComponent(endTime)}`;
    }

    const response = await ApiService.request<PageResponse<PoopRecordDTO>>(url, http.RequestMethod.GET);

    // 添加空值检查
    if (!response.data || !response.data.records) {
      Logger.error('API', 'API响应数据为空或缺少records字段');
      return {
        records: [],
        total: 0
      };
    }

    return {
      records: response.data.records.map((dto: PoopRecordDTO) => ApiService.fromDTO(dto)),
      total: response.data.total || 0
    };
  }

  // 获取最近记录
  static async getRecentRecords(limit: number = 10): Promise<PoopRecord[]> {
    let url = `${ApiService.BASE_URL}/recent?limit=${limit}`;
    
    // 在云端模式下添加userId参数
    const currentUser = UserManager.getCurrentUser();
    if (currentUser) {
      url += `&userId=${encodeURIComponent(currentUser.id)}`;
    }
    const response = await ApiService.request<PoopRecordDTO[]>(url, http.RequestMethod.GET);
    
    // 添加空值检查
    if (!response.data || !Array.isArray(response.data)) {
      Logger.error('API', 'API响应数据为空或格式错误');
      return [];
    }
    
    return response.data.map((dto: PoopRecordDTO) => ApiService.fromDTO(dto));
  }

  // 获取今日记录
  static async getTodayRecords(): Promise<PoopRecord[]> {
    let url = `${ApiService.BASE_URL}/today`;
    
    // 在云端模式下添加userId参数
    const currentUser = UserManager.getCurrentUser();
    if (currentUser) {
      url += `?userId=${encodeURIComponent(currentUser.id)}`;
    }
    
    const response = await ApiService.request<PoopRecordDTO[]>(
      url,
      http.RequestMethod.GET
    );
    
    // 添加空值检查
    if (!response.data || !Array.isArray(response.data)) {
      Logger.error('API', 'API响应数据为空或格式错误');
      return [];
    }
    
    return response.data.map((dto: PoopRecordDTO) => ApiService.fromDTO(dto));
  }

  // 统计记录数量
  static async countRecords(
    color?: string,
    mood?: string,
    startTime?: string,
    endTime?: string
  ): Promise<number> {
    let url = `${ApiService.BASE_URL}/stats/count`;
    const params: string[] = [];

    if (color) {
      params.push(`color=${encodeURIComponent(color)}`);
    }
    if (mood) {
      params.push(`mood=${encodeURIComponent(mood)}`);
    }
    if (startTime) {
      params.push(`startTime=${encodeURIComponent(startTime)}`);
    }
    if (endTime) {
      params.push(`endTime=${encodeURIComponent(endTime)}`);
    }

    if (params.length > 0) {
      url += '?' + params.join('&');
    }

    const response = await ApiService.request<number>(url, http.RequestMethod.GET);
    return response.data;
  }
}