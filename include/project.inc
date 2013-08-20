;.......................................................................
include     includes.inc

;.......................................................................
MIN_NAMELEN     equ 5
MAX_NAMELEN     equ 32
MIN_SERIALLEN   equ 32
MAX_SERIALLEN   equ 32

;.......................................................................
AUTOUPDATE      equ 1                ; guess
INFODLG         equ 1                ; info dlg?
RELEASEDATA     equ 1                ; show release data at info dlg

;.......................................................................
; Prototypes
MAINDLGPROC     PROTO    :HWND,:UINT,:WPARAM,:LPARAM
INFODLGPROC     PROTO    :HWND,:UINT,:WPARAM,:LPARAM

INITIALIZE      PROTO    :HWND
KEYGENPROC      PROTO    :HWND

;.......................................................................
;
.const
    WM_DEFEATED   equ   WM_USER+1337h

;.......................................................................
; some variable data    
.data
    db  "We shall not cease from exploration,",0
    db  "and the end of all our exploring",0
    db  "will be to arrive where we started",0
    db  "and know the place for the first time.",0
    
.data?
    hInst            dd    ?
    hThreadID        dd    ?
    hEventStart      dd    ?
    
    hWndGlobal       dd    ?
    
    IF RELEASEDATA
    
    pReleaseData     LPCTSTR    ?       ; Release data
    
    ENDIF