unit PPDemo_Unt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,  PPSDK ,  superobject ,
  Dialogs, StdCtrls;

type
  TPPDemo_Frm = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure  PP_SumPayJE (CarNo, passport,gate_id :String ;seqno:Integer)  ;
    procedure  PP_PayFinish(Pmag  :String  )  ;
  public
    { Public declarations }
  end;
  procedure  PYunAPIEventCallback   (event_type:Integer; Pmsg:PChar); stdcall;
  Function   PYunAPIRequestCallback (seqno:Integer; payload :PChar):Integer; stdcall;
var
  PPDemo_Frm: TPPDemo_Frm;

     //cdecl

implementation

{$R *.dfm}

//事件拦截
procedure  PYunAPIEventCallback(event_type:Integer; Pmsg:PChar); stdcall;
begin
  case event_type of
      1: PPDemo_Frm.Memo1.Lines.Add('---API授权成功');
     -1: PPDemo_Frm.Memo1.Lines.Add('---API授权失败');
     -2: PPDemo_Frm.Memo1.Lines.Add('---TCP连接异常');
     -3: PPDemo_Frm.Memo1.Lines.Add('---TCP链接关闭');
  end;
end;


// 出口扫码支付(有牌、无牌)、 场内预支付、无牌车入场
//拦截请求回调
Function  PYunAPIRequestCallback (seqno:Integer; payload :PChar):Integer; stdcall;
var
  jorec   :ISuperObject;
  service ,Pmsg :String;
  CarNo  ,passport  ,gate_id  :String;
begin
  Pmsg    :=String(payload) ;
  jorec   :=so(Pmsg);
  service :=jorec['service'].AsString;
  if service='service.parking.payment.billing' then //查询收费金额
  begin
     PPDemo_Frm.Memo1.Lines.Add('PP推送查询订单：序号='+IntToStr(seqno)+' 内容='+Pmsg);
     CarNo     :=jorec['plate'].AsString;      //场内付车牌号码
     passport  :=jorec['passport'].AsString;   //用户通行证ID, 无牌车传入
     gate_id   :=jorec['gate_id'].AsString;    //有牌、无牌车出口直付
     {
     1、场内预支付  ：plate为车牌号码   ,passport、gate_id为空
     2、有牌出口直付：plate为车牌号码   ,passport为空，gate_id为付款通道   , 还是要把那个车的车牌返回来
     3、无牌出口直付：passport通行证ID  ,plate为空   ，gate_id为付款通道
     }
     PPDemo_Frm.PP_SumPayJE(CarNo,passport,gate_id ,seqno);
  end;
  if service='service.parking.payment.result' then //订单支付结果通知收费系统
  begin
     PPDemo_Frm.Memo1.Lines.Add('PP推送支付成功: 序号='+IntToStr(seqno)+' 内容='+Pmsg);
     PPDemo_Frm.PP_PayFinish(Pmsg);
  end;

  
end;



//订单支付结果通知收费系统
procedure  TPPDemo_Frm.PP_PayFinish(Pmag  :String  )  ;
begin
  {
  gate_id":""  ,                              //通道编号ID, 付费时可传递触发开闸;
  parking_order":"TC20180731155256",          //停车支付订单号, 原客户端提交.
  parking_serial":"20180731155256",           //停车流水, 原客户端提交.
  pay_origin":"0",                            //0-PP停车  4-支付宝 8-微信
  pay_origin_desc":"PYun",                    //支付来源说明, 例如:PP停车
  pay_serial":"20180731155233075500218569",   //PP停车支付流水, 对账可用.
  pay_time":"20180731155246",                 //支付时间, 格式: yyyyMMddHHmmss .
  value":"1",                                 //支付金额(单位分) .
  }

end;



//查询收费金额
procedure  TPPDemo_Frm.PP_SumPayJE(CarNo , passport,gate_id:String ;seqno:Integer)  ;
var
  service,version ,charset ,result_code ,pmessage ,sign , plate ,parking_serial ,parking_order  ,enter_time ,card_id :String;
  parking_time ,total_value , free_value ,  paid_value  ,locking_status  ,pay_value  : Integer;
  jo    :ISuperObject;
  jostr :String;
  Ret   :Integer;
