VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   5175
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   8685
   LinkTopic       =   "Form1"
   ScaleHeight     =   5175
   ScaleWidth      =   8685
   StartUpPosition =   3  '窗口缺省
   Begin VB.CommandButton Command3 
      Caption         =   "SDK版本"
      Height          =   615
      Left            =   7080
      TabIndex        =   3
      Top             =   2160
      Width           =   1455
   End
   Begin VB.CommandButton Command2 
      Caption         =   "注销"
      Height          =   615
      Left            =   7080
      TabIndex        =   2
      Top             =   1200
      Width           =   1455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "启动"
      Height          =   615
      Left            =   7080
      TabIndex        =   1
      Top             =   240
      Width           =   1455
   End
   Begin VB.Timer Timer1 
      Interval        =   1000
      Left            =   6450
      Top             =   1920
   End
   Begin VB.ListBox List1 
      Height          =   4560
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   6495
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()
  Dim mLpProc As Long
  Dim mDevMode As Long  ' = 0;
  Dim mSingleThread As Long  ' = 0;
  Dim mHost As String  ' = "sandbox.gate.4pyun.com";
  Dim mPort As Long  ' = 8661;
  Dim cType As String  ' = "public:parking:agent";
  Dim mUuid As String  ' "49f0cc52-e8c7-41e3-b54d-af666b8cc11a";
  Dim mSignMac As String  ' "22D42dSdae2";
  mDevMode = 1
  mSingleThread = 0
  mHost = "sandbox.gate.4pyun.com"
  mPort = 8661
  cType = "public:parking:agent"
  mUuid = "49f0cc52-e8c7-41e3-b54d-af666b8cc11a"
  mSignMac = "22D42dSdae"
  '==1.1 设置事件拦截回调函数
'  SaveSetting "park", "pplink", "stauts", ""
  mLpProc = GetFuncPtr(AddressOf ApiEventCallback2)
  PYunAPIHookEvent mLpProc
'  SaveSetting "park", "pplink", "stauts", ""
  '==1.2 拦截请求回调
  mLpProc = GetFuncPtr(AddressOf ApiRequestCallBack)
  PYunAPIHookRequest mLpProc
'
  '==  1.3 设置可选项
  '// [可选]激活开发者模式, 默认在当前执行目录生成日志文件
  PYunAPISetOpt PYUNAPI_OPT_DEV_MODE, VarPtr(mDevMode)
  ' 设置单线程工作模式
  PYunAPISetOpt PYUNAPI_OPT_SINGLE_THREAD, VarPtr(mSingleThread)
  '/ [必须]设置当前项目工程编码, 底层默认UTF-8编码
  ' VB中直接自己处理UTF8转宽字节
  '// [可选]设置日志文件
  PYunAPISetOpt PYUNAPI_OPT_LOGGER, App.Path + "/logapi.log"
  
  '// 2. 启动API, 底层会开启线程和云端保持TCP长连接
  PYunAPIStart Trim(mHost), mPort, Trim(cType), Trim(mUuid), Trim(mSignMac)
  
End Sub

Private Sub Command2_Click()
  PYunAPIDestroy
End Sub

Private Sub Command3_Click()
  MsgBox PYunAPIVersion
End Sub

Private Sub Form_Load()
  
  '=
  '
End Sub

Private Sub Timer1_Timer()
  If GetSetting("park", "pplink", "stauts", "") = "" Then Exit Sub
  List1.AddItem GetSetting("park", "pplink", "stauts", "")
  SaveSetting "park", "pplink", "stauts", ""
End Sub
