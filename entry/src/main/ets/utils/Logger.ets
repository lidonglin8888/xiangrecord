/**
 * 日志工具类
 * 统一管理应用的日志输出，支持不同级别的日志
 */

import { NetworkConfig } from '../config/NetworkConfig';

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3
}

export class Logger {
  private static readonly TAG_PREFIX = '[XiangRecord]';
  
  /**
   * 调试日志
   * @param tag 标签
   * @param message 消息
   * @param data 可选的数据对象
   */
  public static debug(tag: string, message: string, data?: string | number | object): void {
    if (NetworkConfig.ENABLE_DEBUG_LOGS) {
      const fullTag = `${Logger.TAG_PREFIX}[${tag}]`;
      if (data !== undefined) {
        console.debug(`${fullTag} ${message}`, data);
      } else {
        console.debug(`${fullTag} ${message}`);
      }
    }
  }
  
  /**
   * 信息日志
   * @param tag 标签
   * @param message 消息
   * @param data 可选的数据对象
   */
  public static info(tag: string, message: string, data?: string | number | object): void {
    if (NetworkConfig.ENABLE_API_LOGS) {
      const fullTag = `${Logger.TAG_PREFIX}[${tag}]`;
      if (data !== undefined) {
        console.info(`${fullTag} ${message}`, data);
      } else {
        console.info(`${fullTag} ${message}`);
      }
    }
  }
  
  /**
   * 警告日志
   * @param tag 标签
   * @param message 消息
   * @param data 可选的数据对象
   */
  public static warn(tag: string, message: string, data?: string | number | object): void {
    const fullTag = `${Logger.TAG_PREFIX}[${tag}]`;
    if (data !== undefined) {
      console.warn(`${fullTag} ${message}`, data);
    } else {
      console.warn(`${fullTag} ${message}`);
    }
  }
  
  /**
   * 错误日志
   * @param tag 标签
   * @param message 消息
   * @param error 可选的错误对象
   */
  public static error(tag: string, message: string, error?: string | number): void {
    const fullTag = `${Logger.TAG_PREFIX}[${tag}]`;
    if (error !== undefined) {
      console.error(`${fullTag} ${message}`, error);
    } else {
      console.error(`${fullTag} ${message}`);
    }
  }
  
  /**
   * API相关的日志
   * @param message 消息
   * @param data 可选的数据对象
   */
  public static api(message: string, data?: string | number | object): void {
    Logger.info('API', message, data);
  }
  
  /**
   * 网络连接相关的日志
   * @param message 消息
   * @param data 可选的数据对象
   */
  public static network(message: string, data?: string | number | object): void {
    Logger.info('NETWORK', message, data);
  }
  
  /**
   * UI相关的日志
   * @param message 消息
   * @param data 可选的数据对象
   */
  public static ui(message: string, data?: string | number | object): void {
    Logger.debug('UI', message, data);
  }
  
  /**
   * 数据相关的日志
   * @param message 消息
   * @param data 可选的数据对象
   */
  public static data(message: string, data?: string | number | object): void {
    Logger.debug('DATA', message, data);
  }
}