;[Death Virii Crew] Presents
;CHAOS A.D. Vmag, Issue 3, Autumn 1996 - Winter 1997

;------------------------------------- 0 -------------------------------------

_nop macro
db 0h
endm

_lxi_b macro oper16
db 1
dw oper16
endm

_stax_b macro
db 2
endm

_inx_b macro
db 3
endm

_inr_b macro
db 4
endm

_dcr_b macro
db 5
endm

_mvi_b macro oper8
db 6
db oper8
endm

_rlc macro
db 7
endm

_dad_b macro
db 9
endm

_ldax_b macro
db 0ah
endm

_dcx_b macro
db 0bh
endm

_inr_c macro
db 0ch
endm

_dcr_c macro
db 0dh
endm

_mvi_c macro oper8
db 0eh
db oper8
endm

_rrc macro
db 0fh
endm

;------------------------------------- 1 -------------------------------------

_lxi_d macro oper16
db 11h
dw oper16
endm

_stax_d macro
db 12h
endm

_inx_d macro
db 13h
endm

_inr_d macro
db 14h
endm

_dcr_d macro
db 15h
endm

_mvi_d macro oper8
db 16h
db oper8
endm

_ral macro
db 17h
endm

_dad_d macro
db 19h
endm

_ldax_d macro
db 1ah
endm

_dcx_d macro
db 1bh
endm

_inr_e macro
db 1ch
endm

_dcr_e macro
db 1dh
endm

_mvi_e macro oper8
db 1eh
db oper8
endm

_rar macro
db 1fh
endm

;------------------------------------- 2 -------------------------------------

_lxi_h macro oper16
db 21h
dw oper16
endm

_shld macro _addr16
db 22h
dw _addr16
endm

_inx_h macro
db 23h
endm

_inr_h macro
db 24h
endm

_dcr_h macro
db 25h
endm

_mvi_h macro oper8
db 26h
db oper8
endm

_daa macro
db 27h
endm

_dad_h macro
db 29h
endm

_lhld macro _addr16
db 2ah
dw _addr16
endm

_dcx_h macro
db 2bh
endm

_inr_l macro
db 2ch
endm

_dcr_l macro
db 2dh
endm

_mvi_l macro oper8
db 2eh
db oper8
endm

_cma macro
db 2fh
endm

;------------------------------------- 3 -------------------------------------

_lxi_sp macro oper16
db 31h
dw oper16
endm

_sta macro _addr16
db 32h
dw _addr16
endm

_inx_sp macro
db 33h
endm

_inr_m macro
db 34h
endm

_dcr_m macro
db 35h
endm

_mvi_m macro oper8
db 36h
db oper8
endm

_stc macro
db 37h
endm

_dad_sp macro
db 39h
endm

_lda macro _addr16
db 3ah
dw _addr16
endm

_dcx_sp macro
db 3bh
endm

_inr_a macro
db 3ch
endm

_dcr_a macro
db 3dh
endm

_mvi_a macro oper8
db 3eh
db oper8
endm

_cmc macro
db 3fh
endm

;------------------------------------- 4 -------------------------------------

_mov_b_b macro
db 40h
endm

_mov_b_c macro
db 41h
endm

_mov_b_d macro
db 42h
endm

_mov_b_e macro
db 43h
endm

_mov_b_h macro
db 44h
endm

_mov_b_l macro
db 45h
endm

_mov_b_m macro
db 46h
endm

_mov_b_a macro
db 47h
endm

_mov_c_b macro
db 48h
endm

_mov_c_c macro
db 49h
endm

_mov_c_d macro
db 4ah
endm

_mov_c_e macro
db 4bh
endm

_mov_c_h macro
db 4ch
endm

_mov_c_l macro
db 4dh
endm

_mov_c_m macro
db 4eh
endm

_mov_c_a macro
db 4fh
endm

;------------------------------------- 5 -------------------------------------

_mov_d_b macro
db 50h
endm

_mov_d_c macro
db 51h
endm

_mov_d_d macro
db 52h
endm

_mov_d_e macro
db 53h
endm

_mov_d_h macro
db 54h
endm

_mov_d_l macro
db 55h
endm

_mov_d_m macro
db 56h
endm

