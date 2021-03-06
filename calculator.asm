.386
.model flat, stdcall
option casemap:none

includelib      msvcrt.lib
include         windows.inc
include         kernel32.inc
includelib      kernel32.lib
include         user32.inc
includelib      user32.lib
printf			PROTO C :PTR BYTE, :vararg
sscanf          PROTO C :PTR BYTE, :PTR BYTE, :vararg
sprintf         PROTO C: PTR BYTE, :PTR BYTE, :vararg
strcat          PROTO C :PTR BYTE, :PTR BYTE
strcpy          PROTO C :PTR BYTE, :PTR BYTE
strlen          PROTO C :PTR BYTE

.data
hInstance       DWORD   ?
hWindow         DWORD   ?
hEdit1          DWORD   ?
hEdit2          DWORD   ?
Op              DWORD   ?
NumStr1			BYTE	100 DUP(0)
NumStr2			BYTE	100 DUP(0)
ResStr          BYTE    100 DUP(0)
buf				BYTE	1024 DUP(0)
State			BYTE	0

szFmtPrintF     BYTE    "%lf", 0AH, 0
szFmtPrintS     BYTE    "%s", 0AH, 0

.const
szClassName     BYTE    "Calculator", 0
szWindowName    BYTE    "Calculator", 0
szButton        BYTE    "button", 0
szEdit          BYTE    "edit", 0
szStrError      BYTE    "ERROR", 0
szStrEqu        BYTE    " =", 0
szNopStr        BYTE    0, 0
szFmtUnaryOp    BYTE    "%s(%s)", 0
szFmtBinaryOp   BYTE    "%s %s ", 0
szFmtFloatStr   BYTE    "%lf", 0
szButtonText11  BYTE    "2^", 0
szButtonText12  BYTE    "sqrt", 0
szButtonText13  BYTE    "%", 0
szButtonText14  BYTE    "C", 0
szButtonText15  BYTE    "/", 0
szButtonText21  BYTE    "sin", 0
szButtonText22  BYTE    "7", 0
szButtonText23  BYTE    "8", 0
szButtonText24  BYTE    "9", 0
szButtonText25  BYTE    "x", 0
szButtonText31  BYTE    "cos", 0
szButtonText32  BYTE    "4", 0
szButtonText33  BYTE    "5", 0
szButtonText34  BYTE    "6", 0
szButtonText35  BYTE    "-", 0
szButtonText41  BYTE    "tan", 0
szButtonText42  BYTE    "1", 0
szButtonText43  BYTE    "2", 0
szButtonText44  BYTE    "3", 0
szButtonText45  BYTE    "+", 0
szButtonText51  BYTE    "cot", 0
szButtonText52  BYTE    "+/-", 0
szButtonText53  BYTE    "0", 0
szButtonText54  BYTE    ".", 0
szButtonText55  BYTE    "=", 0

.code
GetNegative     PROC C USES EAX EBX, NumStr :PTR BYTE, hEdit :DWORD
    LOCAL       buf1[1024] :BYTE
    LOCAL       p :PTR BYTE
    LOCAL       numLen :DWORD, editLen :DWORD

    MOV         EAX, NumStr
    MOV         BL, [EAX]
    ; ?????????????????????????????????
    .IF         BL == '-'
    INC         EAX
    INVOKE      strcpy, ADDR buf1, EAX
    .ELSE
    MOV         BL, '-'
    MOV         buf1, BL
    LEA         EAX, buf1
    INC         EAX
    INVOKE      strcpy, EAX, NumStr
    .ENDIF
    ; ????????????????????????hEdit????????????
    INVOKE      strlen, NumStr
    MOV         numLen, EAX
    INVOKE      GetWindowText, hEdit, OFFSET buf, 1024
    INVOKE      strlen, OFFSET buf
    MOV         editLen, EAX
    LEA         EAX, buf
    SUB         EAX, numLen
    ADD         EAX, editLen
    MOV         p, EAX
    ; ?????????????????????Numstr    
    INVOKE      strcpy, NumStr, ADDR buf1
    INVOKE      strcpy, p, ADDR buf1
    INVOKE      SetWindowText, hEdit, OFFSET buf
    RET
GetNegative     ENDP

