/*
 * MUSCLE SmartCard Development ( https://pcsclite.apdu.fr/ )
 *
 * Copyright (C) 1999-2004
 *  David Corcoran <corcoran@musclecard.com>
 * Copyright (C) 2002-2011
 *  Ludovic Rousseau <ludovic.rousseau@free.fr>
 * Copyright (C) 2005
 *  Martin Paljak <martin@paljak.pri.ee>
 *
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
 
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
#ifndef __pcsclite_h__
#define __pcsclite_h__
 
#include "wintypes.h"
 
#ifdef __cplusplus
extern "C"
{
#endif
 
typedef LONG SCARDCONTEXT; 
typedef SCARDCONTEXT *PSCARDCONTEXT;
typedef SCARDCONTEXT *LPSCARDCONTEXT;
typedef LONG SCARDHANDLE; 
typedef SCARDHANDLE *PSCARDHANDLE;
typedef SCARDHANDLE *LPSCARDHANDLE;
 
#define MAX_ATR_SIZE            33  
/* Set structure elements alignment on bytes
 * http://gcc.gnu.org/onlinedocs/gcc/Structure_002dPacking-Pragmas.html */
#ifdef __APPLE__
#pragma pack(1)
#endif
 
typedef struct
{
    const char *szReader;
    void *pvUserData;
    DWORD dwCurrentState;
    DWORD dwEventState;
    DWORD cbAtr;
    unsigned char rgbAtr[MAX_ATR_SIZE];
}
SCARD_READERSTATE, *LPSCARD_READERSTATE;
 
typedef struct
{
    unsigned long dwProtocol;   
    unsigned long cbPciLength;  
}
SCARD_IO_REQUEST, *PSCARD_IO_REQUEST, *LPSCARD_IO_REQUEST;
 
typedef const SCARD_IO_REQUEST *LPCSCARD_IO_REQUEST;
 
extern const SCARD_IO_REQUEST g_rgSCardT0Pci, g_rgSCardT1Pci, g_rgSCardRawPci;
 
/* restore default structure elements alignment */
#ifdef __APPLE__
#pragma pack()
#endif
 
