; template v.1.7 (release)
;.......................................................................
include     TES.inc                         ; Tiny Encryption Shit (yeah i did it)
includelib  TES.lib

include     THS.inc                         ; Tiny Hash Shit (this crapp too)
includelib  THS.lib

;.......................................................................
.const

    szSUCCESSTITLE  db "Congratulations!",0
    szSUCCESSTEXT   db "You just defeated this protection.",13,10
                    db "Now you should share your knowledge with others.",13,10
                    db "Make a tutorial on how you reverse it.",0
    
    szFORMAT        db "%.8X%.8X",0         ; to print volume/random ID
    szROOTPATH      db "c:\",0              ; to get volume serial

.data
    ddNameLen       dd ?                    ; to check for name length
    ddSerialLen     dd ?                    ; idem but with serial lol
    
    hHashID         dd 2    dup(?)          ; 2 dword hash over volume serial and 05F6A55E0h
    szHashID        dd 4    dup(?)          ; to print
    
    szName          db 34   dup(?)          ; user name
    szSerial        db 34   dup(?)          ; his serial (usually bad :P)

    hSerialHex      db 17   dup(?)          ; serial in hex

;.......................................................................
.code
__KEYGEN__  proc    hWnd:dword
    local   FLAG   :dword
    pushad
    ; Hash(szName) == Encrypt(hSerialHex,Hash(hardID))
    
    ;--------------------------------------------------------------
    ; Hashing szName
    invoke  THS_INIT, 0, 4, 1               ; initializing vectors (virtual allocate, 4 dwords, 1 round)
                                            
                                            ; hash name, length name, initialized buffer
    invoke  THS_HASH, addr szName, dword ptr ddNameLen, eax
    push    eax
    
    ;--------------------------------------------------------------
    ; Encrypting szSerialHex with hHashID as key
    invoke  TES_SETKEY, addr hHashID, 8     ; hHashId, 8 bytes
    
    invoke  TES_UPDATE                      ; updating S_Box
                                            
                                            ; encrypt hSerialHex, 16 bytes, virtual allocate, 4 rounds
    invoke  TES_ENCRYPT, addr hSerialHex, 16, 0, 4
    push    eax

    ;--------------------------------------------------------------
    ; comparing
    pop     edi                             ; * hSerialHex encrypted
    pop     esi                             ; * NameHash
    
    mov     ecx,4
    repe    cmpsd                           ; compares dwords until different dec ecx
    setz    byte ptr FLAG                   ; if zero fucking cool

    invoke  TES_CLEAR                       ; cleaning encryption shit
    invoke  THS_CLEAR                       ; cleaning hash shit
    
    popad
    
    mov     eax,FLAG
    ret
__KEYGEN__ endp

;.......................................................................
__TOHEX__   proc    lptData:DWORD, ddDataLength:DWORD, lptOutput:DWORD
    ; return -1 if can not run out all the string (cuz some char isnt 0..9, A..F)
    local    ddRESULT    :dword
    local    ddLENGTH    :dword
    pushad

    mov     edi,dword ptr lptData
    mov     esi,dword ptr lptOutput
    
    mov     eax,dword ptr ddDataLength      ; we'll obtain lenght/2
    xor     edx,edx
    mov     ecx,2
    idiv    ecx
    mov     dword ptr ddLENGTH,eax
    
    xor     eax,eax                         ; counter
    xor     ecx,ecx
    
    .while  (eax <= dword ptr ddLENGTH)

        mov     edx,dword ptr [edi]         ; data (dword)
        
        xor     ebx,ebx
        .repeat
            
            .if (dl >= "0") && (dl <= "9") || dl==0
                
                sub     dl,30h              ; 39h - 30h = 9h

            .elseif (dl >= "A") && (dl <= "F")
            
                sub     dl,37h              ; 42h - 38h = Ah
                
            .else

                xor     edx,edx
                dec     edx
                
            .endif
            
            .break  .if edx == -1
            
            inc     ebx
            rol     edx,8
            
        .until ebx == 4
        
        .break  .if edx == -1

        xor     ebx,ebx
        xor     ecx,ecx
        .repeat
            
            add     bl,dl
            ror     edx,8
            rol     ebx,4
        
            inc     ecx
        .until  ecx == 3
        
        add     bl,dl
        xchg    bl,bh
        mov     word ptr [esi+eax],bx
    
        .break  .if eax == dword ptr ddLENGTH
        add     eax,2
        add     edi,4
    .endw

    sub     eax,dword ptr ddLENGTH
    .if SIGN?                               ; ecx > eax?
        
        xor     eax,eax
        dec     eax
    
        mov     dword ptr ddLENGTH, eax
        
    .endif

    popad
    
    mov     eax,dword ptr ddLENGTH
    ret

