import { BusinessError } from '@ohos.base';
import { User, LoginType } from '../model/UserModel';
import { Logger } from '../utils/Logger';
import router from '@ohos.router';
import http from '@ohos.net.http';
import { NetworkConfig } from '../config/NetworkConfig';

/**
 * 登录请求参数
 */
export interface LoginRequest {
  loginType: LoginType;
  phone?: string;
  password?: string;
  huaweiAuthCode?: string;
  wechatAuthCode?: string;
}

/**
 * 登录响应
 */
export interface LoginResponse {
  code: number;
  message: string;
  user?: User;
  token?: string;
}

/**
 * 注册请求参数
 */
export interface RegisterRequest {
  phone: string;
  password: string;
  username: string;
  verificationCode: string;
}

/**
 * 注册响应
 */
export interface RegisterResponse {
  code: number;
  message: string;
  user?: User;
}

/**
 * 验证码请求参数
 */
export interface VerificationCodeRequest {
  phone: string;
  type: 'register' | 'login' | 'reset';
}

/**
 * 验证码响应
 */
export interface VerificationCodeResponse {
  code: number;
  message: string;
}

/**
 * 验证结果接口
 */
interface ValidationResult {
  isValid: boolean;
  message: string;
}

/**
 * API响应数据接口
 */
interface ApiResponseData {
  userId: string;
  username: string;
  avatar?: string;
  token: string;
  createdAt: string;
  huaweiId?: string;
  wechatId?: string;
  codeId?: string;
  expiresIn?: number;
}

/**
 * API响应接口
 */
interface ApiResponse {
  code: number;
  message?: string;
  data?: ApiResponseData;
  timestamp?: string;
}

/**
 * 手机登录参数接口
 */
interface PhoneLoginParams {
  phone: string;
  password: string;
  loginType: string;
}

/**
 * 华为登录参数接口
 */
interface HuaweiLoginParams {
  authCode: string;
}

/**
 * 微信登录参数接口
 */
interface WechatLoginParams {
  authCode: string;
}

/**
 * Token验证参数接口
 */
interface TokenParams {
  token: string;
}

/**
 * Logger数据接口
 */
interface LoggerData {
  phone?: string;
  username?: string;
  type?: string;
}

/**
 * 认证服务类
 */
interface GeneratedTypeLiteralInterface_1 {
  code: number;
  message: string;
  data?: Record<string, Object>;
}

interface UserInfo {
  id?: string;
  username?: string;
}

export class AuthService {
  private static readonly BASE_URL = `http://${NetworkConfig.DEV_SERVER_IP}:${NetworkConfig.DEV_SERVER_PORT}`;
  private static readonly TIMEOUT = 10000;

  /**
   * 手机号密码登录
   */
  static async loginWithPhone(phone: string, password: string): Promise<LoginResponse> {
    try {
      Logger.info('AuthService', 'Attempting phone login', { phone } as LoggerData);
      const loginType: string = "phone"
      // 模拟API调用
      const response: ApiResponse = await AuthService.apiCall('/auth/login/phone', {
        phone,
        password,
        loginType
      } as PhoneLoginParams);

      if (response.code === 200 && response.data) {
        const user: User = {
          id: response.data.userId,
          username: response.data.username,
          phone: phone,
          loginType: LoginType.PHONE,
          avatar: response.data.avatar,
          createdAt: new Date(response.data.createdAt)
        };

        return {
          code: 200,
          message: response.message || '登录成功',
          user,
          token: response.data.token
        };
      } else {
        return {
          code: response.code || 500,
          message: response.message || '登录失败'
        };
      }
    } catch (error) {
      Logger.error('Phone login failed', error);
      const generalErrorResponse: LoginResponse = {
        code: 500,
        message: '网络错误，请稍后重试'
      };
      return generalErrorResponse;
    }
  }

