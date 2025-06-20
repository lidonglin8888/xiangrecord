/**
 * 网络配置文件
 * 用于配置API服务器地址和网络相关参数
 */

export class NetworkConfig {
  // API服务器配置
  // 注意：在真机或模拟器上运行时，需要将localhost替换为开发机器的实际IP地址
  // 获取本机IP地址的方法：
  // Windows: 在命令行输入 ipconfig，查看IPv4地址
  // macOS/Linux: 在终端输入 ifconfig 或 ip addr，查看inet地址
  
  // 开发环境配置（请根据实际情况修改）
  public static readonly DEV_SERVER_IP = '192.168.8.222'; // 替换为你的开发机器IP
  public static readonly DEV_SERVER_PORT = '8080';
  public static readonly API_BASE_PATH = '/api/v1/records'; // 后端控制器路径
  
  // 生产环境配置
  public static readonly PROD_SERVER_URL = 'https://your-production-server.com/api/v1/records';
  
  // 当前使用的配置
  public static readonly IS_PRODUCTION = false; // 设置为true使用生产环境
  
  // 获取完整的API基础URL
  public static getApiBaseUrl(): string {
    if (NetworkConfig.IS_PRODUCTION) {
      return NetworkConfig.PROD_SERVER_URL;
    } else {
      return `http://${NetworkConfig.DEV_SERVER_IP}:${NetworkConfig.DEV_SERVER_PORT}${NetworkConfig.API_BASE_PATH}`;
    }
  }
  
  // 网络超时配置
  public static readonly CONNECT_TIMEOUT = 10000; // 连接超时 10秒
  public static readonly READ_TIMEOUT = 10000;    // 读取超时 10秒
  
  // 重试配置
  public static readonly MAX_RETRY_COUNT = 3;     // 最大重试次数
  public static readonly RETRY_DELAY = 1000;      // 重试延迟 1秒
  
  // 日志配置
  public static readonly ENABLE_API_LOGS = true;  // 是否启用API日志
  public static readonly ENABLE_DEBUG_LOGS = true; // 是否启用调试日志
}