PYunAPI SDK
---

#### 版本更新

##### [v1.0.6.38] - 2023/06/01

- 支持根据心跳应答检测网络状态，若心跳发送未及时收到心跳应答则触发网络重连。

##### [v1.0.6.36] - 2022/03/20

- 处理在某些语言环境下心跳异常的情况。

##### [v1.0.6.34] - 2021/12/15

- 处理在某些语言环境下心跳异常的情况。

##### [v1.0.6.32] - 2021/04/03

- 优化日志处理逻辑;
- 须先调用`PYunAPILevel`并判断返回值后才允许启动SDK。

##### [v1.0.6.30] - 2020/09/26

- 业务处理默认开辟新线程
- 修复并发情况下请求数据异常的情况

##### [v1.0.6.28] - 2020/04/26

- 调整方法`PYunAPIHashMD5`=>`PYunAPICryptoMD5`;
- 新增方法`PYunAPICryptoCRC`用于提供计算CRC相关算法。

##### [v1.0.6.27] - 2020/03/25

- 业务处理不在开辟新线程;
- 新增`PYunAPIHashMD5`。

##### [v1.0.6.26] - 2020/03/13

- 完善日志输出利于排查问题;
- 支持控制线程模式。

##### [v1.0.6.24] - 2019/10/29

- 新增设置`fingerprint`用于设置当前硬件指纹防止参数滥用。

##### [v1.0.6.22] - 2019/10/04

- 支持同步厂商标识;
- 支持接入平台设置当前设备信息, 例如主机名称及本地IP。

##### [v1.0.6.20] - 2019/03/32

- 修复在未设置通信编码时数据异常。

##### [v1.0.6.18] - 2019/03/01

- 修正发送数据超过10240字节时数据异常;

- 限制最大发送报文长度为500KB。

##### [v1.0.6.17] - 2019/02/23

- 优化底层网络通信。

##### [v1.0.6.16] - 2019/02/15

- 修正`delphi`中示例程序的错误;
- 优化底层网络链接模块。

##### [v1.0.6.15] - 2019/01/29

- 新增`PYunAPIMemcpy`方便在`VB`中处理`char *`读取回调数据。

##### [v1.0.6.14] - 2019/01/28

- 调整`PYunAPIHookEvent`/`PYunAPIHookRequest`回调函数通过`stdcall`标准调用, 老版本升级需要调整回调函数方法定义。

##### [v1.0.6.12] - 2019/01/03

- 修复SDK反复初始化导致异常的错误。

##### [v1.0.6.10] - 2018/12/14

- 当开启开发者模式后支持打印输出数据自动签名信息;

- `PYunAPIStart`传入参数改为SDK自动管理, 不受外部字符串释放影响。

##### [v1.0.6.9] - 2018/12/12

- 新增`PYunAPIVersion`方法供上层获取当前SDK版本。

##### [v1.0.6.8] - 2018/12/09

- 修复返回JSON对象时可能导致签名错误的问题。

- 优化底层认证逻辑。

- 废弃`PYunAPIRegister`方法。

##### [v1.0.6.4] - 2018/11/01

- 修复在`PYunAPIReply`返回数据存在的问题。

##### [v1.0.6.2] - 2018/08/23

- 修正`PYunAPIStart`生命周期可能存在的风险。

##### [v1.0.6.1] - 2018/08/22

- 兼容Windows XP操作系统。

##### [v1.0.4] - 2018/08-21

- 支持通过设置选项`PYUNAPI_OPT_DEVICE`支持多终端。

##### [v1.0.3] - 2018/08/01

- 新增SDK生命周期同步锁;

- 优化Winsock中WSACleanup的使用;

- 调整SDK认证版本号。

### 开发环境

| 属性    | 值      |
|:----- |:------ |
| IDE   | VS2010 |
| 平台工具集 | v100   |

### 文件清单

* 4pyun-api.dll
* 4pyun-api.h

## 方法

### 1. 选项设置

```c
/**
 * 设置API选项值
 * optname 参考 PYUNAPI_OPT_* 的定义
 * 返回值:
 * 0  设置成功
 * -1 不支持选项
 */
int __stdcall PYunAPISetOpt(int optname, void *optval);
```

