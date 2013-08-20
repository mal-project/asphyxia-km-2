; TES (Tiny Encryption Shit)
; A crappy encryption scheme from Asphyxia motherfucker
; Asphx // FOFF
; foff.astalavista.ms

; version 0.2.115
; 12:34 PM 12/12/2008

; Set key
TES_SETKEY  PROTO    :DWORD,:DWORD          ; lptKey, ddKeyBytes
                                            ; return in eax addr of key buffer
; Update S_BOX
TES_UPDATE  PROTO                           ; nothing
                                            ; return pointer to S_BOX if everything ok

; Encrypt lptData. ddDataBytes is data length in bytes.
TES_ENCRYPT PROTO    :DWORD,:DWORD,:DWORD,:DWORD
											; lptData, ddDataBytes, lptOutput, ddRounds
                                            ; return in eax pointer to encrypted data (if lptOutput is null then uses VirtualAlloc), -1 if something wrong
                                            ; return in edx length in dwords of encrypted data

; Decrypt lptData. ddDataBytes is data length in bytes.
TES_DECRYPT PROTO    :DWORD,:DWORD,:DWORD,:DWORD
											; lptData, ddDataBytes, lptOutput, ddRounds
                                            ; return in eax pointer to decrypted data (if lptOutput is null then uses VirtualAlloc); -1 if something wrong
                                            ; return in edx length in dwords of encrypted data

; Clear private_PBOX, private_SBOX, private_CIPHER and private_PLAIN
TES_CLEAR   PROTO                           ; nothing
                                            ; nothing