UpdateNum		PROC C USES EAX, id :DWORD, NumStr :PTR BYTE, hEdit :DWORD
	LOCAL       p :PTR BYTE

    .IF			id == 422H
	LEA         EAX, szButtonText22
	.ELSEIF		id == 423H
	LEA         EAX, szButtonText23
	.ELSEIF		id == 424H
	LEA         EAX, szButtonText24
	.ELSEIF		id == 432H
	LEA         EAX, szButtonText32
	.ELSEIF		id == 433H
	LEA         EAX, szButtonText33
	.ELSEIF		id == 434H
	LEA         EAX, szButtonText34
	.ELSEIF		id == 442H
	LEA         EAX, szButtonText42
	.ELSEIF		id == 443H
	LEA         EAX, szButtonText43
	.ELSEIF		id == 444H
	LEA         EAX, szButtonText44
	.ELSEIF		id == 453H
	LEA         EAX, szButtonText53
    .ELSEIF     id == 454H
    LEA         EAX, szButtonText54
	.ELSE
	RET
	.ENDIF

    ; ??????????????????
    MOV         p, EAX
    INVOKE      strcat, NumStr, p
    INVOKE      GetWindowText, hEdit, OFFSET buf, 1024
    INVOKE      strcat, OFFSET buf, p
    INVOKE      SetWindowText, hEdit, OFFSET buf
	RET
UpdateNum		ENDP

UpdateUnaryOp   PROC C USES EAX, id :DWORD, hEdit :DWORD
    LOCAL       p :PTR BYTE
    LOCAL       buf1[1024] :BYTE
    
    PUSH        id
    POP         Op

    .IF         id == 411H
    LEA         EAX, szButtonText11
    .ELSEIF     id == 412H
    LEA         EAX, szButtonText12
    .ELSEIF     id == 421H
    LEA         EAX, szButtonText21
    .ELSEIF     id == 431H
    LEA         EAX, szButtonText31
    .ELSEIF     id == 441H
    LEA         EAX, szButtonText41
    .ELSEIF     id == 451H
    LEA         EAX, szButtonText51
    .ELSE
    RET
    .ENDIF

    ; ??????????????????????????????opr(num)
    MOV         p, EAX
    INVOKE      GetWindowText, hEdit, ADDR buf1, 1024
    INVOKE      sprintf, OFFSET buf, OFFSET szFmtUnaryOp, p, ADDR buf1
    INVOKE      SetWindowText, hEdit, OFFSET buf
    RET
UpdateUnaryOp      ENDP

UpdateBinaryOp  PROC C USES EAX, id :DWORD, hEdit :DWORD
    LOCAL       p :PTR BYTE
    LOCAL       buf1[1024] :BYTE
    
    PUSH        id
    POP         Op

    .IF         id == 413H
    LEA         EAX, szButtonText13
    .ELSEIF     id == 415H
    LEA         EAX, szButtonText15
    .ELSEIF     id == 425H
    LEA         EAX, szButtonText25
    .ELSEIF     id == 435H
    LEA         EAX, szButtonText35
    .ELSEIF     id == 445H
    LEA         EAX, szButtonText45
    .ELSE
    RET
    .ENDIF

    ; ??????????????????????????????num1 op1 
    MOV         p, EAX
    INVOKE      GetWindowText, hEdit, ADDR buf1, 1024
    INVOKE      sprintf, OFFSET buf, OFFSET szFmtBinaryOp, ADDR buf1, p
    INVOKE      SetWindowText, hEdit, OFFSET buf
    RET
UpdateBinaryOp  ENDP

