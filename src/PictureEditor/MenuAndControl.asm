;文件名：MenuAndControl.asm
;描述：菜单和总体控制相关函数，包括菜单初始化，字体，颜色等修改
;功能：只是设置菜单栏显示，并不负责鼠标点击的实现等其他操作
;需要调用Define.inc中对于各类MenuString

.386 
.model flat,stdcall 
option casemap:none

include Define.inc

public EraserRadius

.data
EraserRadius DWORD 10

.code
;创立菜单
ICreateMenu PROC
    extern hMenu: HMENU
    
    LOCAL FileMenu: HMENU
    LOCAL DrawMenu: HMENU
    LOCAL ColorMenu: HMENU  ; 移动颜色菜单的位置
    LOCAL FrameMenu: HMENU
    LOCAL LineMenu: HMENU
    LOCAL BrushMenu: HMENU
    LOCAL ToolMenu: HMENU
    LOCAL FontMenu: HMENU
    LOCAL SettingsMenu: HMENU
    LOCAL EraserSubMenu: HMENU
    LOCAL TextSubMenu: HMENU

    INVOKE CreateMenu
    .IF eax == 0
        ret
    .ENDIF
    mov hMenu, eax
    
    INVOKE CreatePopupMenu
    mov FileMenu, eax

    INVOKE CreatePopupMenu
    mov DrawMenu, eax

    ; 创建颜色菜单并添加到 hMenu 中
    INVOKE CreatePopupMenu
    mov ColorMenu, eax
    INVOKE AppendMenu, hMenu, MF_POPUP, ColorMenu, ADDR ColorMenuString

    INVOKE CreatePopupMenu
    mov FrameMenu, eax
    INVOKE CreatePopupMenu
    mov LineMenu, eax
    INVOKE CreatePopupMenu
    mov BrushMenu, eax
    INVOKE CreatePopupMenu
    mov ToolMenu, eax

    INVOKE CreatePopupMenu
    mov FontMenu, eax
    INVOKE CreatePopupMenu
    mov SettingsMenu, eax
    INVOKE CreatePopupMenu
    mov EraserSubMenu, eax
    INVOKE CreatePopupMenu
    mov TextSubMenu, eax

    INVOKE AppendMenu, hMenu, MF_POPUP, FileMenu, ADDR FileMenuString
    INVOKE AppendMenu, FileMenu, MF_STRING, IDM_LOAD, ADDR LoadMenuString
    INVOKE AppendMenu, FileMenu, MF_STRING, IDM_SAVE, ADDR SaveMenuString

    INVOKE AppendMenu, hMenu, MF_POPUP, DrawMenu, ADDR DrawMenuString
    INVOKE AppendMenu, DrawMenu, MF_STRING, IDM_DRAW, ADDR PaintMenuString

    INVOKE AppendMenu, ColorMenu, MF_STRING, IDM_BRUSH_COLOR, ADDR ColorBrushMenuString

    INVOKE AppendMenu, hMenu, MF_POPUP, FrameMenu, ADDR FrameMenuString
    INVOKE AppendMenu, FrameMenu, MF_POPUP, LineMenu, ADDR LineMenuString
    INVOKE AppendMenu, LineMenu, MF_STRING, IDM_SOLID_LINE, ADDR SolidLineMenuString

    INVOKE AppendMenu, hMenu, MF_POPUP, ToolMenu, ADDR ToolMenuString
    INVOKE AppendMenu, ToolMenu, MF_STRING, IDM_RECTANGLE, ADDR RectangleMenuString

    INVOKE AppendMenu, TextSubMenu, MF_POPUP, FontMenu, ADDR FontMenuString

    INVOKE AppendMenu, hMenu



;设置橡皮大小
IHandleEraserSize PROC, hWnd:HWND
	extern hInstance:HINSTANCE
	invoke DialogBoxParam, hInstance, IDD_DIALOG2 ,hWnd, OFFSET ICallEraserDialog, 0
	ret
IHandleEraserSize ENDP

;弹出对话框输入橡皮大小
ICallEraserDialog PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov ebx,uMsg
    .IF ebx == WM_COMMAND
        invoke IHandleEraserDialog,hWnd,wParam,lParam
    .ELSE 
		;默认处理
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret
ICallEraserDialog endp

;将对话框输入橡皮大小存储，用于绘制
IHandleEraserDialog PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
    mov ebx,wParam
    and ebx,0ffffh
    .IF ebx == IDOK
        invoke GetDlgItemInt,hWnd,IDC_EDIT2, NULL, 0
		.IF eax >= 5 && eax <= 50
			mov EraserRadius, eax
		.ENDIF
        invoke EndDialog,hWnd,wParam
    .ELSEIF ebx == IDCANCEL
        invoke EndDialog,hWnd,wParam
        mov eax,TRUE
    .ENDIF
    ret
IHandleEraserDialog ENDP

;设置画笔大小
IHandlePainterSize PROC, hWnd:HWND
	extern hInstance:HINSTANCE
	invoke DialogBoxParam, hInstance, IDD_DIALOG3 ,hWnd, OFFSET ICallPainterDialog, 0
	ret
IHandlePainterSize ENDP

;弹出对话框输入画笔大小
ICallPainterDialog PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov ebx,uMsg
    .IF ebx == WM_COMMAND
        invoke IHandlePainterDialog,hWnd,wParam,lParam
    .ELSE 
		;默认处理
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret
ICallPainterDialog endp

;将对话框输入画笔大小存储，用于绘制
IHandlePainterDialog PROC hWnd:HWND,wParam:WPARAM,lParam:LPARAM
	extern PenWidth:DWORD

    mov ebx,wParam
    and ebx,0ffffh
    .IF ebx == IDOK
        invoke GetDlgItemInt,hWnd,IDC_EDIT3, NULL, 0
		.IF eax >= 1 && eax <= 10
			mov PenWidth, eax
		.ENDIF
        invoke EndDialog,hWnd,wParam
    .ELSEIF ebx == IDCANCEL
        invoke EndDialog,hWnd,wParam
        mov eax,TRUE
    .ENDIF
    ret
IHandlePainterDialog ENDP

end
