#ifdef PYUNAPIDLL_EXPORTS
#define PYUNAPIDLL_API extern "C" __declspec(dllexport) 
#else
#define PYUNAPIDLL_API extern "C" __declspec(dllimport) 
#endif

// -------------------------
// SDK API 选项
// 心跳时间, 单位ms
#define PYUNAPI_OPT_IDLE_TIME       0xffff
// TCP连接读数据密钥
#define PYUNAPI_OPT_READ_KEY        0xfffe
// TCP连接发送密钥
#define PYUNAPI_OPT_WRITE_KEY       0xfffd
// 认证超时时间, 单位ms
#define PYUNAPI_OPT_AUTH_TIME       0xfffc
// 日志文件路径
#define PYUNAPI_OPT_LOGGER		    0xfffb
// 返回数据编码
#define PYUNAPI_OPT_CHARSET         0xfffa
// 激活开发者模式
#define PYUNAPI_OPT_DEV_MODE        0xfff9
// 设置设备ID, 在一个场多设备连接需指定
#define PYUNAPI_OPT_DEVICE          0xfff8
// 设置当前设备名称
#define PYUNAPI_OPT_HOST_NAME       0xfff7
// 设置当前设备IP
#define PYUNAPI_OPT_HOST_ADDR       0xfff6
// 设置当前设备供应商
#define PYUNAPI_OPT_VENDOR          0xfff5
// 设置当前设备供应商
#define PYUNAPI_OPT_FINGERPRINT     0xfff4
// 设置单线程工作模式
#define PYUNAPI_OPT_SINGLE_THREAD   0xfff3

// -------------------------
// SDK API 事件
// API授权成功
#define PYUNAPI_EVENT_ACCESS_GRANTED  1
// API授权拒绝
#define PYUNAPI_EVENT_ACCESS_DENIED   -1
// TCP连接异常
#define PYUNAPI_EVENT_CHANNEL_ERROR   -2
// TCP连接关闭
#define PYUNAPI_EVENT_CHANNEL_CLOSED  -3

// -------------------------
// SDK CRC 算法
// CRC-16/IBM
#define PYUNAPI_CRYPTO_CRC16_ARC        0x0000
// CRC-16/MODBUS
#define PYUNAPI_CRYPTO_CRC16_MODBUS     0x0001
// CRC-16/USB
#define PYUNAPI_CRYPTO_CRC16_USB        0x0002
// CRC-16/DNP
#define PYUNAPI_CRYPTO_CRC16_DNP        0x0003
// CRC-16/CCITT-FALSE
#define PYUNAPI_CRYPTO_CRC16_CCCT_FALSE 0x0004
// CRC-16/XMODEM
#define PYUNAPI_CRYPTO_CRC16_XMODEM     0x0005
// CRC-16/CCITT(KERMIT)
#define PYUNAPI_CRYPTO_CRC16_CCCT       0x0006

// -------------------------
// 事件回调函数
/**
 * 参数:
 * event_type 参考 `PYUNAPI_EVENT_*` 的定义。
 * msg        针对目前event_type的描述说明。
 */
typedef void (__stdcall *event_callback)(int event_type, char *msg);

/**
 * 请求回调函数
 * 参数:
 * seqno   请求序号, 需原样返回
 * payload 本次请求数据, JSON格式字符串
 *
 * 返回值:
 * 1 请求已受理
 * 0 请求未受理
 */
typedef int (__stdcall *request_callback)(int seqno, char *payload);

/**
 * 设置事件回调函数
 */
PYUNAPIDLL_API void __stdcall PYunAPIHookEvent(event_callback p_callback);

/**
 * 设置请求回调函数
 */
PYUNAPIDLL_API void __stdcall PYunAPIHookRequest(request_callback p_callback);

/**
 * 发送请求返回数据
 * 0 发送成功
 * -1 发送失败
 */
PYUNAPIDLL_API int __stdcall PYunAPIReply(int seqno, char *payload);

/**
 * 设置API相关参数
 * optname 参考 `PYUNAPI_OPT_*` 的定义
 * 返回值:
 * 0  设置成功
 * -1 不支持选项
 */
PYUNAPIDLL_API int __stdcall PYunAPISetOpt(int optname, void *optval);

/**
 * 设置API相关参数
 * optname 参考 `PYUNAPI_OPT_*` 的定义
 */
PYUNAPIDLL_API void * __stdcall PYunAPIGetOpt(int optname);

/**
 * 设置API启用调试模式
 */
PYUNAPIDLL_API void __stdcall PYunAPISetDevMode(int flags);

/**
 * 设置API字符集
 */
PYUNAPIDLL_API void __stdcall PYunAPISetCharset(char *charset);

/**
 * 设置API设备ID
 */
PYUNAPIDLL_API void __stdcall PYunAPISetDevice(char *device);

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
PYUNAPIDLL_API int __stdcall PYunAPIStart(char *host, unsigned int port, char *type, char *uuid, char *sign_mac);

/**
 * 销毁API, 主动关闭和云端链接并释放资源。
 */
PYUNAPIDLL_API int __stdcall PYunAPIDestroy();

/**
 * 获取SDK版本号
 */
PYUNAPIDLL_API char * __stdcall PYunAPIVersion();

/**
 * 将`src`的数据通过memcpy到`dst`
 */
PYUNAPIDLL_API int __stdcall PYunAPIMemcpy(char *src, char *dst);

/**
 * 计算input字符串MD5值
 */
PYUNAPIDLL_API int __stdcall PYunAPICryptoMD5(char *input, char *output);

/**
 * 计算input字符串CRC16值
 */
PYUNAPIDLL_API int __stdcall PYunAPICryptoCRC(char *input, char *output, int algorithm);