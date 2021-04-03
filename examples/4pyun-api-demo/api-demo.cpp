// api-demo.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include "4pyun-api.h"
#include <windows.h>

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
	char *reply = "{\"charset\":\"UTF-8\",\"result_code\":\"1002\",\"service\":\"service.parking.payment.billing\",\"version\":\"1.0\"}";
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
//	char *host = "10.211.55.2";
	unsigned int port = 8661;
	char *type = "public:parking:agent";
	char *uuid = "49f0cc52-e8c7-41e3-b54d-af666b8cc11a";
	char *sign_mac = "123";
	char *device = "A,B,C";
	// 当前对接系统供应商标识, 由P云分配并写死在代码中!
	char *vendor = "4PY2UN";
	// 当前主机名称, 多设备连接用于区分主机
	char *hostname = "PC-1";
	// 当前主机本地IP, 多设备连接用于区分主机
	char *host_address = "192.168.6.99";
	// 计算设备硬件指纹, 防止参数滥用。
	char *fingerprint = "ABCD";

	char *version = PYunAPIVersion();
	printf("SDK_VER: %s\n", version);
	
	getchar();

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

	char dest[2048] = {0};
	PYunAPIMemcpy("Hello", dest);
	printf("Memcpy: %s\n", dest);
	
	getchar();

	// 1.1 设置事件拦截回调函数
	PYunAPIHookEvent(PYunAPIEventCallback);
	// 1.2 拦截请求回调
	PYunAPIHookRequest(PYunAPIRequestCallback);

	do {
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
	//PYunAPISetOpt(PYUNAPI_OPT_LOGGER, (void *)"C:/4pyun-api.log");
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

	char *input = "balance_value=0&car_desc=临时卡A&car_type=1&cash_value=100&enter_gate=XPC入口1&enter_security=0001&enter_time=1584950193000&free_value=0&leave_gate=XPC出口2&leave_image_base64=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&leave_security=0001&leave_time=1584950541000&online_value=0&park_uuid=31899eda-0433-4b2e-a57e-fd5d33bf1fd0&parking_serial=P0000416200323155633&plate=粤XXXXXX&plate_color=-1&prepaid_value=0&total_value=100&vehicle_type=1&app_secrect=ABCD";
	char *hash = (char *) malloc(33);
	PYunAPICryptoMD5(input, hash);

	printf("MD5: %s\n", hash);

	getchar();
	// 3. 销毁API, 断开TCP长连接
	PYunAPIDestroy();

	getchar();
	} while (true);

	return 0;
}

