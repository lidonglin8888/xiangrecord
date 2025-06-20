1. 在没有特殊要求的情况下，优先使用中文回答
2. 当你对语法不自信时，想使用工具联网搜索，确保基本的语法正确
3. 规避以下问题：
    ### 1. 对象字面量类型声明错误
    - 问题 ：直接使用 Record<string, string | object> 等通用类型
    - 解决方案 ：为每种用途创建专门的接口（如 PhoneLoginParams 、 HuaweiLoginParams 等）
    - 教训 ：ArkTS要求明确的类型声明，避免使用过于宽泛的类型
    ### 2. 联合类型属性访问错误
    - 问题 ：直接访问联合类型的属性（如 data.phone ），编译器无法确定属性是否存在
    - 解决方案 ：使用类型断言（ const phoneData = data as PhoneLoginParams ）或类型守卫
    - 教训 ：处理联合类型时必须进行类型收窄
    ### 3. 禁用类型使用
    - 问题 ：使用 any 、 unknown 等被ArkTS禁止的类型
    - 解决方案 ：定义具体的接口类型替代
    - 教训 ：ArkTS强制类型安全，不允许类型逃逸
4. 使用以下cmd命令构建：node "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