  /**
   * 华为账号登录
   */
  static async loginWithHuawei(authCode: string): Promise<LoginResponse> {
    try {
      Logger.info('AuthService', 'Attempting Huawei login');

      // 模拟华为账号登录
      const response: ApiResponse = await AuthService.apiCall('/auth/login/huawei', {
        authCode
      } as HuaweiLoginParams);

      if (response.code === 200 && response.data) {
        const user: User = {
          id: response.data.userId,
          username: response.data.username,
          huaweiId: response.data.huaweiId,
          loginType: LoginType.HUAWEI,
          avatar: response.data.avatar,
          createdAt: new Date(response.data.createdAt)
        };

        return {
          code: 200,
          message: response.message || '登录成功',
          user,
          token: response.data.token
        };
      } else {
        return {
          code: response.code || 500,
          message: response.message || '华为账号登录失败'
        };
      }
    } catch (error) {
      Logger.error('Huawei login failed', error);
      return {
        code: 500,
        message: '华为账号登录失败，请稍后重试'
      };
    }
  }

  /**
   * 微信登录
   */
  static async loginWithWechat(authCode: string): Promise<LoginResponse> {
    try {
      Logger.info('', 'Attempting WeChat login');

      // 模拟微信登录
      const response: ApiResponse = await AuthService.apiCall('/auth/login/wechat', {
        authCode
      } as WechatLoginParams);

      if (response.code === 200 && response.data) {
        const user: User = {
          id: response.data.userId,
          username: response.data.username,
          wechatId: response.data.wechatId,
          loginType: LoginType.WECHAT,
          avatar: response.data.avatar,
          createdAt: new Date(response.data.createdAt)
        };

        return {
          code: 200,
          message: response.message || '登录成功',
          user,
          token: response.data.token
        };
      } else {
        return {
          code: response.code || 500,
          message: response.message || '微信登录失败'
        };
      }
    } catch (error) {
      Logger.error('WeChat login failed', error);
      return {
        code: 500,
        message: '微信登录失败，请稍后重试'
      };
    }
  }

  /**
   * 手机号注册
   */
  static async register(request: RegisterRequest): Promise<RegisterResponse> {
    Logger.info('AUTH', 'Register request:', request);

    // 前端验证
    const validation = AuthService.validateRegisterRequest(request);
    if (!validation.isValid) {
      const failureResponse: RegisterResponse = {
        code: 400,
        message: validation.message
      };
      return failureResponse;
    }

    try {
      const response: ApiResponse = await AuthService.apiCall('/auth/register', request);

      if (response.code === 200 && response.data) {
        const user: User = {
          id: response.data.userId,
          username: request.username,
          phone: request.phone,
          loginType: LoginType.PHONE,
          createdAt: new Date()
        };

        const successResponse: RegisterResponse = {
          code: 200,
          message: response.message || '注册成功',
          user: user
        };
        return successResponse;
      } else {
        const failureResponse: RegisterResponse = {
          code: response.code || 500,
          message: response.message || '注册失败'
        };
        return failureResponse;
      }
    } catch (error) {
      Logger.error('Registration failed', error);
      const errorResponse: RegisterResponse = {
        code: 500,
        message: '网络错误，请稍后重试'
      };
      return errorResponse;
    }
  }

  /**
   * 验证注册请求
   */
  private static validateRegisterRequest(request: RegisterRequest): ValidationResult {
    // 验证手机号
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!request.phone || !phoneRegex.test(request.phone)) {
      const result: ValidationResult = { isValid: false, message: '请输入正确的手机号' };
      return result;
    }

    // 验证用户名
    if (!request.username || request.username.length < 2 || request.username.length > 20) {
      const result: ValidationResult = { isValid: false, message: '用户名长度应在2-20个字符之间' };
      return result;
    }

    const usernameRegex = /^[a-zA-Z0-9\u4e00-\u9fa5_-]+$/;
    if (!usernameRegex.test(request.username)) {
      const result: ValidationResult = { isValid: false, message: '用户名只能包含中文、英文、数字、下划线和横线' };
      return result;
    }

    // 验证密码
    if (!request.password || request.password.length < 6 || request.password.length > 20) {
      const result: ValidationResult = { isValid: false, message: '密码长度应在6-20个字符之间' };
      return result;
    }

