Attribute VB_Name = "main"
'初始化API
Public Declare Function PYunAPIStart Lib "4pyun-api.dll" (ByVal host As String, ByVal port As Long, ByVal cType As String, ByVal uuid As String, ByVal sign_mac As String) As Long
'销毁API
Public Declare Function PYunAPIDestroy Lib "4pyun-api.dll" () As Integer
'选项设置
Public Declare Function PYunAPISetOpt Lib "4pyun-api.dll" (ByVal optname As Long, ByVal optval As Any) As Long
'发送请求结果响应
Public Declare Function PYunAPIReply Lib "4pyun-api.dll" (ByVal seqno As Long, ByVal payload As Long) As Long
'获取API版本
Public Declare Function PYunAPIVersion Lib "4pyun-api.dll" () As String
'Memcpy
Public Declare Function PYunAPIMemcpy Lib "4pyun-api.dll" (ByVal src As Long, ByVal dst As Long) As Integer
'事件拦截
Public Declare Sub PYunAPIHookEvent Lib "4pyun-api.dll" (ByVal lpProc As Long)
'拦截请求回调
Public Declare Sub PYunAPIHookRequest Lib "4pyun-api.dll" (ByVal lpProc As Long)
Public Const PYUNAPI_OPT_IDLE_TIME  As Long = &HFFFF&  'TCP心跳间隔时间, 单位ms int 300000
Public Const PYUNAPI_OPT_AUTH_TIME As Long = &HFFFC&  '认证超时时间, 单位ms    int 20000
Public Const PYUNAPI_OPT_LOGGER As Long = &HFFFB&  '指定API日志文件路径 string  ./4pyun-api.log
Public Const PYUNAPI_OPT_CHARSET As Long = &HFFFA& '开发编码设置    string  UTF-8
Public Const PYUNAPI_OPT_DEV_MODE As Long = &HFFF9& '开发者模式: 1是, 0否    int 0
Public Const PYUNAPI_OPT_DEVICE As Long = &HFFF8&
Public Const PYUNAPI_OPT_SINGLE_THREAD As Long = &HFFF3&

''' WinApi function that maps a UTF-16 (wide character) string to a new character string
#If VBA7 Then
Private Declare PtrSafe Function WideCharToMultiByte Lib "kernel32" ( _
    ByVal CodePage As Long, _
    ByVal dwFlags As Long, _
    ByVal lpWideCharStr As LongPtr, _
    ByVal cchWideChar As Long, _
    ByVal lpMultiByteStr As LongPtr, _
    ByVal cbMultiByte As Long, _
    ByVal lpDefaultChar As Long, _
    ByVal lpUsedDefaultChar As Long _
    ) As Long
#Else
Private Declare Function WideCharToMultiByte Lib "kernel32" ( _
    ByVal CodePage As Long, _
    ByVal dwFlags As Long, _
    ByVal lpWideCharStr As Long, _
    ByVal cchWideChar As Long, _
    ByVal lpMultiByteStr As Long, _
    ByVal cbMultiByte As Long, _
    ByVal lpDefaultChar As Long, _
    ByVal lpUsedDefaultChar As Long _
    ) As Long
#End If

''' Maps a character string to a UTF-16 (wide character) string
Private Declare Function MultiByteToWideChar Lib "kernel32" ( _
    ByVal CodePage As Long, _
    ByVal dwFlags As Long, _
    ByVal lpMultiByteStr As Long, _
    ByVal cchMultiByte As Long, _
    ByVal lpWideCharStr As Long, _
    ByVal cchWideChar As Long _
    ) As Long

' CodePage constant for UTF-8
Private Const CP_UTF8 = 65001

''' Return length of byte array or zero if uninitialized
Private Function BytesLength(abBytes() As Byte) As Long
    ' Trap error if array is uninitialized
    On Error Resume Next
    BytesLength = UBound(abBytes) - LBound(abBytes) + 1
End Function

''' Return VBA "Unicode" string from byte array encoded in UTF-8
Public Function Utf8BytesToString(abUtf8Array() As Byte) As String
    Dim nBytes As Long
    Dim nChars As Long
    Dim strOut As String
    Utf8BytesToString = ""
    ' Catch uninitialized input array
    nBytes = BytesLength(abUtf8Array)
    If nBytes <= 0 Then Exit Function
    ' Get number of characters in output string
    nChars = MultiByteToWideChar(CP_UTF8, 0&, VarPtr(abUtf8Array(0)), nBytes, 0&, 0&)
    ' Dimension output buffer to receive string
    strOut = String(nChars, 0)
    nChars = MultiByteToWideChar(CP_UTF8, 0&, VarPtr(abUtf8Array(0)), nBytes, StrPtr(strOut), nChars)
    Utf8BytesToString = Left$(strOut, nChars)
End Function

''' Return byte array with VBA "Unicode" string encoded in UTF-8
Public Function Utf8BytesFromString(strInput As String) As Byte()
    Dim nBytes As Long
    Dim abBuffer() As Byte
    ' Catch empty or null input string
    Utf8BytesFromString = vbNullString
    If Len(strInput) < 1 Then Exit Function
    ' Get length in bytes *including* terminating null
    nBytes = WideCharToMultiByte(CP_UTF8, 0&, ByVal StrPtr(strInput), -1, 0&, 0&, 0&, 0&)
    ' We don't want the terminating null in our byte array, so ask for `nBytes-1` bytes
    ReDim abBuffer(nBytes - 2)  ' NB ReDim with one less byte than you need
    nBytes = WideCharToMultiByte(CP_UTF8, 0&, ByVal StrPtr(strInput), -1, ByVal VarPtr(abBuffer(0)), nBytes - 1, 0&, 0&)
    Utf8BytesFromString = abBuffer
End Function


'事件拦截
Public Sub ApiEventCallback2(ByVal event_type As Long, ByVal pMsg As Long)
    
    Dim buf(2048) As Byte
    If pMsg > 0 Then PYunAPIMemcpy pMsg, VarPtr(buf(0))
    Dim msg As String
    msg = Utf8BytesToString(buf)
    
   Select Case event_type
      Case 1 'API授权成功
         SaveSetting "park", "pplink", "stauts", "0-" + msg
      Case -1 'API授权拒绝
         SaveSetting "park", "pplink", "stauts", "1-" + msg
      Case -2 'TCP连接异常
         SaveSetting "park", "pplink", "stauts", "2-" + msg
      Case -3 'TCP连接关闭
         SaveSetting "park", "pplink", "stauts", "3-" + msg
   End Select
End Sub
'接受数据回调
Public Function ApiRequestCallBack(ByVal seqno As Long, ByVal pPayload As Long) As Long
    
    Dim buf(20480) As Byte
    If pPayload > 0 Then PYunAPIMemcpy pPayload, VarPtr(buf(0))
    Dim msg As String
    msg = Utf8BytesToString(buf)
    
    SaveSetting "park", "pplink", "stauts", "[<][" + CStr(seqno) + "]- " + msg
    
    Dim reply() As Byte
    
    Dim jsonReply As String
    jsonReply = "{'service':'service.parking.detail','version':'1.0','charset':'UTF-8','result_code':'1001','message':'处理OK','sign':'722059C5CC1B3FF5CDF8F8A4CF3B31CC'}"
    reply = Utf8BytesFromString(jsonReply)
    PYunAPIReply seqno, VarPtr(reply(0))

    SaveSetting "park", "pplink", "stauts", "[>][" + CStr(seqno) + "]- " + msg

End Function
Public Function GetFuncPtr(ByVal Ptr As Long) As Long
  GetFuncPtr = Ptr
End Function