PerformCal      PROC C USES EAX, hEdita :DWORD, hEditb :DWORD
    LOCAL       p :PTR BYTE
    LOCAL       buf1[1024] :BYTE
    LOCAL       Num1 :REAL8, Num2 :REAL8

    ; ?????????????????? =
    INVOKE      GetWindowText, hEdita, OFFSET buf, 1024
    INVOKE      strcat, OFFSET buf, OFFSET szStrEqu
    INVOKE      SetWindowText, hEdita, OFFSET buf
    
    FINIT
    ; ??????????????????
    .IF         Op == 411H || Op == 412H || Op == 421H || Op == 431H || Op == 441H || Op == 451H
        INVOKE      sscanf, OFFSET NumStr1, OFFSET szFmtFloatStr, ADDR Num1
        FLD         Num1
        .IF         Op == 411H
        FLD1
        FSCALE
        .ELSEIF     Op == 412H
        FSQRT
        .ELSEIF     Op == 421H
        FSIN
        .ELSEIF     Op == 431H
        FCOS
        .ELSEIF     Op == 441H
        FPTAN
        .ELSEIF     Op == 451H
        FPATAN
        .ENDIF
    ; ???????????????
    .ELSEIF     Op == 413H
        INVOKE      sscanf, OFFSET NumStr1, OFFSET szFmtFloatStr, ADDR Num1
        INVOKE      sscanf, OFFSET NumStr2, OFFSET szFmtFloatStr, ADDR Num2
        FLD         Num2
        FLD         Num1
        FPREM
    ; ??????????????????
    .ELSEIF     Op == 415H || Op == 425H || Op == 435H || Op == 445H
        INVOKE      sscanf, OFFSET NumStr1, OFFSET szFmtFloatStr, ADDR Num1
        INVOKE      sscanf, OFFSET NumStr2, OFFSET szFmtFloatStr, ADDR Num2
        FLD         Num1
        FLD         Num2
        .IF         Op == 415H
        FDIV
        .ELSEIF     Op == 425H
        FMUL
        .ELSEIF     Op == 435H
        FSUB
        .ELSEIF     Op == 445H
        FADD
        .ENDIF
    .ELSE
    RET
    .ENDIF

    ; ??????????????????
    FSTP        Num1
    INVOKE      sprintf, OFFSET ResStr, OFFSET szFmtFloatStr, Num1
    ; ????????????????????????
    INVOKE      SetWindowText, hEditb, OFFSET ResStr
    RET
PerformCal      ENDP

