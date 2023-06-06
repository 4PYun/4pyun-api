#ifdef PYUNAPIDLL_EXPORTS
#define PYUNAPIDLL_API extern "C" __declspec(dllexport) 
#else
#define PYUNAPIDLL_API extern "C" __declspec(dllimport) 
#endif

// -------------------------
// SDK API ѡ��
// ����ʱ��, ��λms
#define PYUNAPI_OPT_IDLE_TIME       0xffff
// TCP���Ӷ�������Կ
#define PYUNAPI_OPT_READ_KEY        0xfffe
// TCP���ӷ�����Կ
#define PYUNAPI_OPT_WRITE_KEY       0xfffd
// ��֤��ʱʱ��, ��λms
#define PYUNAPI_OPT_AUTH_TIME       0xfffc
// ��־�ļ�·��
#define PYUNAPI_OPT_LOGGER		    0xfffb
// �������ݱ���
#define PYUNAPI_OPT_CHARSET         0xfffa
// �������ģʽ
#define PYUNAPI_OPT_DEV_MODE        0xfff9
// �����豸ID, ��һ�������豸������ָ��
#define PYUNAPI_OPT_DEVICE          0xfff8
// ���õ�ǰ�豸����
#define PYUNAPI_OPT_HOST_NAME       0xfff7
// ���õ�ǰ�豸IP
#define PYUNAPI_OPT_HOST_ADDR       0xfff6
// ���õ�ǰ�豸��Ӧ��
#define PYUNAPI_OPT_VENDOR          0xfff5
// ���õ�ǰ�豸��Ӧ��
#define PYUNAPI_OPT_FINGERPRINT     0xfff4
// ���õ��̹߳���ģʽ
#define PYUNAPI_OPT_SINGLE_THREAD   0xfff3
// ����Ӧ��ʱʱ��, ��λms
#define PYUNAPI_OPT_REPLY_TIME      0xfff2

// -------------------------
// SDK API �¼�
// API��Ȩ�ɹ�
#define PYUNAPI_EVENT_ACCESS_GRANTED  1
// API��Ȩ�ܾ�
#define PYUNAPI_EVENT_ACCESS_DENIED   -1
// TCP�����쳣
#define PYUNAPI_EVENT_CHANNEL_ERROR   -2
// TCP���ӹر�
#define PYUNAPI_EVENT_CHANNEL_CLOSED  -3

// -------------------------
// SDK CRC �㷨
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
// �¼��ص�����
/**
 * ����:
 * event_type �ο� `PYUNAPI_EVENT_*` �Ķ��塣
 * msg        ���Ŀǰevent_type������˵����
 */
typedef void (__stdcall *event_callback)(int event_type, char *msg);

/**
 * ����ص�����
 * ����:
 * seqno   �������, ��ԭ������
 * payload ������������, JSON��ʽ�ַ���
 *
 * ����ֵ:
 * 1 ����������
 * 0 ����δ����
 */
typedef int (__stdcall *request_callback)(int seqno, char *payload);

/**
 * �����¼��ص�����
 */
PYUNAPIDLL_API void __stdcall PYunAPIHookEvent(event_callback p_callback);

/**
 * ��������ص�����
 */
PYUNAPIDLL_API void __stdcall PYunAPIHookRequest(request_callback p_callback);

/**
 * �������󷵻�����
 * 0 ���ͳɹ�
 * -1 ����ʧ��
 */
PYUNAPIDLL_API int __stdcall PYunAPIReply(int seqno, char *payload);

/**
 * ����API��ز���
 * optname �ο� `PYUNAPI_OPT_*` �Ķ���
 * ����ֵ:
 * 0  ���óɹ�
 * -1 ��֧��ѡ��
 */
PYUNAPIDLL_API int __stdcall PYunAPISetOpt(int optname, void *optval);

/**
 * ����API��ز���
 * optname �ο� `PYUNAPI_OPT_*` �Ķ���
 */
PYUNAPIDLL_API void * __stdcall PYunAPIGetOpt(int optname);

/**
 * ����API���õ���ģʽ
 */
PYUNAPIDLL_API void __stdcall PYunAPISetDevMode(int flags);

/**
 * ����API�ַ���
 */
PYUNAPIDLL_API void __stdcall PYunAPISetCharset(char *charset);

/**
 * ����API�豸ID
 */
PYUNAPIDLL_API void __stdcall PYunAPISetDevice(char *device);

/**
 * ��ʼ��API
 * ����:
 * host ��ƽ̨����
 * port ��ƽ̨�˿�
 * type �ͻ�������
 * uuid �ͻ���UUID, һ��UUIDֻ������һ��ʵ��
 * sign_mac �ӿ�ͨ��JSONǩ��������Կ
 * 
 * ����ֵ:
 * 0 ��ʼ�����
 */
PYUNAPIDLL_API int __stdcall PYunAPIStart(char *host, unsigned int port, char *type, char *uuid, char *sign_mac);

/**
 * ����API, �����رպ��ƶ����Ӳ��ͷ���Դ��
 */
PYUNAPIDLL_API int __stdcall PYunAPIDestroy();

/**
 * ��ȡSDK�汾��
 */
PYUNAPIDLL_API char * __stdcall PYunAPIVersion();

/**
 * ��`src`������ͨ��memcpy��`dst`
 */
PYUNAPIDLL_API int __stdcall PYunAPIMemcpy(char *src, char *dst);

/**
 * ����input�ַ���MD5ֵ
 */
PYUNAPIDLL_API int __stdcall PYunAPICryptoMD5(char *input, char *output);

/**
 * ����input�ַ���CRC16ֵ
 */
PYUNAPIDLL_API int __stdcall PYunAPICryptoCRC(char *input, char *output, int algorithm);

/**
 * ��ȡSDK API�ȼ�
 */
PYUNAPIDLL_API int __stdcall PYunAPILevel();