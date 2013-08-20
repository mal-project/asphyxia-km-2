; template v.1.7 (keygen)
;.......................................................................
.486
.model flat, stdcall
option casemap :none

;.......................................................................
include     project.inc

;.......................................................................
.code
    include release.asm

;.......................................................................
MAINDLGPROC PROC hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

    switch  uMsg
    
        case    WM_INITDIALOG
        
            mov     eax,hWnd
            mov     hWndGlobal, eax         ; for the thread
            
            invoke  CreateEvent, 0, 0, 0, 0 ; creating the event
            mov     hEventStart,eax
            
            invoke  CreateThread, 0, 0, KEYGENPROC, 0, 0, addr hThreadID
            invoke  CloseHandle,eax         ; creating the thread
            
            invoke  INITIALIZE, hWnd        ; generating request code and printing it
        
        case    WM_COMMAND
            
            mov     eax,wParam
            
            switch  eax

                case    IDB_CLOSE           ; close button

                    invoke  EndDialog, hWnd, 0

                IF INFODLG
            
                case    IDB_INF             ; button info
                
                    invoke  DialogBoxParam, hInst, IDD_INF, hWnd, INFODLGPROC, 0
                
                ENDIF
            
                IF AUTOUPDATE
            
                case    IDE_NAME || IDE_SERIAL
                
                    shr     eax,16
                    .if ax == EN_CHANGE
                                            ; starting keygen thread
                        invoke  SetEvent, hEventStart

                    .endif
            
                ELSE
            
                case    IDB_GEN             ; gen button
                                            ; starting keygen thread
                    invoke  SetEvent, hEventStart

                ENDIF

            endsw

        case    WM_DEFEATED

            invoke  SendDlgItemMessage, hWnd, IDE_SERIAL, EM_SETREADONLY, 1, 0
            invoke  SendDlgItemMessage, hWnd, IDE_NAME, EM_SETREADONLY, 1, 0

            invoke  MessageBox, hWnd, addr szSUCCESSTEXT, addr szSUCCESSTITLE, MB_ICONINFORMATION + MB_OK + MB_TOPMOST
        
        case    WM_CLOSE || uMsg == WM_RBUTTONUP || uMsg == WM_LBUTTONDBLCLK
            
            invoke  EndDialog, hWnd, 0
        
        case    WM_LBUTTONDOWN
            
            invoke  SendMessage, hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0

    endsw

    xor     eax,eax
    ret

MAINDLGPROC endp

;.......................................................................
IF INFODLG

INFODLGPROC PROC hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM


    switch  uMsg
    
        case    WM_INITDIALOG
        
            IF INFODLG AND RELEASEDATA
            
            invoke  FindResource, hInst, IDR_INF, RT_RCDATA
            invoke  LoadResource, hInst, eax
            invoke  LockResource, eax
            
            invoke  SendDlgItemMessage, hWnd, IDE_INF, WM_SETTEXT, 0, eax
        
            ENDIF
        
        case    WM_COMMAND
        
            .if wParam == IDB_CLSINF
        
                invoke  SendMessage, hWnd, WM_CLOSE, 0, 0

            .endif

        case    WM_CLOSE || uMsg == WM_RBUTTONUP || uMsg == WM_LBUTTONDBLCLK

            invoke  EndDialog, hWnd, 0
    
        case    WM_LBUTTONDOWN
            
            invoke  SendMessage, hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0

    endsw

    xor     eax, eax
    ret

INFODLGPROC ENDP

ENDIF

;.......................................................................
Start:
    pushad
    
    invoke  GetModuleHandle, 0
    mov     hInst,eax
    
    invoke  DialogBoxParam, hInst, IDD_DLG, 0, MAINDLGPROC, 0

    popad

    invoke  ExitProcess, 0
ret

end Start