_ProcWindow     PROC C USES EBX EDI ESI, hWnd, uMsg, wParam, lParam
    LOCAL       @stPaintStruct :PAINTSTRUCT
    LOCAL       @stRect :RECT
	LOCAL		@hDc

    MOV         EAX, uMsg
    .IF         EAX == WM_PAINT
    INVOKE      BeginPaint, hWnd, ADDR @stPaintStruct
	MOV			@hDc, EAX
	INVOKE		GetClientRect, hWnd, ADDR @stRect
    INVOKE      EndPaint, hWnd, ADDR @stPaintStruct
    .ELSEIF     EAX == WM_CREATE
    INVOKE      CreateWindowEx, WS_EX_CLIENTEDGE, OFFSET szEdit, NULL, \; ??????????????????????????????
                    WS_CHILD OR WS_VISIBLE OR WS_BORDER OR ES_LEFT OR ES_READONLY OR ES_AUTOHSCROLL, \
                    25, 20, 267, 25, hWnd, 1, hInstance, NULL
    MOV         hEdit1, EAX
    INVOKE      CreateWindowEx, WS_EX_CLIENTEDGE, OFFSET szEdit, NULL, \; ??????????????????????????????
                    WS_CHILD OR WS_VISIBLE OR WS_BORDER OR ES_RIGHT OR ES_READONLY OR ES_AUTOHSCROLL, \
                    25, 50, 267, 25, hWnd, 2, hInstance, NULL
    MOV         hEdit2, EAX


	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText11, WS_CHILD OR WS_VISIBLE, \
                    25, 90, 45, 25, hWnd, 411H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText12, WS_CHILD OR WS_VISIBLE, \
                    80, 90, 45, 25, hWnd, 412H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText13, WS_CHILD OR WS_VISIBLE, \
                    135, 90, 45, 25, hWnd, 413H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText14, WS_CHILD OR WS_VISIBLE, \
                    190, 90, 45, 25, hWnd, 414H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText15, WS_CHILD OR WS_VISIBLE, \
                    245, 90, 45, 25, hWnd, 415H, hInstance, NULL
	
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText21, WS_CHILD OR WS_VISIBLE, \
                    25, 125, 45, 25, hWnd, 421H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText22, WS_CHILD OR WS_VISIBLE, \
                    80, 125, 45, 25, hWnd, 422H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText23, WS_CHILD OR WS_VISIBLE, \
                    135, 125, 45, 25, hWnd, 423H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText24, WS_CHILD OR WS_VISIBLE, \
                    190, 125, 45, 25, hWnd, 424H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText25, WS_CHILD OR WS_VISIBLE, \
                    245, 125, 45, 25, hWnd, 425H, hInstance, NULL
	
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText31, WS_CHILD OR WS_VISIBLE, \
                    25, 160, 45, 25, hWnd, 431H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText32, WS_CHILD OR WS_VISIBLE, \
                    80, 160, 45, 25, hWnd, 432H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText33, WS_CHILD OR WS_VISIBLE, \
                    135, 160, 45, 25, hWnd, 433H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText34, WS_CHILD OR WS_VISIBLE, \
                    190, 160, 45, 25, hWnd, 434H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText35, WS_CHILD OR WS_VISIBLE, \
                    245, 160, 45, 25, hWnd, 435H, hInstance, NULL
	
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText41, WS_CHILD OR WS_VISIBLE, \
                    25, 195, 45, 25, hWnd, 441H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText42, WS_CHILD OR WS_VISIBLE, \
                    80, 195, 45, 25, hWnd, 442H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText43, WS_CHILD OR WS_VISIBLE, \
                    135, 195, 45, 25, hWnd, 443H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText44, WS_CHILD OR WS_VISIBLE, \
                    190, 195, 45, 25, hWnd, 444H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText45, WS_CHILD OR WS_VISIBLE, \
                    245, 195, 45, 25, hWnd, 445H, hInstance, NULL

	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText51, WS_CHILD OR WS_VISIBLE, \
                    25, 230, 45, 25, hWnd, 451H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText52, WS_CHILD OR WS_VISIBLE, \
                    80, 230, 45, 25, hWnd, 452H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText53, WS_CHILD OR WS_VISIBLE, \
                    135, 230, 45, 25, hWnd, 453H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText54, WS_CHILD OR WS_VISIBLE, \
                    190, 230, 45, 25, hWnd, 454H, hInstance, NULL
	INVOKE      CreateWindowEx, NULL, OFFSET szButton, \                ; ??????????????????
                    OFFSET szButtonText55, WS_CHILD OR WS_VISIBLE, \
                    245, 230, 45, 25, hWnd, 455H, hInstance, NULL
    .ELSEIF     EAX == WM_CLOSE
    INVOKE      DestroyWindow, hWindow                                  ; ????????????
    INVOKE      PostQuitMessage, NULL                                   ; ???????????????????????????????????????
	.ELSEIF     EAX == WM_COMMAND
	;-------------------------------------------------------------------------------------------------------------
	MOV         EBX, wParam
	; ???????????????
	.IF	EBX == 422H || EBX == 423H || EBX == 424H || EBX == 432H || EBX == 433H || EBX == 434H || EBX == 442H || EBX == 443H || EBX == 444H || EBX == 453H
        ; ????????????????????????????????????
        .IF	State == 0 || State == 1 || State == 2
            INVOKE UpdateNum, EBX, OFFSET NumStr1, hEdit1
            ; ????????????
            .IF	State == 0
                MOV	State, 1
            .ENDIF
        ; ????????????????????????????????????
        .ELSEIF State == 4 || State == 5 || State == 6
            INVOKE UpdateNum, EBX, OFFSET NumStr2, hEdit1
            ; ????????????
            .IF State == 4
                MOV State, 5
            .ENDIF
        ; ????????????
        .ELSE
            INVOKE SetWindowText, hEdit1, OFFSET szStrError
            MOV State, 8
        .ENDIF
	; ????????????????????????
	.ELSEIF	EBX == 411H || EBX == 412H || EBX == 421H || EBX == 431H || EBX == 441H || EBX == 451H
        .IF State == 1 || State == 2
            INVOKE UpdateUnaryOp, EBX, hEdit1
            MOV State, 3
        .ELSE
            INVOKE SetWindowText, hEdit1, OFFSET szStrError
            MOV State, 8
        .ENDIF
	; ????????????????????????
	.ELSEIF	EBX == 413H || EBX == 415H || EBX == 425H || EBX == 435H || EBX == 445H
        .IF State == 1 || State == 2
            INVOKE UpdateBinaryOp, EBX, hEdit1
            MOV State, 4
        .ELSE
            INVOKE SetWindowText, hEdit1, OFFSET szStrError
            MOV State, 8
        .ENDIF
	; ????????????+/-???
	.ELSEIF	EBX == 452H
        ; ????????????????????????????????????
        .IF State == 1 || State == 2
            INVOKE GetNegative, OFFSET NumStr1, hEdit1
        ; ????????????????????????????????????
        .ELSEIF State == 5 || State == 6
            INVOKE GetNegative, OFFSET NumStr2, hEdit1
        .ELSE
            INVOKE SetWindowText, hEdit1, OFFSET szStrError
            MOV State, 8
        .ENDIF
	; ????????????.???
	.ELSEIF	EBX == 454H
        ; ????????????????????????????????????
        .IF State == 1
            INVOKE UpdateNum, EBX, OFFSET NumStr1, hEdit1
            MOV State, 2
        ; ????????????????????????????????????
        .ELSEIF State == 5
            INVOKE UpdateNum, EBX, OFFSET NumStr2, hEdit1
            MOV State, 6
        .ELSE
            INVOKE SetWindowText, hEdit1, OFFSET szStrError
            MOV State, 8
        .ENDIF
	; ?????????'=???
	.ELSEIF	EBX == 455H
        .IF State == 3 || State == 5 || State == 6
            INVOKE PerformCal, hEdit1, hEdit2
            MOV State, 7
        .ELSE
            INVOKE SetWindowText, hEdit1, OFFSET szStrError
            MOV State, 8
        .ENDIF
	; ?????????'C'
	.ELSEIF		EBX == 414H
        INVOKE strcpy, OFFSET NumStr1, OFFSET szNopStr
        INVOKE strcpy, OFFSET NumStr2, OFFSET szNopStr
        INVOKE strcpy, OFFSET ResStr, OFFSET szNopStr
        INVOKE SetWindowText, hEdit1, OFFSET szNopStr
        INVOKE SetWindowText, hEdit2, OFFSET szNopStr
        MOV State, 0
	.ENDIF
	;-------------------------------------------------------------------------------------------------------------
	.ELSE
    INVOKE      DefWindowProc, hWnd, uMsg, wParam, lParam               ; ???????????????????????????
    RET
	.ENDIF
    XOR         EAX, EAX
    RET