    const passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,}$/;
    if (!passwordRegex.test(request.password)) {
      const result: ValidationResult = { isValid: false, message: '密码必须包含字母和数字' };
      return result;
    }

    // 验证验证码
    if (!request.verificationCode || request.verificationCode.length !== 6) {
      const result: ValidationResult = { isValid: false, message: '请输入6位验证码' };
      return result;
    }

    const result: ValidationResult = { isValid: true, message: '' };
    return result;
  }

  /**
   * 发送验证码
   */
  static async sendVerificationCode(request: VerificationCodeRequest): Promise<VerificationCodeResponse> {
    Logger.info('AUTH', 'Send verification code request:', request);

    // 前端验证
    const validation = AuthService.validateVerificationCodeRequest(request);
    if (!validation.isValid) {
      const failureResponse: VerificationCodeResponse = {
        code: 400,
        message: validation.message
      };
      return failureResponse;
    }

    try {
      const response: ApiResponse = await AuthService.apiCall('/auth/verification-code', request);

      const result: VerificationCodeResponse = {
        code: response.code,
        message: response.code === 200 ? (response.message || '验证码已发送') : (response.message || '发送失败')
      };
      return result;
    } catch (error) {
      Logger.error('Send verification code failed', error);
      const errorResponse: VerificationCodeResponse = {
        code: 500,
        message: '网络错误，请稍后重试'
      };
      return errorResponse;
    }
  }

  /**
   * 验证发送验证码请求
   */
  private static validateVerificationCodeRequest(request: VerificationCodeRequest): ValidationResult {
    // 验证手机号
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!request.phone || !phoneRegex.test(request.phone)) {
      const result: ValidationResult = { isValid: false, message: '请输入正确的手机号' };
      return result;
    }

    // 验证类型
    if (!request.type || (request.type !== 'register' && request.type !== 'login' && request.type !== 'reset')) {
      const result: ValidationResult = { isValid: false, message: '验证码类型无效' };
      return result;
    }

    const result: ValidationResult = { isValid: true, message: '' };
    return result;
  }

  /**
   * 验证token有效性
   */
  static async validateToken(token: string): Promise<boolean> {
    try {
      const response: ApiResponse = await AuthService.apiCall('/auth/validate', { token } as TokenParams);
      return response.code === 200;
    } catch (error) {
      Logger.error('AuthService', 'Token validation failed', String(error));
      return false;
    }
  }

  /**
   * 退出登录
   */
  static async logout(token: string): Promise<boolean> {
    try {
      const response: ApiResponse = await AuthService.apiCall('/auth/logout', { token } as TokenParams);
      return response.code === 200;
    } catch (error) {
      Logger.error('AuthService', 'Logout failed', String(error));
      return false;
    }
  }

  // 存储验证码发送时间的静态变量
  private static lastSendTimes: Map<string, number> = new Map();

  /**
   * 获取上次发送验证码的时间
   */
  private static getLastSendTime(phone: string): number | undefined {
    return AuthService.lastSendTimes.get(phone);
  }

  /**
   * 设置验证码发送时间
   */
  private static setLastSendTime(phone: string, time: number): void {
    AuthService.lastSendTimes.set(phone, time);
  }

  /**
   * 发送HTTP请求到后端API
   */
  private static async apiCall(endpoint: string,
    data: PhoneLoginParams | HuaweiLoginParams | WechatLoginParams | TokenParams | RegisterRequest | VerificationCodeRequest): Promise<ApiResponse> {
    const httpRequest = http.createHttp();

    try {
      const url = `${AuthService.BASE_URL}/api${endpoint}`;
      Logger.info('AUTH', `发起请求: POST ${url}`);
      Logger.debug('AUTH', '请求数据:', JSON.stringify(data));

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        extraData: JSON.stringify(data),
        connectTimeout: 10000,
        readTimeout: 10000
      };

      const response = await httpRequest.request(url, options);

      Logger.info('AUTH', `响应状态码: ${response.responseCode}`);
      Logger.debug('AUTH', '响应数据:', response.result);

      if (response.responseCode >= 200 && response.responseCode < 300) {
        interface BackendResponseData {
          userId?: string;
          user?: UserInfo;
          token?: string;
        }

        interface ApiResult {
          code: number;
          message: string;
          data?: BackendResponseData;
        }

        const result: ApiResult = JSON.parse(response.result as string);

        // 转换后端响应格式到前端期望的格式
        if (result.code === 200) {
          // 对于注册接口，需要特殊处理返回的数据结构
          if (endpoint === '/auth/register' && result.data) {
            const registerResponseData: ApiResponseData = {
              userId: result.data.userId || result.data.user?.id || '',
              username: result.data.user?.username || '',
              token: result.data.token || '',
              createdAt: new Date().toISOString()
            };
            const registerResponse: ApiResponse = {
              code: 200,
              message: result.message,
              data: registerResponseData
            };
            return registerResponse;
          } else {
            let successResponseData: ApiResponseData | undefined = undefined;
            if (result.data) {
              successResponseData = {
                userId: result.data.userId || result.data.user?.id || '',
                username: result.data.user?.username || '',
                token: result.data.token || '',
                createdAt: new Date().toISOString()
              };
            }
            const successResponse: ApiResponse = {
              code: 200,
              message: result.message,
              data: successResponseData
            };
            return successResponse;
          }
        } else {
          const errorResponse: ApiResponse = {
            code: result.code || 500,
            message: result.message || '请求失败'
          };
          return errorResponse;
        }
      } else {
        const errorMsg = `HTTP ${response.responseCode}: ${response.result}`;
        Logger.error('AUTH', `HTTP错误: ${errorMsg}`);
        const networkErrorResponse: ApiResponse = {
          code: response.responseCode,
          message: '网络请求失败，请稍后重试'
        };
        return networkErrorResponse;
      }
    } catch (error) {
      Logger.error('AUTH', '请求失败:', error);

      // 提供更详细的错误信息
      if (error instanceof Error) {
        if (error.message.includes('timeout')) {
          const timeoutResponse: ApiResponse = {
            code: 408,
            message: '请求超时，请检查网络连接'
          };
          return timeoutResponse;
        } else if (error.message.includes('connect')) {
          const connectResponse: ApiResponse = {
            code: 503,
            message: '无法连接到服务器，请检查网络设置'
          };
          return connectResponse;
        }
      }

      return {
        code: 500,
        message: '网络错误，请稍后重试'
      };
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 模拟API调用（保留作为备用方案）
   */
  private static async mockApiCall(endpoint: string,
    data: PhoneLoginParams | HuaweiLoginParams | WechatLoginParams | TokenParams | RegisterRequest | VerificationCodeRequest): Promise<ApiResponse> {
    return new Promise((resolve) => {
      setTimeout(() => {
        // 模拟不同的响应
        switch (endpoint) {
          case '/auth/login/phone':
            const phoneData = data as PhoneLoginParams;
            if (phoneData.phone === '13800138000' && phoneData.password === '123456') {
              const loginData: ApiResponseData = {
                userId: 'user_001',
                username: '测试用户',
                avatar: '',
                token: 'mock_token_' + Date.now(),
                createdAt: new Date().toISOString()
              };
              const loginResponse: ApiResponse = {
                code: 200,
                data: loginData
              };
              resolve(loginResponse);
            } else {
              const errorResponse: ApiResponse = {
                code: 401,
                message: '手机号或密码错误'
              };
              resolve(errorResponse);
            }
            break;

          case '/auth/login/huawei':
            const huaweiData: ApiResponseData = {
              userId: 'huawei_user_001',
              username: '华为用户',
              huaweiId: 'hw_' + Date.now(),
              avatar: '',
              token: 'huawei_token_' + Date.now(),
              createdAt: new Date().toISOString()
            };
            const huaweiResponse: ApiResponse = {
              code: 200,
              data: huaweiData
            };
            resolve(huaweiResponse);
            break;

          case '/auth/login/wechat':
            const wechatData: ApiResponseData = {
              userId: 'wechat_user_001',
              username: '微信用户',
              wechatId: 'wx_' + Date.now(),
              avatar: '',
              token: 'wechat_token_' + Date.now(),
              createdAt: new Date().toISOString()
            };
            const wechatResponse: ApiResponse = {
              code: 200,
              data: wechatData
            };
            resolve(wechatResponse);
            break;

          case '/auth/register':
            const registerRequest = data as RegisterRequest;

            // 模拟检查手机号是否已注册
            if (registerRequest.phone === '13800138000') {
              const phoneExistsResponse: ApiResponse = {
                code: 409,
                message: '该手机号已注册，请直接登录'
              };
              resolve(phoneExistsResponse);
              break;
            }

            // 模拟检查用户名是否已存在
            if (registerRequest.username === 'admin' || registerRequest.username === 'test') {
              const usernameExistsResponse: ApiResponse = {
                code: 409,
                message: '用户名已存在，请更换用户名'
              };
              resolve(usernameExistsResponse);
              break;
            }

            // 模拟验证码验证
            if (registerRequest.verificationCode !== '123456') {
              const codeErrorResponse: ApiResponse = {
                code: 400,
                message: '验证码错误，请重新输入'
              };
              resolve(codeErrorResponse);
              break;
            }

            // 模拟注册成功
            const registerData: ApiResponseData = {
              userId: 'new_user_' + Date.now(),
              username: registerRequest.username,
              avatar: '',
              token: 'mock_token_' + Date.now(),
              createdAt: new Date().toISOString()
            };
            const registerSuccessResponse: ApiResponse = {
              code: 200,
              message: '注册成功，欢迎使用香香记录！',
              data: registerData
            };
            resolve(registerSuccessResponse);
            break;

          case '/auth/verification-code':
            const codeRequest = data as VerificationCodeRequest;

            // 模拟频繁发送限制
            const now = Date.now();
            const lastSendTime = AuthService.getLastSendTime(codeRequest.phone);
            if (lastSendTime && (now - lastSendTime) < 60000) { // 60秒内不能重复发送
              const errorResponse: ApiResponse = {
                code: 429,
                message: '发送过于频繁，请稍后再试'
              };
              resolve(errorResponse);
              break;
            }

            // 模拟手机号格式验证
            const phoneRegex = /^1[3-9]\d{9}$/;
            if (!phoneRegex.test(codeRequest.phone)) {
              const phoneFormatErrorResponse: ApiResponse = {
                code: 400,
                message: '手机号格式不正确'
              };
              resolve(phoneFormatErrorResponse);
              break;
            }

            // 模拟注册时检查手机号是否已存在
            if (codeRequest.type === 'register' && codeRequest.phone === '13800138000') {
              const phoneRegisteredResponse: ApiResponse = {
                code: 409,
                message: '该手机号已注册，请直接登录'
              };
              resolve(phoneRegisteredResponse);
              break;
            }

            // 记录发送时间
            AuthService.setLastSendTime(codeRequest.phone, now);

            const successData: ApiResponseData = {
              userId: '',
              username: '',
              token: '',
              createdAt: '',
              codeId: 'code_' + Date.now(),
              expiresIn: 300 // 5分钟过期
            };
            const successResponse: ApiResponse = {
              code: 200,
              message: '验证码已发送，请注意查收（测试验证码：123456）',
              data: successData
            };
            resolve(successResponse);
            break;

          case '/auth/validate':
            const validateResponse: ApiResponse = {
              code: 200
            };
            resolve(validateResponse);
            break;

          case '/auth/logout':
            const logoutResponse: ApiResponse = {
              code: 200
            };
            resolve(logoutResponse);
            break;

          default:
            const notFoundResponse: ApiResponse = {
              code: 404,
              message: '未知接口'
            };
            resolve(notFoundResponse);
        }
      }, 1000); // 模拟网络延迟
    });
  }
}