_mov_d_a macro
db 57h
endm

_mov_e_b macro
db 58h
endm

_mov_e_c macro
db 59h
endm

_mov_e_d macro
db 5ah
endm

_mov_e_e macro
db 5bh
endm

_mov_e_h macro
db 5ch
endm

_mov_e_l macro
db 5dh
endm

_mov_e_m macro
db 5eh
endm

_mov_e_a macro
db 5fh
endm

;------------------------------------- 6 -------------------------------------

_mov_h_b macro
db 60h
endm

_mov_h_c macro
db 61h
endm

_mov_h_d macro
db 62h
endm

_mov_h_e macro
db 63h
endm

_mov_h_h macro
db 64h
endm

_mov_h_l macro
db 65h
endm

_mov_h_m macro
db 66h
endm

_mov_h_a macro
db 67h
endm

_mov_l_b macro
db 68h
endm

_mov_l_c macro
db 69h
endm

_mov_l_d macro
db 6ah
endm

_mov_l_e macro
db 6bh
endm

_mov_l_h macro
db 6ch
endm

_mov_l_l macro
db 6dh
endm

_mov_l_m macro
db 6eh
endm

_mov_l_a macro
db 6fh
endm

;------------------------------------- 7 -------------------------------------

_mov_m_b macro
db 70h
endm

_mov_m_c macro
db 71h
endm

_mov_m_d macro
db 72h
endm

_mov_m_e macro
db 73h
endm

_mov_m_h macro
db 74h
endm

_mov_m_l macro
db 75h
endm

_hlt macro
db 76h
endm

_mov_m_a macro
db 77h
endm

_mov_a_b macro
db 78h
endm

_mov_a_c macro
db 79h
endm

_mov_a_d macro
db 7ah
endm

_mov_a_e macro
db 7bh
endm

_mov_a_h macro
db 7ch
endm

_mov_a_l macro
db 7dh
endm

_mov_a_m macro
db 7eh
endm

_mov_a_a macro
db 7fh
endm

;------------------------------------- 8 -------------------------------------

_add_b macro
db 80h
endm

_add_c macro
db 81h
endm

_add_d macro
db 82h
endm

_add_e macro
db 83h
endm

_add_h macro
db 84h
endm

_add_l macro
db 85h
endm

_add_m macro
db 86h
endm

_add_a macro
db 87h
endm

_adc_b macro
db 88h
endm

_adc_c macro
db 89h
endm

_adc_d macro
db 8ah
endm

_adc_e macro
db 8bh
endm

_adc_h macro
db 8ch
endm

_adc_l macro
db 8dh
endm

_adc_m macro
db 8eh
endm

_adc_a macro
db 8fh
endm

;------------------------------------- 9 -------------------------------------

_sub_b macro
db 90h
endm

_sub_c macro
db 91h
endm

_sub_d macro
db 92h
endm

_sub_e macro
db 93h
endm

_sub_h macro
db 94h
endm

_sub_l macro
db 95h
endm

_sub_m macro
db 96h
endm

_sub_a macro
db 97h
endm

_sbb_b macro
db 98h
endm

_sbb_c macro
db 99h
endm

_sbb_d macro
db 9ah
endm

_sbb_e macro
db 9bh
endm

_sbb_h macro
db 9ch
endm

_sbb_l macro
db 9dh
endm

_sbb_m macro
db 9eh
endm

_sbb_a macro
db 9fh
endm

;------------------------------------- A -------------------------------------

_ana_b macro
db 0a0h
endm

_ana_c macro
db 0a1h
endm

_ana_d macro
db 0a2h
endm

_ana_e macro
db 0a3h
endm

_ana_h macro
db 0a4h
endm

_ana_l macro
db 0a5h
endm

_ana_m macro
db 0a6h
endm

_ana_a macro
db 0a7h
endm

_xra_b macro
db 0a8h
endm

_xra_c macro
db 0a9h
endm

_xra_d macro
db 0aah
endm

_xra_e macro
db 0abh
endm

_xra_h macro
db 0ach
endm

_xra_l macro
db 0adh
endm

_xra_m macro
db 0aeh
endm

_xra_a macro
db 0afh
endm