| 选项定义                  | 值      | 说明              | 类型     | 默认值             |
|:--------------------- |:------:|:--------------- |:------:|:--------------- |
| PYUNAPI_OPT_IDLE_TIME   | 0xffff | TCP心跳间隔时间, 单位ms | int    | 300000          |
| PYUNAPI_OPT_READ_KEY    | 0xfffe | 读数据密钥           | string | -               |
| PYUNAPI_OPT_WRITE_KEY   | 0xfffd | 写数据密钥           | string | -               |
| PYUNAPI_OPT_AUTH_TIME   | 0xfffc | 认证超时时间, 单位ms    | int    | 20000           |
| PYUNAPI_OPT_LOGGER      | 0xfffb | 指定API日志文件路径     | string | ./4pyun-api.log |
| PYUNAPI_OPT_CHARSET     | 0xfffa | 开发编码设置          | string | UTF-8           |
| PYUNAPI_OPT_DEV_MODE    | 0xfff9 | 开发者模式: 1是, 0否   | int    | 0               |
| PYUNAPI_OPT_DEVICE      | 0xfff8 | 多设备模式下设置当前设备ID  | string | `NULL`          |
| PYUNAPI_OPT_HOST_NAME   | 0xfff7 | 当前设备名称  | string | `NULL`          |
| PYUNAPI_OPT_HOST_ADDR   | 0xfff6 | 当前设备本地IP  | string | `NULL`          |
| PYUNAPI_OPT_VENDOR      | 0xfff5 | 当前设备供应商  | string | `NULL`          |
| PYUNAPI_OPT_FINGERPRINT | 0xfff4 | 当前硬件指纹  | string | `NULL`          |
| PYUNAPI_OPT_REPLY_TIME | 0xfff2 | 应答超时时间, 单位ms  | string | 60000      |

**示例**

```c
int idle_time = 60000 * 10;  // 10分钟
int auth_time = 1000 * 30;   // 30秒
int dev_mode = 0;            // 开启开发者模式
// [必须]设置当前项目工程编码, 底层默认UTF-8编码
PYunAPISetOpt(PYUNAPI_OPT_CHARSET,   (void *)"GBK");
// [可选]激活开发者模式, 激活后默认在当前执行目录生成日志文件
PYunAPISetOpt(PYUNAPI_OPT_DEV_MODE,   (void *)&dev_mode);
// [可选]设置心跳间隔时间, ms
PYunAPISetOpt(PYUNAPI_OPT_IDLE_TIME, (void *)&idle_time);
// [可选]设置授权超时时间, ms
PYunAPISetOpt(PYUNAPI_OPT_AUTH_TIME, (void *)&auth_time);
// [可选]设置日志文件
PYunAPISetOpt(PYUNAPI_OPT_LOGGER, (void *)"C:/4pyun-api.log");
```

### 2. 事件拦截

```c
/**
 * 参数:
 * event_type 参考 `PYUNAPI_EVENT_*` 的定义。
 * msg        针对目前event_type的描述说明。
 */
typedef void (__stdcall *event_callback)(int event_type, char *msg);

/**
 * 设置事件回调函数
 */
void __stdcall PYunAPIHookEvent(event_callback p_callback);
```

| 选项定义                         | 值   | 说明      |
|:---------------------------- |:---:| ------- |
| PYUNAPI_EVENT_ACCESS_GRANTED | 1   | API授权成功 |
| PYUNAPI_EVENT_ACCESS_DENIED  | -1  | API授权失败 |
| PYUNAPI_EVENT_CHANNEL_ERROR  | -2  | TCP连接异常 |
| PYUNAPI_EVENT_CHANNEL_CLOSED | -3  | TCP链接关闭 |

**示例**

