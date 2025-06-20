/**
 * 网络诊断工具
 * 帮助用户快速定位网络连接问题
 */

import http from '@ohos.net.http';
import { NetworkConfig } from '../config/NetworkConfig';
import { Logger } from './Logger';

export interface DiagnosticResult {
  success: boolean;
  message: string;
  details?: string[];
  suggestions?: string[];
}

export class NetworkDiagnostic {

  /**
   * 执行完整的网络诊断
   */
  public static async runFullDiagnostic(): Promise<DiagnosticResult[]> {
    Logger.network('开始执行网络诊断...');

    const results: DiagnosticResult[] = [];
    
    // 1. 检查网络配置
    results.push(await NetworkDiagnostic.checkNetworkConfig());
    
    // 2. 检查基础连通性
    results.push(await NetworkDiagnostic.checkBasicConnectivity());
    
    // 3. 检查API端点
    results.push(await NetworkDiagnostic.checkApiEndpoint());
    
    // 4. 检查HTTP请求
    results.push(await NetworkDiagnostic.checkHttpRequest());
    
    Logger.network('网络诊断完成');
    return results;
  }
  
  /**
   * 检查网络配置
   */
  private static async checkNetworkConfig(): Promise<DiagnosticResult> {
    try {
      const baseUrl = NetworkConfig.getApiBaseUrl();
      const isLocalhost = baseUrl.includes('localhost') || baseUrl.includes('127.0.0.1');
      
      if (isLocalhost) {
        return {
          success: false,
          message: '检测到使用localhost地址',
          details: [
            `当前API地址: ${baseUrl}`,
            'localhost在真机/模拟器上指向设备本身，无法访问开发机器'
          ],
          suggestions: [
            '请在NetworkConfig.ets中将DEV_SERVER_IP修改为开发机器的实际IP地址',
            'Windows: 命令行输入 ipconfig 查看IPv4地址',
            'macOS/Linux: 终端输入 ifconfig 查看inet地址'
          ]
        };
      }
      
      return {
        success: true,
        message: '网络配置检查通过',
        details: [`API地址: ${baseUrl}`]
      };
    } catch (error) {
      return {
        success: false,
        message: '网络配置检查失败',
        details: [`错误: ${error}`]
      };
    }
  }
  
  /**
   * 检查基础连通性
   */
  private static async checkBasicConnectivity(): Promise<DiagnosticResult> {
    try {
      const httpRequest = http.createHttp();
      const baseUrl = NetworkConfig.getApiBaseUrl();
      const serverUrl = baseUrl.replace('/api/v1/records', '');
      
      const response = await httpRequest.request(serverUrl, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      });
      
      httpRequest.destroy();
      
      if (response.responseCode === 200 || response.responseCode === 404) {
        return {
          success: true,
          message: '服务器连通性检查通过',
          details: [`响应码: ${response.responseCode}`]
        };
      } else {
        return {
          success: false,
          message: '服务器响应异常',
          details: [`响应码: ${response.responseCode}`],
          suggestions: ['检查服务器是否正常运行', '检查端口是否开放']
        };
      }
    } catch (error) {
      return {
        success: false,
        message: '无法连接到服务器',
        details: [`错误: ${error}`],
        suggestions: [
          '检查网络连接是否正常',
          '确认服务器IP地址和端口正确',
          '检查防火墙设置',
          '确认服务器已启动'
        ]
      };
    }
  }
  
  /**
   * 检查API端点
   */
  private static async checkApiEndpoint(): Promise<DiagnosticResult> {
    try {
      const httpRequest = http.createHttp();
      const baseUrl = NetworkConfig.getApiBaseUrl();
      
      const response = await httpRequest.request(baseUrl, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        connectTimeout: NetworkConfig.CONNECT_TIMEOUT,
        readTimeout: NetworkConfig.READ_TIMEOUT
      });
      
      httpRequest.destroy();
      
      if (response.responseCode === 200) {
        return {
          success: true,
          message: 'API端点检查通过',
          details: [`响应码: ${response.responseCode}`]
        };
      } else {
        return {
          success: false,
          message: 'API端点响应异常',
          details: [
            `响应码: ${response.responseCode}`,
            `响应内容: ${response.result}`
          ],
          suggestions: [
            '检查API路径是否正确',
            '确认后端服务API接口已实现',
            '检查服务器日志'
          ]
        };
      }
    } catch (error) {
      return {
        success: false,
        message: 'API端点检查失败',
        details: [`错误: ${error}`],
        suggestions: [
          '检查API路径配置',
          '确认后端服务正常运行',
          '检查网络连接'
        ]
      };
    }
  }
  
  /**
   * 检查HTTP请求
   */
  private static async checkHttpRequest(): Promise<DiagnosticResult> {
    try {
      const httpRequest = http.createHttp();
      const baseUrl = NetworkConfig.getApiBaseUrl();
      
      // 尝试发送一个简单的GET请求
      const response = await httpRequest.request(`${baseUrl}?page=1&size=1`, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        connectTimeout: NetworkConfig.CONNECT_TIMEOUT,
        readTimeout: NetworkConfig.READ_TIMEOUT
      });
      
      httpRequest.destroy();
      
      if (response.responseCode === 200) {
        try {
          JSON.parse(response.result as string);
          return {
            success: true,
            message: 'HTTP请求检查通过',
            details: [
              `响应码: ${response.responseCode}`,
              `数据格式: JSON`,
              `响应大小: ${(response.result as string).length} 字符`
            ]
          };
        } catch (parseError) {
          return {
            success: false,
            message: 'HTTP请求成功但数据格式异常',
            details: [
              `响应码: ${response.responseCode}`,
              `解析错误: ${parseError}`,
              `响应内容: ${response.result}`
            ],
            suggestions: ['检查后端API返回的数据格式']
          };
        }
      } else {
        return {
          success: false,
          message: 'HTTP请求失败',
          details: [
            `响应码: ${response.responseCode}`,
            `响应内容: ${response.result}`
          ],
          suggestions: ['检查API接口实现', '查看服务器日志']
        };
      }
    } catch (error) {
      return {
        success: false,
        message: 'HTTP请求检查失败',
        details: [`错误: ${error}`],
        suggestions: [
          '检查网络连接',
          '确认服务器状态',
          '检查请求参数'
        ]
      };
    }
  }
  
  /**
   * 生成诊断报告
   */
  public static generateReport(results: DiagnosticResult[]): string {
    let report = '=== 网络诊断报告 ===\n\n';
    
    results.forEach((result, index) => {
      const status = result.success ? '✅ 通过' : '❌ 失败';
      report += `${index + 1}. ${result.message} ${status}\n`;
      
      if (result.details && result.details.length > 0) {
        report += '   详情:\n';
        result.details.forEach(detail => {
          report += `   - ${detail}\n`;
        });
      }
      
      if (result.suggestions && result.suggestions.length > 0) {
        report += '   建议:\n';
        result.suggestions.forEach(suggestion => {
          report += `   - ${suggestion}\n`;
        });
      }
      
      report += '\n';
    });
    
    const successCount = results.filter(r => r.success).length;
    const totalCount = results.length;
    report += `总结: ${successCount}/${totalCount} 项检查通过\n`;
    
    if (successCount === totalCount) {
      report += '🎉 所有检查都通过了！网络连接应该正常。';
    } else {
      report += '⚠️ 发现问题，请根据上述建议进行排查。';
    }
    
    return report;
  }
}