begin
{1001 订单获取成功, 业务参数将返回.
1002 未查询到停车信息.
1003 月卡车辆, 不允许支付.
1401 签名错误, 请检查配置.
1500 接口处理异常.
}
  
  service        :='service.parking.payment.billing' ;//服务名: service.parking.payment.billing
  version        :='1.0';                             //版本号: 1.0
  charset        :='UTF-8';                           //字符集: UTF‐8
  result_code    :='1001';                            //状态码:
  pmessage       :='订单获取成功, 业务参数将返回';    //状态码处理描述, 如:返回错误信息
  sign           :='';                                //签名
  plate          :=CarNo;                             //识别车牌号码
  card_id        :='';                                //无牌车获取订单返回本地的虚拟卡ID/虚拟车牌.
  parking_serial :=FormatDatetime('yyyymmddhhnnss',now);      //停车流水, 标识具体某次停车事件, 需保证该停车场下唯一.
  parking_order  :='TC'+FormatDatetime('yyyymmddhhnnss',now);     //停车支付订单号, 需保证该停车场下唯一.注:同一停车场内不可重复！
  enter_time     :=FormatDatetime('yyyymmddhhnnss',now);          //入场时间, 格式yyyyMMddHHmmss
  parking_time   :=3600;                           //停车时长(单位秒)
  total_value    :=1;                             //总停车费用(单位分), 为用户从入场到现在获取订单时的总费用.
  free_value     :=0;                             //已优惠金额(单位分), 为停车场在当前停车费用时已经给予的优惠金额, 如果包涵优惠时间则该值为则free_value填写该时间等价的优惠金额+其他有效优惠金额.
  paid_value     :=0;                             //已支付金额(单位分), 为当次停车用户已经支付的金额, 比如当用户先支付了一笔后, 超时未出场重新查询订单时须返回以支付金额.
  pay_value      :=1;                             //应支付金额(单位分), 这里停车场系统需处理如果结果为负数的情况直接返回无需支付.
  locking_status :=0;                             //锁车标识: 1已锁, 0未锁, 1不支持
 
  jo:=SO();
  jo.S['service']          :=service;
  jo.S['version']          :='1.0';
  jo.S['charset']          :='UTF-8';
  jo.S['result_code']      :=result_code;
  jo.S['message']          :=pmessage;
  jo.S['sign']             :=sign;
  jo.S['plate']            :=CarNo;
  jo.S['card_id']          :=card_id;
  jo.S['parking_serial']   :=parking_serial;
  jo.S['parking_order']    :=parking_order;
  jo.S['enter_time']       :=enter_time;
  jo.I['parking_time']     :=parking_time;
  jo.I['total_value']      :=total_value;
  jo.I['free_value']       :=free_value;
  jo.I['paid_value']       :=paid_value;
  jo.I['pay_value']        :=pay_value;
  jo.I['locking_status']   :=locking_status;
  jostr   :=jo.AsString;

  Ret :=PYunAPIReply(seqno ,Pchar(jostr) );
  if Ret=0 then
     PPDemo_Frm.Memo1.Lines.Add('收费返回订单成功:序号='+IntToStr(seqno)+' 内容='+jostr)
  else
     PPDemo_Frm.Memo1.Lines.Add('收费返回订单失败:序号='+IntToStr(seqno)+' 内容='+jostr);

end;


procedure TPPDemo_Frm.Button1Click(Sender: TObject);
var
  phost ,ptype ,uuid  ,psign_mac :Pchar;
  port : Integer;
  iRet : Integer;
  A : Integer ;
  ExeFile :String;

begin
   
  ExeFile := ExtractFilepath(application.exename);


  // 1.1 设置事件拦截回调函数
  PYunAPIHookEvent(@PYunAPIEventCallback);
  // 1.2 拦截请求回调
  PYunAPIHookRequest(@PYunAPIRequestCallback);

	// 1.3 设置可选项
	// [必须]设置当前项目工程编码, 底层默认UTF-8编码
 	iRet :=PYunAPISetOpt(PYUNAPI_OPT_CHARSET,   PCHAR('GBK')  );
  if iRet=0 then
     Memo1.Lines.Add('---开发编码设置=GBK成功')
  else
     Memo1.Lines.Add('---开发编码设置=GBK识别失败');

   // [可选]激活开发者模式, 默认在当前执行目录生成日志文件  开发者模式: 1是, 0否
  A:=1;
  iRet :=PYunAPISetOpt(PYUNAPI_OPT_DEV_MODE,   @A);
  if iRet=0 then
     Memo1.Lines.Add('---激活开发者模式设置成功')
  else
     Memo1.Lines.Add('---激活开发者模式设置失败');

  {
	// [可选]设置心跳间隔时间, ms
	PYunAPISetOpt(PYUNAPI_OPT_IDLE_TIME,  (void *)&idle_time);
	// [可选]设置授权超时时间, ms
	PYunAPISetOpt(PYUNAPI_OPT_AUTH_TIME,  (void *)&auth_time);}

	// [可选]设置日志文件
	iRet :=PYunAPISetOpt(PYUNAPI_OPT_LOGGER,     PCHAR(ExeFile+'MY.log')  );
  if iRet=0 then
     Memo1.Lines.Add('---设置日志文件成功='+ExeFile+'MY.log' )
  else
     Memo1.Lines.Add('---设置日志文件失败');

  // 2. 启动API, 底层会开启线程和云端保持TCP长连接
  phost    :='sandbox.gate.4pyun.com';                 //云平台域名
  port     :=8661;                                      //云平台端口
  ptype    :='public:parking:agent';                    //客户端类型
  uuid     :='2adf6966-1c06-4e09-91ea-354ffc7df916';    //客户端UUID, 一个UUID只能运行一个实例
  psign_mac:='XGbVfP1oC21UHkwn';                        //接口通信JSON签名计算密钥
  iRet :=PYunAPIStart( phost ,port ,ptype,uuid,psign_mac );
  if iRet=0 then
     Memo1.Lines.Add('---启动API成功')
  else
     Memo1.Lines.Add('---启动API失败')
end;

procedure TPPDemo_Frm.Button2Click(Sender: TObject);
begin
  PYunAPIDestroy;
end;

procedure TPPDemo_Frm.FormShow(Sender: TObject);
begin
  Button1Click(self);
end;

end.