```c
/**
 * API事件回调函数实现
 */
void __stdcall PYunAPIEventCallback(int event_type, char *msg){  
    switch (event_type) {
        case PYUNAPI_EVENT_ACCESS_GRANTED:
            printf("\nAccessGranted\n\n");
            break;
        case PYUNAPI_EVENT_ACCESS_DENIED:
            printf("\nAccessDenied %s\n\n", msg == NULL ? "" : msg);
            break;
        case PYUNAPI_EVENT_CHANNEL_ERROR:
            printf("\nChannelError %s\n\n", msg == NULL ? "" : msg);
            break;
        case PYUNAPI_EVENT_CHANNEL_CLOSED:
            printf("\nChannelClosed %s\n\n", msg == NULL ? "" : msg);
            break;
    }
    return;
}

// 设置事件拦截回调函数
PYunAPIHookEvent(PYunAPIEventCallback);
```

### 3.  拦截请求回调

通过该方法拦截后将不再通过函数触发请求回调, 所有的请求解析和数据返回由开发者自行处理, 请求处理成功需要调用`PYunAPIReply`返回数据。

```c
/**
 * 请求回调函数
 * 参数:
 * seqno   请求序号, 需原样返回
 * payload 请求JSON数据
*
 * 返回值:
 * 1 请求已受理
 * 0 请求未受理
 */
typedef int (__stdcall *request_callback)(int seqno, char *payload);

/**
 * 设置请求拦截回调函数
 */
void __stdcall PYunAPIHookRequest(request_callback p_callback);
```

**示例**

```c
int __stdcall PYunAPIRequestCallback(int seqno, char *payload) {
    // 根据JSON中的service判断是否处理, 如果没处理将ret设置为-1。
    int ret = 0;
    printf("RECV: %d, %s\n", seqno, payload);
    char *reply = "{\"service\":\"service.parking.detail\",\"version\":\"1.0\",\"charset\":\"UTF-8\",\"result_code\":\"1001\",\"message\":\"处理OK\",\"sign\":\"722059C5CC1B3FF5CDF8F8A4CF3B31CC\"}";
    // Reply的时候必须原样返回seqno!
    PYunAPIReply(seqno, reply);
    return ret;
}

// 设置请求回调函数
PYunAPIHookRequest(PYunAPIRequestCallback);
```

### 4.  发送请求结果响应

```c
/**
 * 发送请求结果响应, 线程安全, 该方法会自动为发送的payload计算签名。
 * 参数:
 * seqno   请求序号
 * payload 应答JSON数据
 *
 * 返回值:
 * 0  发送成功
 * -1 发送失败
 */
int __stdcall PYunAPIReply(int seqno, char *payload);
```

### 5. 初始化API

在所有设置完成后需要调用该方法完成API初始化, 底层会开启一个线程和云端保持TCP长链接, 链接的状态可通过`PYunAPIHookEvent`注册的回调方法异步触发。

*注: 每次重新设置后需要`PYunAPIDestory`后重新调用`PYunAPIStart`完成初始化。*

```c
/**
 * 初始化API
 * 参数:
 * host 云平台域名
 * port 云平台端口
 * type 客户端类型
 * uuid 客户端UUID, 一个UUID只能运行一个实例
 * sign_mac 接口通信JSON签名计算密钥
 *
 * 返回值:
 * 0 初始化完成
 */
int __stdcall PYunAPIStart(char *host, unsigned int port, char *type, char *uuid, char *sign_mac);
```

**示例**

