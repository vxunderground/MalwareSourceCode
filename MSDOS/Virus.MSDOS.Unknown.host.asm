

                .model  tiny

                .code

;******************************************************************************
;The host program starts here. This one is a dummy that just returns control
;to DOS.
                public  HOST

                db      100 dup (0)
HOST:
                mov     ax,4C00H                ;Terminate, error code = 0
                int     21H

HOST_END:

                END