_ProcWindow     ENDP

main            PROC
    LOCAL       @stWinStruct :WNDCLASSEX                                ; ????????????
    LOCAL       @stMsg :MSG                                             ; ????????????

    INVOKE      GetModuleHandle, NULL                                   ; ????????????????????????
    MOV         hInstance, EAX
    INVOKE      RtlZeroMemory, ADDR @stWinStruct, sizeof @stWinStruct
    INVOKE      LoadCursor, 0, IDC_ARROW                                ; ????????????????????????
    MOV         @stWinStruct.hCursor, EAX                               ; ???????????????????????????????????????
    PUSH        hInstance
    POP         @stWinStruct.hInstance                                  ; ?????????????????????????????????
    MOV         @stWinStruct.cbSize, sizeof WNDCLASSEX                  ; ??????????????????
    MOV         @stWinStruct.style, CS_HREDRAW OR CS_VREDRAW            ; ??????????????????
    MOV         @stWinStruct.lpfnWndProc, OFFSET _ProcWindow            ; ???????????????????????????
    MOV         @stWinStruct.hbrBackground, COLOR_WINDOW + 1            ; ???????????????????????????
    MOV         @stWinStruct.lpszClassName, OFFSET szClassName          ; ??????????????????
    INVOKE      RegisterClassEx, ADDR @stWinStruct                      ; ???????????????"Calculator"
    INVOKE      CreateWindowEx, WS_EX_CLIENTEDGE, OFFSET szClassName, \ ; ???"Calculator"???????????????
                    OFFSET szWindowName,  WS_OVERLAPPEDWINDOW, \
                    100, 100, 340, 320, NULL, NULL, hInstance, NULL
    MOV         hWindow,EAX                                             ; ?????????????????????????????????hWindow
    INVOKE      ShowWindow, hWindow, SW_SHOWNORMAL                      ; ????????????
    INVOKE      UpdateWindow, hWindow                                   ; ????????????
    
    .WHILE      TRUE
    INVOKE      GetMessage, ADDR @stMsg, NULL, 0, 0                     ; ?????????????????????????????????????????????
    .BREAK      .IF EAX == WM_QUIT                                      ; 
    INVOKE      TranslateMessage, ADDR @stMsg                           ; ??????????????????
    INVOKE      DispatchMessage, ADDR @stMsg                            ; ??????????????????????????????
    .ENDW
    INVOKE      ExitProcess, 0                                          ; ????????????
main            ENDP
END             main