#define SCARD_PCI_T0    (&g_rgSCardT0Pci) 
#define SCARD_PCI_T1    (&g_rgSCardT1Pci) 
#define SCARD_PCI_RAW   (&g_rgSCardRawPci) 
#define SCARD_S_SUCCESS         ((LONG)0x00000000) 
#define SCARD_F_INTERNAL_ERROR      ((LONG)0x80100001) 
#define SCARD_E_CANCELLED       ((LONG)0x80100002) 
#define SCARD_E_INVALID_HANDLE      ((LONG)0x80100003) 
#define SCARD_E_INVALID_PARAMETER   ((LONG)0x80100004) 
#define SCARD_E_INVALID_TARGET      ((LONG)0x80100005) 
#define SCARD_E_NO_MEMORY       ((LONG)0x80100006) 
#define SCARD_F_WAITED_TOO_LONG     ((LONG)0x80100007) 
#define SCARD_E_INSUFFICIENT_BUFFER ((LONG)0x80100008) 
#define SCARD_E_UNKNOWN_READER      ((LONG)0x80100009) 
#define SCARD_E_TIMEOUT         ((LONG)0x8010000A) 
#define SCARD_E_SHARING_VIOLATION   ((LONG)0x8010000B) 
#define SCARD_E_NO_SMARTCARD        ((LONG)0x8010000C) 
#define SCARD_E_UNKNOWN_CARD        ((LONG)0x8010000D) 
#define SCARD_E_CANT_DISPOSE        ((LONG)0x8010000E) 
#define SCARD_E_PROTO_MISMATCH      ((LONG)0x8010000F) 
#define SCARD_E_NOT_READY       ((LONG)0x80100010) 
#define SCARD_E_INVALID_VALUE       ((LONG)0x80100011) 
#define SCARD_E_SYSTEM_CANCELLED    ((LONG)0x80100012) 
#define SCARD_F_COMM_ERROR      ((LONG)0x80100013) 
#define SCARD_F_UNKNOWN_ERROR       ((LONG)0x80100014) 
#define SCARD_E_INVALID_ATR     ((LONG)0x80100015) 
#define SCARD_E_NOT_TRANSACTED      ((LONG)0x80100016) 
#define SCARD_E_READER_UNAVAILABLE  ((LONG)0x80100017) 
#define SCARD_P_SHUTDOWN        ((LONG)0x80100018) 
#define SCARD_E_PCI_TOO_SMALL       ((LONG)0x80100019) 
#define SCARD_E_READER_UNSUPPORTED  ((LONG)0x8010001A) 
#define SCARD_E_DUPLICATE_READER    ((LONG)0x8010001B) 
#define SCARD_E_CARD_UNSUPPORTED    ((LONG)0x8010001C) 
#define SCARD_E_NO_SERVICE      ((LONG)0x8010001D) 
#define SCARD_E_SERVICE_STOPPED     ((LONG)0x8010001E) 
#define SCARD_E_UNEXPECTED      ((LONG)0x8010001F) 
#define SCARD_E_UNSUPPORTED_FEATURE ((LONG)0x8010001F) 
#define SCARD_E_ICC_INSTALLATION    ((LONG)0x80100020) 
#define SCARD_E_ICC_CREATEORDER     ((LONG)0x80100021) 
/* #define SCARD_E_UNSUPPORTED_FEATURE  ((LONG)0x80100022) / **< This smart card does not support the requested feature. */
#define SCARD_E_DIR_NOT_FOUND       ((LONG)0x80100023) 
#define SCARD_E_FILE_NOT_FOUND      ((LONG)0x80100024) 
#define SCARD_E_NO_DIR          ((LONG)0x80100025) 
#define SCARD_E_NO_FILE         ((LONG)0x80100026) 
#define SCARD_E_NO_ACCESS       ((LONG)0x80100027) 
#define SCARD_E_WRITE_TOO_MANY      ((LONG)0x80100028) 
#define SCARD_E_BAD_SEEK        ((LONG)0x80100029) 
#define SCARD_E_INVALID_CHV     ((LONG)0x8010002A) 
#define SCARD_E_UNKNOWN_RES_MSG     ((LONG)0x8010002B) 
#define SCARD_E_UNKNOWN_RES_MNG     SCARD_E_UNKNOWN_RES_MSG
#define SCARD_E_NO_SUCH_CERTIFICATE ((LONG)0x8010002C) 
#define SCARD_E_CERTIFICATE_UNAVAILABLE ((LONG)0x8010002D) 
#define SCARD_E_NO_READERS_AVAILABLE    ((LONG)0x8010002E) 
#define SCARD_E_COMM_DATA_LOST      ((LONG)0x8010002F) 
#define SCARD_E_NO_KEY_CONTAINER    ((LONG)0x80100030) 
#define SCARD_E_SERVER_TOO_BUSY     ((LONG)0x80100031) 
#define SCARD_W_UNSUPPORTED_CARD    ((LONG)0x80100065) 
#define SCARD_W_UNRESPONSIVE_CARD   ((LONG)0x80100066) 
#define SCARD_W_UNPOWERED_CARD      ((LONG)0x80100067) 
#define SCARD_W_RESET_CARD      ((LONG)0x80100068) 
#define SCARD_W_REMOVED_CARD        ((LONG)0x80100069) 
#define SCARD_W_SECURITY_VIOLATION  ((LONG)0x8010006A) 
#define SCARD_W_WRONG_CHV       ((LONG)0x8010006B) 
#define SCARD_W_CHV_BLOCKED     ((LONG)0x8010006C) 
#define SCARD_W_EOF         ((LONG)0x8010006D) 
#define SCARD_W_CANCELLED_BY_USER   ((LONG)0x8010006E) 
#define SCARD_W_CARD_NOT_AUTHENTICATED  ((LONG)0x8010006F) 
#define SCARD_AUTOALLOCATE (DWORD)(-1)  
#define SCARD_SCOPE_USER        0x0000  
#define SCARD_SCOPE_TERMINAL        0x0001  
#define SCARD_SCOPE_SYSTEM      0x0002  
#define SCARD_SCOPE_GLOBAL      0x0003  
#define SCARD_PROTOCOL_UNDEFINED    0x0000  
#define SCARD_PROTOCOL_UNSET SCARD_PROTOCOL_UNDEFINED   /* backward compat */
#define SCARD_PROTOCOL_T0       0x0001  
#define SCARD_PROTOCOL_T1       0x0002  
#define SCARD_PROTOCOL_RAW      0x0004  
#define SCARD_PROTOCOL_T15      0x0008  
#define SCARD_PROTOCOL_ANY      (SCARD_PROTOCOL_T0|SCARD_PROTOCOL_T1)   
#define SCARD_SHARE_EXCLUSIVE       0x0001  
#define SCARD_SHARE_SHARED      0x0002  
#define SCARD_SHARE_DIRECT      0x0003  
#define SCARD_LEAVE_CARD        0x0000  
#define SCARD_RESET_CARD        0x0001  
#define SCARD_UNPOWER_CARD      0x0002  
#define SCARD_EJECT_CARD        0x0003  
#define SCARD_UNKNOWN           0x0001  
#define SCARD_ABSENT            0x0002  
#define SCARD_PRESENT           0x0004  
#define SCARD_SWALLOWED         0x0008  
#define SCARD_POWERED           0x0010  
#define SCARD_NEGOTIABLE        0x0020  
#define SCARD_SPECIFIC          0x0040  
#define SCARD_STATE_UNAWARE     0x0000  
#define SCARD_STATE_IGNORE      0x0001  
#define SCARD_STATE_CHANGED     0x0002  
#define SCARD_STATE_UNKNOWN     0x0004  
#define SCARD_STATE_UNAVAILABLE     0x0008  
#define SCARD_STATE_EMPTY       0x0010  
#define SCARD_STATE_PRESENT     0x0020  
#define SCARD_STATE_ATRMATCH        0x0040  
#define SCARD_STATE_EXCLUSIVE       0x0080  
#define SCARD_STATE_INUSE       0x0100  
#define SCARD_STATE_MUTE        0x0200  
#define SCARD_STATE_UNPOWERED       0x0400  
#ifndef INFINITE
#define INFINITE            0xFFFFFFFF  
#endif
 
#define PCSCLITE_VERSION_NUMBER     "2.0.3" 
#define PCSCLITE_MAX_READERS_CONTEXTS           16
 
#define MAX_READERNAME          128
 
#ifndef SCARD_ATR_LENGTH
#define SCARD_ATR_LENGTH        MAX_ATR_SIZE    
#endif
 
/*
 * The message and buffer sizes must be multiples of 16.
 * The max message size must be at least large enough
 * to accommodate the transmit_struct
 */
#define MAX_BUFFER_SIZE         264 
#define MAX_BUFFER_SIZE_EXTENDED    (4 + 3 + (1<<16) + 3 + 2)   
/*
 * Gets a stringified error response
 */
const char *pcsc_stringify_error(const LONG);
 
#ifdef __cplusplus
}
#endif
 
#endif