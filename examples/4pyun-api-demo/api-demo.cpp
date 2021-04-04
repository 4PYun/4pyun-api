// api-demo.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include "4pyun-api.h"
#include <windows.h>
#include <time.h>

/**
 * API事件回调函数实现
 */
void __stdcall PYunAPIEventCallback(int event_type, char *msg){  
	switch (event_type) {
		case PYUNAPI_EVENT_ACCESS_GRANTED:
			printf("\nAccessGranted %s\n\n", msg == NULL ? "" : msg);
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
}

int __stdcall PYunAPIRequestCallback(int seqno, char *payload) {
    // 根据JSON中的service判断是否处理, 如果没处理将ret设置为-1。
	int ret = 0;

	printf("RECV: %d, %s\n", seqno, payload);
	char *reply = "{\"charset\":\"UTF-8\",\"result_code\":\"1002\",\"message\":\"消息内容\",\"key1\":\"value1\",\"key2\":\"value2\",\"service\":\"service.parking.payment.billing\",\"version\":\"1.0\"}";
	//Sleep(3000);
	// Reply的时候必须原样返回seqno!
	PYunAPIReply(seqno, reply);
	return ret;
}

int _tmain(int argc, _TCHAR* argv[])
{
	int idle_time = 1000 * 1;
	int auth_time = 1000 * 30;
	int dev_mode = 1;
	char *host = "sandbox.gate.4pyun.com";

	unsigned int port = 8661;
	char *type = "public:parking:agent";
	char *uuid = "49f0cc52-e8c7-41e3-b54d-af666b8cc11a";
	char *sign_mac = "123";
	char *device = "A,B,C";
	// 当前对接系统供应商标识, 由P云分配并写死在代码中!
	char *vendor = "PYUN";
	// 当前主机名称, 多设备连接用于区分主机
	char *hostname = "PC-1";
	// 当前主机本地IP, 多设备连接用于区分主机
	char *host_address = "192.168.6.99";
	// 计算设备硬件指纹, 防止参数滥用。
	char *fingerprint = "ABCD";

	char *version = PYunAPIVersion();
	printf("SDK_VER: %s\n", version);
	getchar();

	// !!!!!!!获取SDK API等级, 必须执行这个步骤!!!!!!!
	int sdk_level = PYunAPILevel();
	printf("SDK_LEVEL: %d\n", sdk_level);
	getchar();
	if (sdk_level < 10) {
		// 过低的SDK版本
		return -1;
	}

	// 243264PEIT6SHEOB8IC8GI => 13571,3503
	char dest2[2048] = {0};
	char *input = "243264PEIT6SHEOB8IC8GI";
	printf("CRC CALC INPUT=%s\n", input);
	printf("###########################\n");
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_ARC);
	printf("CRC16_ARC        : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_MODBUS);
	printf("CRC16_MODBUS     : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_USB);
	printf("CRC16_USB        : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_DNP);
	printf("CRC16_DNP        : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_CCCT_FALSE);
	printf("CRC16_CCCT_FALSE : %s\n", dest2);
	PYunAPICryptoCRC(input, dest2, PYUNAPI_CRYPTO_CRC16_XMODEM);
	printf("CRC16_XMODEM     : %s\n", dest2);
	getchar();

	// TEST MEMCPY
	char dest[2048] = {0};
	PYunAPIMemcpy("Hello", dest);
	printf("Memcpy: %s\n", dest);
	getchar();
	
	// TEST MD5...
	input = "中文ABC123";
	char *hash = (char *) malloc(33);
	PYunAPICryptoMD5(input, hash);
	printf("MD5: %s\n", hash);
	getchar();

	// 1.1 设置事件拦截回调函数
	PYunAPIHookEvent(PYunAPIEventCallback);
	// 1.2 拦截请求回调
	PYunAPIHookRequest(PYunAPIRequestCallback);

	do {
		// 取当前日期生成日志文件名称, SDK底层不会自动分割日志文件，建议上层应用每天设置新的日志文件名称
		char time_buf[26];
		time_t timer = time(0);
		strftime(time_buf, 26, "%Y%m%d", localtime(&timer));
		char logger_file_name[128] = { 0 };
		sprintf(logger_file_name, "C://logs/4pyun-api.%s.log", time_buf);
		printf("LOG_FILE: %s\n", logger_file_name);

		// 1.3 设置可选项
		// [必须]设置当前项目工程编码, 底层默认UTF-8编码
		PYunAPISetOpt(PYUNAPI_OPT_CHARSET,   (void *)"GBK");
		// [可选]激活开发者模式, 默认在当前执行目录生成日志文件
		PYunAPISetOpt(PYUNAPI_OPT_DEV_MODE,   (void *)&dev_mode);

		printf("DEV_MODE: %d\n", PYunAPIGetOpt(PYUNAPI_OPT_DEV_MODE));

		// [可选]设置心跳间隔时间, ms
	//	PYunAPISetOpt(PYUNAPI_OPT_IDLE_TIME, (void *)&idle_time);
		// [可选]设置授权超时时间, ms
		PYunAPISetOpt(PYUNAPI_OPT_AUTH_TIME, (void *)&auth_time);
		// [可选]设置日志文件
		PYunAPISetOpt(PYUNAPI_OPT_LOGGER, (void *)&logger_file_name);
		// [可选]设置设备ID, 仅在多终端模式下设置
		PYunAPISetOpt(PYUNAPI_OPT_DEVICE, (void *)device);
		// [可选]设置当前对接系统供应商标识, 由P云分配并写死在代码中
		PYunAPISetOpt(PYUNAPI_OPT_VENDOR, (void *)vendor);
		// [可选]设置计算设备硬件指纹, 防止参数滥用。
		PYunAPISetOpt(PYUNAPI_OPT_FINGERPRINT, (void *)fingerprint);
		// [可选]设置当前本地主机名称
		PYunAPISetOpt(PYUNAPI_OPT_HOST_NAME, (void *)hostname);
		// [可选]设置当前本地主机IP
		PYunAPISetOpt(PYUNAPI_OPT_HOST_ADDR, (void *)host_address);

		// 2. 启动API, 底层会开启线程和云端保持TCP长连接
		PYunAPIStart(host, port, type, uuid, sign_mac);

		getchar();
		// 3. 销毁API, 断开TCP长连接
		PYunAPIDestroy();
	} while (true);

	return 0;
}

