.386
.model flat, stdcall
option casemap:none

includelib      msvcrt.lib
include         windows.inc
include         kernel32.inc
includelib      kernel32.lib
include         user32.inc
includelib      user32.lib
sprintf         PROTO C: PTR BYTE, :PTR BYTE, :vararg
fopen           PROTO C :PTR BYTE, :PTR BYTE
fclose          PROTO C :DWORD
fgets           PROTO C :PTR BYTE, :DWORD, :DWORD
strlen          PROTO C :PTR BYTE
strcmp          PROTO C :PTR BYTE, :PTR BYTE
strcat          PROTO C :PTR BYTE, :PTR BYTE

.data
BUF_SIZE        EQU     1024
MAX_FPATH       EQU     512
hInstance       DWORD   ?
hWindow         DWORD   ?
hEdit1          DWORD   ?
hEdit2          DWORD   ?
hEdit3			DWORD	?
filePath1       BYTE    MAX_FPATH DUP(0)
filePath2       BYTE    MAX_FPATH DUP(0)
buf1            BYTE    BUF_SIZE DUP(0)
buf2            BYTE    BUF_SIZE DUP(0)
buf3            BYTE    1124 DUP(0)

.const
szClassName     BYTE    "compWindow", 0
szTopText		BYTE	"Please input file A path and file B path", 0
szWindowName    BYTE    "File Comparator", 0
szEdit1Text		BYTE	"FileA Path:", 0
szEdit2Text		BYTE	"FileB Path:", 0
szMBoxName      BYTE    "Compare Result", 0
szButton        BYTE    "button", 0
szEdit          BYTE    "edit", 0
szButtonText    BYTE    "Compare", 0

FmtFNFStr       BYTE    "File '%s' not found.", 0
FmtLineNEqu     BYTE    "Line %d not equ.", 0DH, 0AH, 0
.code
; 类似fgets，但当没有读取到任何字符时将buf清0
fgets_s         PROC C USES ECX ESI, buf :PTR BYTE, fp :DWORD
    INVOKE      fgets, buf, BUF_SIZE, fp
    .IF EAX == 0
    MOV         ECX, BUF_SIZE
    MOV         ESI, buf
    SetZero:
    MOV         BYTE PTR [ESI], 0
    INC         ESI
    LOOP        SetZero
    .ENDIF
    RET
fgets_s         ENDP

; 文件比较，参数为两个文件路径字符串的指针，比较结果输出在Edit3
comp            PROC C USES EAX, f1Path :PTR BYTE, f2Path :PTR BYTE
    LOCAL       fp1 :DWORD, fp2 :DWORD, openMode[3] :BYTE
    LOCAL       lineCount :DWORD, f1NEndFlag :DWORD, f2NEndFlag :DWORD
    LOCAL       lineNEquFlag :DWORD, line1Len :DWORD, line2Len :DWORD
    MOV         openMode[0], 'r'
    MOV         openMode[1], 'b'
    MOV         openMode[2], 0

    INVOKE      fopen, f1Path, ADDR openMode
    .IF         EAX == 0
    INVOKE      sprintf, OFFSET buf3, OFFSET FmtFNFStr, f1Path
    INVOKE      SetWindowText, hEdit3, OFFSET buf3
    RET
    .ENDIF
    MOV         fp1, EAX
    INVOKE      fopen, f2Path, ADDR openMode
    .IF         EAX == 0
    INVOKE      sprintf, OFFSET buf3, OFFSET FmtFNFStr, f2Path
    INVOKE      SetWindowText, hEdit3, OFFSET buf3
    INVOKE      fclose, fp1
    RET
    .ENDIF
    MOV         fp2, EAX

    MOV         f1NEndFlag, 1
    MOV         f2NEndFlag, 1
    MOV         lineCount, 0
    .WHILE f1NEndFlag != 0 || f2NEndFlag != 0
    INC         lineCount
    MOV         lineNEquFlag, 0
    .REPEAT
    INVOKE      fgets_s, OFFSET buf1, fp1
    MOV         f1NEndFlag, EAX
    INVOKE      strlen, OFFSET buf1
    MOV         line1Len, EAX
    INVOKE      fgets_s, OFFSET buf2, fp2
    MOV         f2NEndFlag, EAX
    INVOKE      strlen, OFFSET buf2
    MOV         line2Len, EAX
    INVOKE      strcmp, OFFSET buf1, OFFSET buf2
    OR          lineNEquFlag, EAX
    .UNTIL      line1Len != BUF_SIZE - 1 && line2Len != BUF_SIZE - 1
    .IF         lineNEquFlag != 0
    INVOKE      sprintf, OFFSET buf3[1024], OFFSET FmtLineNEqu, lineCount
    INVOKE      strcat, OFFSET buf3, OFFSET OFFSET buf3[1024]
    INVOKE      SetWindowText, hEdit3, OFFSET buf3
    .ENDIF
    .ENDW

    INVOKE      fclose, fp2
    INVOKE      fclose, fp1
    RET
comp            ENDP

