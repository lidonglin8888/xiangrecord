import { common } from '@kit.AbilityKit';

/**
 * 上下文管理器
 * 用于管理应用的上下文信息
 */
export class ContextManager {
  private static context: common.UIAbilityContext | null = null;

  /**
   * 设置应用上下文
   * @param context UIAbilityContext
   */
  static setContext(context: common.UIAbilityContext): void {
    ContextManager.context = context;
  }

  /**
   * 获取应用上下文
   * @returns UIAbilityContext | null
   */
  static getContext(): common.UIAbilityContext | null {
    return ContextManager.context;
  }

  /**
   * 清除上下文
   */
  static clearContext(): void {
    ContextManager.context = null;
  }

  /**
   * 检查上下文是否已设置
   * @returns boolean
   */
  static hasContext(): boolean {
    return ContextManager.context !== null;
  }
}

export default ContextManager;