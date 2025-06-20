#!/bin/bash

# 环境切换脚本 - Linux/macOS版本
# 用于快速切换Spring Boot应用的运行环境

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo
    echo -e "${GREEN}环境切换脚本${NC}"
    echo
    echo -e "${YELLOW}用法:${NC}"
    echo "  ./switch-env.sh <environment>"
    echo
    echo -e "${YELLOW}支持的环境:${NC}"
    echo "  dev   - 开发环境 (H2数据库, 热重载, 详细日志)"
    echo "  prod  - 生产环境 (MySQL数据库, 优化配置, 生产日志)"
    echo "  test  - 测试环境 (H2数据库, 测试配置, 简化日志)"
    echo
    echo -e "${YELLOW}示例:${NC}"
    echo "  ./switch-env.sh dev"
    echo "  ./switch-env.sh prod"
    echo "  ./switch-env.sh test"
    echo
    echo -e "${YELLOW}选项:${NC}"
    echo "  -h, --help    显示此帮助信息"
    echo
}

# 检查参数
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# 获取环境参数
ENV="$1"

# 验证环境参数
if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ] && [ "$ENV" != "test" ]; then
    echo -e "${RED}错误: 无效的环境参数 '$ENV'${NC}"
    echo "支持的环境: dev, prod, test"
    show_help
    exit 1
fi

echo -e "${BLUE}正在切换到 $ENV 环境...${NC}"
echo

# 设置项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# 检查Maven是否可用
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}错误: Maven未安装或不在PATH中${NC}"
    echo "请先安装Maven并配置环境变量"
    exit 1
fi

# 根据环境设置不同的启动参数
case "$ENV" in
    "dev")
        echo -e "${GREEN}开发环境配置:${NC}"
        echo "- 使用H2内存数据库"
        echo "- 启用热重载"
        echo "- 启用H2控制台"
        echo "- 详细日志输出"
        echo "- 启用Swagger文档"
        echo
        SPRING_PROFILES="dev"
        JVM_OPTS="-Xms256m -Xmx512m -Dspring.profiles.active=dev"
        MAVEN_OPTS="-Dspring-boot.run.profiles=dev"
        ;;
    "prod")
        echo -e "${YELLOW}生产环境配置:${NC}"
        echo "- 使用MySQL数据库"
        echo "- 优化JVM参数"
        echo "- 禁用开发工具"
        echo "- 生产级日志配置"
        echo "- 禁用Swagger文档"
        echo
        SPRING_PROFILES="prod"
        JVM_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -Dspring.profiles.active=prod"
        MAVEN_OPTS="-Dspring-boot.run.profiles=prod"
        ;;
    "test")
        echo -e "${BLUE}测试环境配置:${NC}"
        echo "- 使用H2内存数据库"
        echo "- 随机端口"
        echo "- 测试数据初始化"
        echo "- 简化日志输出"
        echo
        SPRING_PROFILES="test"
        JVM_OPTS="-Xms128m -Xmx256m -Dspring.profiles.active=test"
        MAVEN_OPTS="-Dspring-boot.run.profiles=test"
        ;;
esac

# 设置环境变量
export SPRING_PROFILES_ACTIVE="$SPRING_PROFILES"
export MAVEN_OPTS="$MAVEN_OPTS"

# 显示当前配置
echo -e "${GREEN}当前配置:${NC}"
echo "SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE"
echo "JVM_OPTS=$JVM_OPTS"
echo "MAVEN_OPTS=$MAVEN_OPTS"
echo

# 询问是否启动应用
read -p "是否立即启动应用? (y/n): " START_APP

if [[ "$START_APP" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    echo -e "${GREEN}正在启动应用...${NC}"
    echo
    
    # 启动Spring Boot应用
    mvn spring-boot:run
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}应用启动成功${NC}"
    else
        echo -e "${RED}应用启动失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}环境已切换到 $ENV，可以手动启动应用${NC}"
    echo "启动命令: mvn spring-boot:run"
fi

echo
echo -e "${GREEN}环境切换完成!${NC}"

# 显示有用的命令
echo
echo -e "${YELLOW}有用的命令:${NC}"
echo "  查看当前profile: echo \$SPRING_PROFILES_ACTIVE"
echo "  手动启动应用: mvn spring-boot:run"
echo "  构建应用: mvn clean package"
echo "  运行测试: mvn test"

if [ "$ENV" = "dev" ]; then
    echo "  访问H2控制台: http://localhost:8080/api/h2-console"
    echo "  访问Swagger文档: http://localhost:8080/api/swagger-ui.html"
elif [ "$ENV" = "prod" ]; then
    echo "  查看应用日志: tail -f logs/xiangrecord.log"
    echo "  监控应用状态: curl http://localhost:8080/api/actuator/health"
fi

echo