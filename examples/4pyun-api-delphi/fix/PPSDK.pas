unit PPSDK;


interface

CONST
  PYUNAPI_OPT_IDLE_TIME =$ffff;   //TCP心跳间隔时间,单位msint 300000
  PYUNAPI_OPT_READ_KEY  =$fffe;   //读数据密钥string -
  PYUNAPI_OPT_WRITE_KEY =$fffd;   //写数据密钥string -
  PYUNAPI_OPT_AUTH_TIME =$fffc;   //认证超时时间,单位msint 20000
  PYUNAPI_OPT_LOGGER    =$fffb;   //指定API日志文件路径string ./4pyunapi.log
  PYUNAPI_OPT_CHARSET   =$fffa;   //开发编码设置string UTF-8
  PYUNAPI_OPT_DEV_MODE  =$fff9;   //开发者模式: 1是, 0否int 0
  PYUNAPI_OPT_DEVICE    =$fff8;   //多设备模式下设置当前设备ID
  PYUNAPI_OPT_VENDOR    =$fff5;   //当前设备供应商

 type
    //event_type 参考 `PYUNAPI_EVENT_*` 的定义。* msg 针对目前event_type的描述说明。
    TPYunAPIEventCallback  = procedure(event_type:Integer; Pmsg:PChar); stdcall;

    //* seqno 请求序号, 需原样返回 * payload 请求JSON数据
    TPYunAPIRequestCallback= Function (seqno:Integer;  payload :PChar) :Integer; stdcall;

 // 1.1 设置事件拦截回调函数
 Procedure PYunAPIHookEvent  (PYunAPIEventCallback  :TPYunAPIEventCallback   );stdcall;external '4pyun-api.dll';  //回调

 // 1.2 拦截请求回调
 Procedure PYunAPIHookRequest(PYunAPIRequestCallback:TPYunAPIRequestCallback ); stdcall; external '4pyun-api.dll';  //回调

 // 1.3 设置可选项
 Function PYunAPISetOpt( optname : Integer;  optval :Pointer): Integer; stdcall; external '4pyun-api.dll';

 //2. 启动API, 底层会开启线程和云端保持TCP长连接
{
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
}
 Function  PYunAPIStart( phost :Pchar;  port :Integer;  ptype:Pchar; uuid:Pchar ; psign_mac :Pchar) : Integer; stdcall; external '4pyun-api.dll';

 //当程序关闭时调用该方法可以主动关闭和云端链接并释放资源。
 procedure PYunAPIDestroy(); stdcall; external '4pyun-api.dll';


 //发送请求结果响应
 Function PYunAPIReply( seqno :Integer; payload :Pchar) : Integer; stdcall; external '4pyun-api.dll';

implementation



end.