_ProcWindow     PROC C USES EBX EDI ESI, hWnd, uMsg, wParam, lParam
    LOCAL       @stPaintStruct :PAINTSTRUCT
    LOCAL       @stRect :RECT
	LOCAL		@hDc

    MOV         EAX, uMsg
    .IF         EAX == WM_PAINT
    INVOKE      BeginPaint, hWnd, ADDR @stPaintStruct
	MOV			@hDc, EAX
	INVOKE		GetClientRect, hWnd, ADDR @stRect
	INVOKE		DrawText, @hDc, OFFSET szTopText, -1, ADDR @stRect, \   ; 在窗口上方绘制文本
					DT_SINGLELINE OR DT_CENTER OR DT_TOP
    INVOKE      EndPaint, hWnd, ADDR @stPaintStruct
    .ELSEIF     EAX == WM_CREATE
    INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; 创建按钮组件
                    OFFSET szButtonText, WS_CHILD OR WS_VISIBLE, \
                    240, 100, 80, 25, hWnd, 401H, hInstance, NULL
    INVOKE      CreateWindowEx, WS_EX_CLIENTEDGE, OFFSET szEdit, NULL, \; 创建单行文本编辑组件
                    WS_CHILD OR WS_VISIBLE OR WS_BORDER OR ES_LEFT OR ES_AUTOHSCROLL, \
                    20, 20, 300, 30, hWnd, 1, hInstance, NULL
    MOV         hEdit1, EAX
    INVOKE      CreateWindowEx, WS_EX_CLIENTEDGE, OFFSET szEdit, NULL, \; 创建单行文本编辑组件
                    WS_CHILD OR WS_VISIBLE OR WS_BORDER OR ES_LEFT OR ES_AUTOHSCROLL, \
                    20, 60, 300, 30, hWnd, 2, hInstance, NULL
    MOV         hEdit2, EAX
	INVOKE      CreateWindowEx, WS_EX_CLIENTEDGE, OFFSET szEdit, NULL, \; 创建多行文本编辑组件
                    WS_CHILD OR WS_VISIBLE OR WS_BORDER OR ES_LEFT OR ES_MULTILINE OR ES_READONLY OR ES_AUTOHSCROLL, \
                    20, 140, 300, 100, hWnd, 3, hInstance, NULL
    MOV         hEdit3, EAX
    .ELSEIF     EAX == WM_CLOSE
    INVOKE      DestroyWindow, hWindow                                  ; 销毁窗口
    INVOKE      PostQuitMessage, NULL                                   ; 发送退出消息，结束消息循环
    .ELSEIF     EAX == WM_COMMAND
    MOV         EBX, wParam
    
    .IF         EBX == 401H
    INVOKE      GetWindowText, hEdit1, OFFSET filePath1, 512            ; 获取控件Edit1内容
    INVOKE      GetWindowText, hEdit2, OFFSET filePath2, 512            ; 获取控件Edit2内容
    INVOKE      comp, OFFSET filePath1, OFFSET filePath2
    .ENDIF
    .ELSE
    INVOKE      DefWindowProc, hWnd, uMsg, wParam, lParam               ; 处理默认行为的消息
    RET
    .ENDIF
    XOR         EAX, EAX
    RET

_ProcWindow     ENDP

main            PROC
    LOCAL       @stWinStruct :WNDCLASSEX                                ; 窗口结构
    LOCAL       @stMsg :MSG                                             ; 消息结构

    INVOKE      GetModuleHandle, NULL                                   ; 获取当前模块句柄
    MOV         hInstance, EAX
    INVOKE      RtlZeroMemory, ADDR @stWinStruct, sizeof @stWinStruct
    INVOKE      LoadCursor, 0, IDC_ARROW                                ; 加载鼠标光标类型
    MOV         @stWinStruct.hCursor, EAX                               ; 指定鼠标在窗口中的光标形状
    PUSH        hInstance
    POP         @stWinStruct.hInstance                                  ; 指定窗口所在的模块实例
    MOV         @stWinStruct.cbSize, sizeof WNDCLASSEX                  ; 指定结构长度
    MOV         @stWinStruct.style, CS_HREDRAW OR CS_VREDRAW            ; 指定窗口风格
    MOV         @stWinStruct.lpfnWndProc, OFFSET _ProcWindow            ; 指定窗口的回调函数
    MOV         @stWinStruct.hbrBackground, COLOR_WINDOW + 1            ; 指定窗口的背景颜色
    MOV         @stWinStruct.lpszClassName, OFFSET szClassName          ; 指定窗口类名
    INVOKE      RegisterClassEx, ADDR @stWinStruct                      ; 注册窗口类"compWindow"
    INVOKE      CreateWindowEx, WS_EX_CLIENTEDGE, OFFSET szClassName, \ ; 从"compWindow"类创建窗口
                    OFFSET szWindowName,  WS_OVERLAPPEDWINDOW, \
                    100, 100, 360, 300, NULL, NULL, hInstance, NULL
    MOV         hWindow,EAX                                             ; 把返回的窗口句柄保存在hWindow
    INVOKE      ShowWindow, hWindow, SW_SHOWNORMAL                      ; 显示窗口
    INVOKE      UpdateWindow, hWindow                                   ; 绘制窗口
    
    .WHILE      TRUE
    INVOKE      GetMessage, ADDR @stMsg, NULL, 0, 0                     ; 从当前窗口的消息队列中获取消息
    .BREAK      .IF EAX == WM_QUIT                                      ; 如果消息队列中有WM_QUIT，则退出消息循环
    INVOKE      TranslateMessage, ADDR @stMsg                           ; 键盘消息转换
    INVOKE      DispatchMessage, ADDR @stMsg                            ; 调用回调函数处理消息
    .ENDW
    INVOKE      ExitProcess, 0                                          ; 结束进程
main            ENDP
END             main