```c
int idle_time = 1000 * 30;
int auth_time = 1000 * 30;
int dev_mode = 0;
char *host = "sandbox.gate.4pyun.com";
unsigned int port = 8661;
char *type = "public:parking:agent";
char *uuid = "49f0cc52-e8c7-41e3-b54d-af666b8cc11a";
char *sign_mac = "22D42dSdae2";

// 获取SDK API等级, 必须执行这个步骤
int sdk_level = PYunAPILevel();
if (sdk_level < 10) {
    // 过低的SDK版本
    return -1;
}

// 1.1 设置事件拦截回调函数
PYunAPIHookEvent(PYunAPIEventCallback);
// 1.2 拦截请求回调
PYunAPIHookRequest(PYunAPIRequestCallback);

// 1.3 设置可选项
// [必须]设置当前项目工程编码, 底层默认UTF-8编码
PYunAPISetOpt(PYUNAPI_OPT_CHARSET,   (void *)"GBK");
// [可选]设置厂商代码, 用于区分设备厂商, 接入联系P云分配!
PYunAPISetOpt(PYUNAPI_OPT_VENDOR,   (void *)"PYUN");
// [可选]激活开发者模式, 默认在当前执行目录生成日志文件
PYunAPISetOpt(PYUNAPI_OPT_DEV_MODE,   (void *)&dev_mode);
// [可选]设置心跳间隔时间, ms
PYunAPISetOpt(PYUNAPI_OPT_IDLE_TIME, (void *)&idle_time);
// [可选]设置授权超时时间, ms
PYunAPISetOpt(PYUNAPI_OPT_AUTH_TIME, (void *)&auth_time);
// [可选]设置日志文件
PYunAPISetOpt(PYUNAPI_OPT_LOGGER, (void *)"C:/4pyun-api.log");

// 2. 启动API, 底层会开启线程和云端保持TCP长连接
PYunAPIStart(host, port, type, uuid, sign_mac);
// 3. 销毁API, 断开TCP长连接
getchar();
PYunAPIDestroy();
getchar();
```

### 6. 销毁API

当程序关闭时调用该方法可以主动关闭和云端链接并释放资源。

```c
/**
 * 销毁API, 主动关闭和云端链接并释放资源。
 */
void __stdcall PYunAPIDestroy();
```

### 7. 获取SDK版本及API版本

上层应用可通过调用该方法获取当前SDK版本信息。

```c
/**
 * 获取当前SDK版本号
 */
char* __stdcall PYunAPIVersion();
```

```c
/**
 * 获取当前SDK API等级, 版本越新值越大
 */
char* __stdcall PYunAPILevel();
```

### 8. 内存拷贝

在`VB`中要处理回调函数中的`char *`比较麻烦, SDK中方法实现如下:

```c
int __stdcall PYunAPIMemcpy(char *src, char *dst) {
    memcpy(dst, src, strlen(src) + 1);    
    log_trace("[PYunAPI][Memcpy] - %p => %p, STR: %s", src, dst, src);
    return 0;
}
```

在VB中可

```vb
' 引入DLL方法, 这里将内存地址设置为long传递
Public Declare Function PYunAPIMemcpy Lib "4pyun-api.dll" (ByVal src As Long, ByVal dst As Long) As Integer

Public Sub ApiEventCallback(ByVal event_type As Long, ByVal pMsg As Long)
    Dim buf(2048) As Byte
    If pMsg > 0 Then PYunAPIMemcpy pMsg, VarPtr(buf(0))
    Dim msg As String
    msg = Utf8BytesToString(buf)
End Sub
```

### 附录

#### A. 多终端设置

默认P云一个项目只允许保持一个有效TCP连接用于数据通信, 为兼容部分系统厂商暂时提供多终端的解决方案, 该方案允许各个终端设置自己的`device`用于区分不同的终端。

在停车场景, `device`需设置为当前通道口ID, 设置方法如下:

```c
// 只控制通道A
char *device = "A";
// 同时控制通道A、B、C
char *device = "A,B,C";

// [可选]设置设备ID, 仅在多终端模式下设置
PYunAPISetOpt(PYUNAPI_OPT_DEVICE, (void *)device);t
```

### B. 设备信息设置

为便于排查多终端链接情况, SDK已提供支持设置设备信息便于查看当前具体连接到平台到终端信息例如: 主机名称、本地IP:

```c
// 主机名称
char *hostname = "PC-1-1";
// 本地IP
char *local_ip = "192.168.1.66";

// [可选]设置当前本地主机名称
PYunAPISetOpt(PYUNAPI_OPT_HOST_NAME, (void *)hostname);
// [可选]设置当前本地主机IP
PYunAPISetOpt(PYUNAPI_OPT_HOST_ADDR, (void *)host_address);
```

### C. SDK日志说明

由于SDK不会自动按日归档, 建议你可以隔日调用以下方法设置新的文件路径:
```c
PYunAPISetOpt(PYUNAPI_OPT_LOGGER, (void *)"C:/4pyun-api-20210401.log");
```
