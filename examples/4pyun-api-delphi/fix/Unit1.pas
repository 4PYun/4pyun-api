unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;




CONST

  WM_PP_OrderNo    = WM_USER+109;  //PP查询订单


//PP查询订单
type
  TPP_OrderNo = Packed  Record
      CarNo     : String;    //车牌号码
      passport  : String;    //用户通行证ID, 无牌车传入
      gate_id   : String;    //有牌、无牌车出口直付开闸通道
      seqno     : Integer;   //指令序号
end;
pPP_OrderNo = ^TPP_OrderNo;  //定义结构体指针.



type
  TForm1 = class(TForm)
  private
    { Private declarations }

    procedure  MyMsg_PP_OrderNo (var  msg:TMSG);message  WM_PP_OrderNo;  //PP查询订单


  public
    { Public declarations }
  end;


  procedure  ReceiveDataCallBackProc(strJsonData:PChar); stdcall;
  procedure  PYunAPIEventCallback   (event_type:Integer; Pmsg:PChar); stdcall;
  Function   PYunAPIRequestCallback (seqno:Integer; payload :PChar):Integer; stdcall;


var
  Form1: TForm1;

implementation

{$R *.dfm}


//无需处理
procedure  PfSerialDataCallBack (lSerialHandle: Longint;
                                pRecvDataBuffer: PChar;
                                dwBufSize: Longword;
                                dwUser: Longint );stdcall;
begin

end;


//pp事件拦截 ，仅仅记录
procedure  PYunAPIEventCallback(event_type:Integer; Pmsg:PChar); stdcall;
begin

end;


// pp出口扫码支付(有牌、无牌)、 场内预支付、无牌车入场
//拦截请求回调
Function  PYunAPIRequestCallback (seqno:Integer; payload :PChar):Integer; stdcall;
var
  jorec   :ISuperObject;
  service ,Pmsg   :String;

  pPPOrderNo:pPP_OrderNo ;
begin
  Pmsg    :=String(payload) ;
  jorec   :=so(Pmsg);
  try
      service :=jorec['service'].AsString;  //服务名称

      if service='service.parking.payment.billing' then //查询收费金额
      begin
         plate    :='';
         passport :='';
         gate_id  :='';
         new(pPPOrderNo);
         pPPOrderNo.CarNo       :=plate;       //车牌号码
         pPPOrderNo.passport    :=passport;
         pPPOrderNo.gate_id     :=gate_id;
         pPPOrderNo.seqno       :=seqno;
         //上抛给系统处理 ，非常重要!!!!
         postmessage(Form1.handle,WM_PP_OrderNo, 0, LPARAM( pPPOrderNo) );
      end;
  except
      Exit;
  end;
end;



procedure  TForm1.MyMsg_PP_OrderNo (var  msg:TMSG);   //PP查询订单
var
   pPPOrderNo:pPP_OrderNo ;
begin
   pPPOrderNo := pPP_OrderNo(Msg.wParam);
   try
      CarNo     :=pPPOrderNo^.CarNo ;      //车牌号码
      passport  :=pPPOrderNo^.passport;    //用户通行证ID, 无牌车传入
      gate_id   :=pPPOrderNo^.gate_id;    //有牌、无牌车出口直付开闸通道
      seqno     :=pPPOrderNo^.seqno;      //指令序号
      //自己处理查询订单......... !!!!!
   finally
      Dispose(pPPOrderNo);
   end;

end;



end.
