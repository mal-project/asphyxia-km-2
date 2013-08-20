; THS (Tiny Hash Shit)
; A crappy hash scheme from Asphyxia motherfucker
; Asphx // FOFF
; foff.astalavista.ms

; 0.2.023
; 10:06 PM 12/12/2008

; initializes buffers, and set hash propieties
THS_INIT    proto    lptOutput:dword, ddHashSize:dword, ddRounds:dword
                                        ; lptOutput  : output buffer for hash (if null then VirtualAlloc is used)
                                        ; ddHashSize : hash size in dwords
                                        ; ddRounds   : rounds to do
                                            
                                        ; return pointer to buffer (initialized)
; hash given data
THS_HASH    proto    lptData:dword, ddDataLength:dword, lptOutput:dword
                                        ; lptData     : data to hash
                                        ; ddDataLenght: length of data to hash in bytes
                                        ; lptOutput   : output buffer (use THS_INIT to get an initialized buffer)
                                        
                                        ; return pointer to buffer (the hash); -1 if something bad
; clear THS data
THS_CLEAR   proto    