__TOHEX__    endp

;.......................................................................
KEYGENPROC  proc    hWnd:DWORD

    invoke  WaitForSingleObject, hEventStart, -1; waiting to start
    
    invoke  SendDlgItemMessage, hWndGlobal, IDE_SERIAL, WM_GETTEXT, sizeof szSerial, addr szSerial
    
    .if eax == MIN_SERIALLEN
        
                                            ; convert serial string to hex (ie: "1234ABF" -> 1234ABFh)
        invoke  __TOHEX__, addr szSerial, eax, addr hSerialHex
                                            ; return in eax -1 if some char isnt hex one (upcase) (<30 and >39 <41 and >46)

        mov     dword ptr ddSerialLen, eax  ; however, serial must be 32 chars long!

        or      eax,eax
        .if !SIGN?
                
            invoke  SendDlgItemMessage, hWndGlobal, IDE_NAME, WM_GETTEXT, sizeof szName, addr szName

            mov     dword ptr ddNameLen,eax

                                            ; checking name len    
            .if eax >= MIN_NAMELEN && eax <= MAX_NAMELEN

                invoke  __KEYGEN__, hWndGlobal

                .if al != 0
                
                    invoke  PostMessage, hWndGlobal, WM_DEFEATED, 0, 0
                
                .endif                

            .endif
            
        .endif
    
    .endif
    
    jmp     KEYGENPROC
    ret
KEYGENPROC endp

;.......................................................................
INITIALIZE    proc    hWnd:dword
    local    pFileSystemFlag    :dword
    local    pMaxFilenameLength :dword
    local    dummy              :dword
    local    pVolumeSerialNumber:dword

    pushad    
    ;---------------------------------------------------------------    
    ; making the volume serial/random ID hash
    invoke  GetVolumeInformation, addr szROOTPATH, 0, 0, addr pVolumeSerialNumber, addr pMaxFilenameLength, addr pFileSystemFlag, 0, 0

    ;---------------------------------------------------------------    
    ; hashing volume serial/random ID
    invoke  THS_INIT, 0, 2, 1               ; initializing vectors

    mov     dword ptr dummy, 05F6A55E0h
    invoke  THS_HASH, addr pVolumeSerialNumber, 8, eax
    
    ;---------------------------------------------------------------    
    ; saving the hash
    mov     edx,dword ptr [eax+4]
    mov     dword ptr [hHashID+4],edx
    mov     edx,dword ptr [eax]
    mov     dword ptr [hHashID],edx

    invoke  THS_CLEAR                       ; cleaning this shit

    ;---------------------------------------------------------------        
    ; getting some randomness
    invoke  nseed
    invoke  nrandom, -1
    xor     dword ptr [hHashID+4],eax
    invoke  nrandom, -1
    xor     dword ptr [hHashID],eax    
    
    ;---------------------------------------------------------------    
    ; formating for printing
    mov     edx,dword ptr [hHashID+4]
    bswap   edx
    push    edx
    
    mov     edx,dword ptr [hHashID]
    bswap   edx
    push    edx

    push    offset szFORMAT
    push    offset szHashID
    call    wsprintf                        ; printing hash
    add     esp,010h
    
    ;---------------------------------------------------------------    
    ; requesting
    invoke  SendDlgItemMessage, hWnd, IDE_RANDOM, WM_SETTEXT, 0, addr szHashID
    
    ;---------------------------------------------------------------    
    ; Get name user
    mov     dword ptr ddNameLen, MAX_NAMELEN
    invoke  GetUserName, addr szName, addr ddNameLen
    invoke  SendDlgItemMessage, hWnd, IDE_NAME, WM_SETTEXT, 0, addr szName
    
    popad
    ret
INITIALIZE    endp
