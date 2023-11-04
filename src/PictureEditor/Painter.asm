;文件名：Painter.asm
;描述：各种绘图函数的定义

.386 
.model flat,stdcall 
option casemap:none

include Define.inc

public CurrentMode
public CurrentX
public CurrentY
public StartX
public StartY
public EndX
public EndY
public MouseStatus
public ShowString
public CurrentPointNum
public SameThreshold

.data
; 模式
CurrentMode DWORD IDM_MODE_DRAW

;画线和擦除
;坐标
CurrentX DWORD 0
CurrentY DWORD 0
StartX DWORD 0
StartY DWORD 0
EndX DWORD 0
EndY DWORD 0
;鼠标状态
MouseStatus DWORD 0

;当前使用的点信息
CurrentPointNum DWORD 0
CurrentPointListX DWORD 100 DUP(?)
CurrentPointListY DWORD 100 DUP(?)

;判断两点是否接近的Threshold
SameThreshold DWORD 4

;显示的文字
ShowString BYTE 100 dup(?)


.code
;画笔绘制函数
IPaint PROC, hdc:HDC
	INVOKE MoveToEx, hdc, StartX, StartY, NULL
	INVOKE LineTo, hdc, EndX, EndY
	INVOKE MoveToEx, hdc, 0, 0, NULL
	ret
IPaint ENDP

;橡皮擦除函数
IErase PROC, hdc:HDC
	extern EraserRadius:DWORD
	INVOKE GetStockObject, NULL_PEN
	INVOKE SelectObject, hdc, eax
	mov ecx, EraserRadius
	sub CurrentX, ecx
	sub CurrentY, ecx
	mov ebx, CurrentX
	mov edx, CurrentY
	add ebx, ecx
	add ebx, ecx
	add edx, ecx
	add edx, ecx
	INVOKE Rectangle, hdc, CurrentX, CurrentY, ebx, edx
	add CurrentX, ecx
	add CurrentY, ecx
	ret
IErase ENDP

;文字输入函数
IText PROC, hdc:HDC,hWnd:HWND
	extern hInstance:HINSTANCE
	mov edx, CurrentX
	mov ecx, CurrentY
	push edx
	push ecx
	invoke DialogBoxParam, hInstance, IDD_DIALOG1 ,hWnd, OFFSET ICallTextDialog, 0
	invoke crt_strlen, OFFSET ShowString
	pop ecx
	pop edx
	INVOKE TextOutA, hdc, edx, ecx, ADDR ShowString, eax
	mov ShowString, 0
	ret
IText ENDP

;画线函数
IPaintLine PROC, hdc:HDC
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE LineTo, hdc, edx, ecx
	INVOKE MoveToEx, hdc, 0, 0, NULL
	mov CurrentPointNum, 0
	ret
IPaintLine ENDP

;画矩形框函数
IPaintRectangleFrame PROC hdc:HDC
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY + 4]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE LineTo, hdc, edx, ecx
	mov edx, DWORD PTR [CurrentPointListX + 4]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE MoveToEx, hdc, edx, ecx, NULL
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	INVOKE LineTo, hdc, edx, ecx
	INVOKE MoveToEx, hdc, 0, 0, NULL
	mov CurrentPointNum, 0
	ret
IPaintRectangleFrame ENDP

;画矩形函数
IPaintRectangle PROC, hdc:HDC
	mov edx, DWORD PTR [CurrentPointListX]
	mov ecx, DWORD PTR [CurrentPointListY]
	mov ebx, DWORD PTR [CurrentPointListX + 4]
	mov eax, DWORD PTR [CurrentPointListY + 4]
	INVOKE Rectangle, hdc, edx, ecx, ebx, eax
	mov CurrentPointNum, 0
	ret
IPaintRectangle ENDP

;获得当前点信息
IGetCurrentPoint PROC, Place:DWORD
	push ebx
	push edx
	mov ebx, Place
	mov edx, 0
	mov dx, bx
	sar ebx, 16
	mov CurrentX, edx
	mov CurrentY, ebx
	pop edx
	pop ebx
	ret
IGetCurrentPoint ENDP

;将当前点存储进点列
IAddGraphPoint PROC
	LOCAL PointerX:DWORD
	LOCAL PointerY:DWORD
	push edx
	push ebx
	mov edx, OFFSET CurrentPointListX
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	mov PointerX, edx
	mov edx, OFFSET CurrentPointListY
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	add edx, CurrentPointNum
	mov PointerY, edx
	mov ebx, CurrentX
	mov edx, PointerX
	mov [edx], ebx
	mov ebx, CurrentY
	mov edx, PointerY
	mov [edx], ebx
	inc CurrentPointNum
	pop ebx
	pop edx
	ret
IAddGraphPoint ENDP

;弹出对话框输入文字
ICallTextDialog PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov ebx,uMsg
    .IF ebx == WM_COMMAND
        invoke IHandleTextDialog,hWnd,wParam,lParam
    .ELSE 
		;默认处理
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret
ICallTextDialog endp

;将对话框输入文字存储，用于绘制
IHandleTextDialog PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov ebx,wParam
    and ebx,0ffffh
    .IF ebx == IDOK
        invoke GetDlgItemText,hWnd,IDC_EDIT1,addr ShowString, MAX_LENGTH
        invoke EndDialog,hWnd,wParam
    .ELSEIF ebx == IDCANCEL
        invoke EndDialog,hWnd,wParam
        mov eax,TRUE
    .ENDIF
    ret
IHandleTextDialog ENDP

end