;------------------------------------- B -------------------------------------

_ora_b macro
db 0b0h
endm

_ora_c macro
db 0b1h
endm

_ora_d macro
db 0b2h
endm

_ora_e macro
db 0b3h
endm

_ora_h macro
db 0b4h
endm

_ora_l macro
db 0b5h
endm

_ora_m macro
db 0b6h
endm

_ora_a macro
db 0b7h
endm

_cmp_b macro
db 0b8h
endm

_cmp_c macro
db 0b9h
endm

_cmp_d macro
db 0bah
endm

_cmp_e macro
db 0bbh
endm

_cmp_h macro
db 0bch
endm

_cmp_l macro
db 0bdh
endm

_cmp_m macro
db 0beh
endm

_cmp_a macro
db 0bfh
endm

;------------------------------------- C -------------------------------------

_rnz macro
db 0c0h
endm

_pop_b macro
db 0c1h
endm

_jnz macro addr16
db 0c2h
dw addr16
endm

_jmp macro addr16
db 0c3h
dw addr16
endm

_cnz macro addr16
db 0c4h
dw addr16
endm

_push_b macro
db 0c5h
endm

_adi macro oper8
db 0c6h
db oper8
endm

_rst_0 macro
db 0c7h
endm

_rz macro
db 0c8h
endm

_ret macro
db 0c9h
endm

_jz macro addr16
db 0cah
dw addr16
endm

_cz macro addr16
db 0cch
dw addr16
endm

_call macro addr16
db 0cdh
dw addr16
endm

_aci macro oper8
db 0ceh
db oper8
endm

_rst_1 macro
db 0cfh
endm

;------------------------------------- D -------------------------------------

_rnc macro
db 0d0h
endm

_pop_d macro
db 0d1h
endm

_jnc macro addr16
db 0d2h
dw addr16
endm

_out macro oper8
db 0d3h
db oper8
endm

_cnc macro addr16
db 0d4h
dw addr16
endm

_push_d macro
db 0d5h
endm

_sui macro oper8
db 0d6h
db oper8
endm

_rst_2 macro
db 0d7h
endm

_rc macro
db 0d8h
endm

_jc macro addr16
db 0dah
dw addr16
endm

_in macro oper8
db 0dbh
db oper8
endm

_cc macro addr16
db 0dch
dw addr16
endm

_sbi macro oper8
db 0deh
db oper8
endm

_rst_3 macro
db 0dfh
endm

;------------------------------------- E -------------------------------------

_rpo macro
db 0e0h
endm

_pop_h macro
db 0e1h
endm

_jpo macro addr16
db 0e2h
dw addr16
endm

_xthl macro
db 0e3h
endm

_cpo macro addr16
db 0e4h
dw addr16
endm

_push_h macro
db 0e5h
endm

_ani macro oper8
db 0e6h
db oper8
endm

_rst_4 macro
db 0e7h
endm

_rpe macro
db 0e8h
endm

_pchl macro
db 0e9h
endm

_jpe macro addr16
db 0eah
dw addr16
endm

_xchg macro
db 0ebh
endm

_cpe macro addr16
db 0ech
dw addr16
endm

_xri macro oper8
db 0eeh
db oper8
endm

_rst_5 macro
db 0efh
endm

;------------------------------------- F -------------------------------------

_rp macro
db 0f0h
endm

_pop_psw macro
db 0f1h
endm

_jp macro addr16
db 0f2h
dw addr16
endm

_di macro
db 0f3h
endm

_cp macro addr16
db 0f4h
dw addr16
endm

_push_psw macro
db 0f5h
endm

_ori macro oper8
db 0f6h
db oper8
endm

_rst_6 macro
db 0f7h
endm

_rm macro
db 0f8h
endm

_sphl macro
db 0f9h
endm

_jm macro addr16
db 0fah
dw addr16
endm

_ei macro
db 0fbh
endm

_cm macro addr16
db 0fch
dw addr16
endm

_cpi macro oper8
db 0feh
db oper8
endm

_rst_7 macro
db 0ffh
endm

; non used: 8h,10h,18h,20h,28h,30h,38h,0cbh,d9h,0ddh,0edh,0fdh


;						(c) by Reminder [DVC]

