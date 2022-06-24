.386
.model          flat, stdcall
option          casemap:none

includelib		msvcrt.lib
scanf           PROTO C :PTR BYTE, :vararg
printf			PROTO C :PTR BYTE, :vararg
strlen          PROTO C :PTR BYTE

.data
MAX_LEN         EQU     1000
msgBegin        BYTE    "Please enter multipliers A and multipliers B:", 0AH, 0
msgLenErr       BYTE    "The input length should be between 1 and 1000.", 0AH, 0
fmtScan         BYTE    "%s", 0
fmtPrintDigit   BYTE    "%d", 0
fmtPrintFlag    BYTE    "-", 0
A               BYTE    MAX_LEN DUP(0)
B               BYTE    MAX_LEN DUP(0)
lenA            DWORD   ?
lenB            DWORD   ?
negativeFlag    BYTE    0
zeroFlag        BYTE    1
ANS             DWORD   2*MAX_LEN DUP(0)

.code
; 反转字符串并将ASCII码表示转换为无符号数表示，返回去除符号(如果存在)的字符串长度
ReverseStr      PROC C rawStr: PTR BYTE, lenStr: DWORD
    MOV         ECX, [lenStr]
    MOV         ESI, rawStr
    
    MOV         EAX, [lenStr]
    MOVZX       EBX, BYTE PTR [ESI]
    CMP         EBX, '-'                          ; 判断符号位
    JNZ         ReversePush
    XOR         negativeFlag, 1
    DEC         EAX
    
    ReversePush:
    MOVZX       EBX, BYTE PTR [ESI]              ; 堆栈单元最小为16位
    SUB         EBX, '0'                         ; ASCII转换为无符号数
    PUSH        EBX
    INC         ESI
    LOOP        ReversePush
    
    MOV         ECX, [lenStr]
    MOV         ESI, rawStr
    ReversePop:
    POP         EBX
    MOV         [ESI], BL
    INC         ESI
    LOOP        ReversePop
    RET
ReverseStr      ENDP

main			PROC
    INVOKE      printf, OFFSET msgBegin             ; 提示用户输入被乘数A和乘数B
    INVOKE      scanf, OFFSET fmtScan, OFFSET A
    INVOKE      strlen, OFFSET A
    CMP         EAX, MAX_LEN
    JA          LengthOverflow                      ; 输入A超过MAX_LEN位，为避免溢出，程序报错并结束
    INVOKE      ReverseStr, OFFSET A, EAX
    MOV         lenA, EAX
    INVOKE      scanf, OFFSET fmtScan, OFFSET B
    INVOKE      strlen, OFFSET B
    CMP         EAX, MAX_LEN
    JA          LengthOverflow                      ; 输入B超过MAX_LEN位，为避免溢出，程序报错并结束
    INVOKE      ReverseStr, OFFSET B, EAX
    MOV         lenB, EAX

    XOR         ESI, ESI
    BLoop:                                          ; BLoop遍历B的每一位
    XOR         EDI, EDI
    LEA         ECX, ANS[4 * ESI]
    ALoop:                                          ; ALoop遍历A的每一位
    XOR         EAX, EAX
    MOV         AL, A[EDI]
    MUL         B[ESI]
    ADD         EAX, DWORD PTR [ECX][4 * EDI]
    MOV         EBX, 10
    XOR         EDX, EDX
    DIV         EBX
    ADD         DWORD PTR [ECX][4 * EDI + 4], EAX   ; 商转移到进位
    MOV         DWORD PTR [ECX][4 * EDI], EDX       ; 余数保留在原位
    INC         EDI
    CMP         EDI, [lenA]
    JNZ         ALoop
    INC         ESI
    CMP         ESI, [lenB]
    JNZ         BLoop

    MOV         ECX, 2*MAX_LEN
    XOR         ESI, ESI
    AnsReversePush:
    PUSH        ANS[4 * ESI]
    INC         ESI
    LOOP        AnsReversePush
    MOV         ECX, 2*MAX_LEN
    CMP         negativeFlag, 0
    JZ          AnsReversePop
    PUSH        ECX
    INVOKE      printf, OFFSET fmtPrintFlag
    POP         ECX
    AnsReversePop:
    POP         EAX
    CMP         EAX, 0
    JZ          CmpZeroFlag
    MOV         zeroFlag, 0
    CmpZeroFlag:
    CMP         zeroFlag, 0
    JNZ         SkipPrint                           ; 跳过有效位前的0位
    PUSH        ECX
    INVOKE      printf, OFFSET fmtPrintDigit, EAX
    POP         ECX
    SkipPrint:
    LOOP        AnsReversePop
    
    CMP         zeroFlag, 0                         ; 处理结果为0时输出
    JZ          NormalEnd
    INVOKE      printf, OFFSET fmtPrintDigit, ECX
    JMP         NormalEnd
    LengthOverflow:
    INVOKE      printf, OFFSET msgLenErr
    JMP         NormalEnd

    NormalEnd:
main			ENDP
END				main