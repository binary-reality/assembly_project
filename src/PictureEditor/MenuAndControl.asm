;�ļ�����MenuAndControl.asm
;�������˵������������غ����������˵���ʼ�������壬��ɫ���޸�
;���ܣ�ֻ�����ò˵�����ʾ�����������������ʵ�ֵ���������
;��Ҫ����Define.inc�ж��ڸ���MenuString

.386 
.model flat,stdcall 
option casemap:none

include Define.inc

public EraserRadius

.data
EraserRadius DWORD 10

.code
;�����˵�
ICreateMenu PROC
    extern hMenu: HMENU
    
    LOCAL FileMenu: HMENU
    LOCAL DrawMenu: HMENU
    LOCAL ColorMenu: HMENU  ; �ƶ���ɫ�˵���λ��
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

    ; ������ɫ�˵�����ӵ� hMenu ��
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



;������Ƥ��С
IHandleEraserSize PROC, hWnd:HWND
	extern hInstance:HINSTANCE
	invoke DialogBoxParam, hInstance, IDD_DIALOG2 ,hWnd, OFFSET ICallEraserDialog, 0
	ret
IHandleEraserSize ENDP

;�����Ի���������Ƥ��С
ICallEraserDialog PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov ebx,uMsg
    .IF ebx == WM_COMMAND
        invoke IHandleEraserDialog,hWnd,wParam,lParam
    .ELSE 
		;Ĭ�ϴ���
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret
ICallEraserDialog endp

;���Ի���������Ƥ��С�洢�����ڻ���
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

;���û��ʴ�С
IHandlePainterSize PROC, hWnd:HWND
	extern hInstance:HINSTANCE
	invoke DialogBoxParam, hInstance, IDD_DIALOG3 ,hWnd, OFFSET ICallPainterDialog, 0
	ret
IHandlePainterSize ENDP

;�����Ի������뻭�ʴ�С
ICallPainterDialog PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov ebx,uMsg
    .IF ebx == WM_COMMAND
        invoke IHandlePainterDialog,hWnd,wParam,lParam
    .ELSE 
		;Ĭ�ϴ���
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret
ICallPainterDialog endp

;���Ի������뻭�ʴ�С�洢�����ڻ���
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
