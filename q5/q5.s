    .text
    .globl main
    .extern open
    .extern read
    .extern lseek
    .extern close
    .extern printf

main:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)   # fd
    sd s1, 8(sp)    # left
    sd s2, 0(sp)    # right


    la a0, filename
    li a1, 0          # O_RDONLY
    call open
    mv s0, a0         # fd


    mv a0, s0
    li a1, 0
    li a2, 2          # SEEK_END
    call lseek

    addi s2, a0, -1   # right = size - 1
    li s1, 0          # left = 0

pal_loop:
    bge s1, s2, is_palindrome

    mv a0, s0
    mv a1, s1
    li a2, 0          # SEEK_SET
    call lseek

    mv a0, s0
    la a1, buf1
    li a2, 1
    call read

    lb t0, buf1


    mv a0, s0
    mv a1, s2
    li a2, 0
    call lseek

    mv a0, s0
    la a1, buf2
    li a2, 1
    call read

    lb t1, buf2


    bne t0, t1, not_palindrome

    addi s1, s1, 1
    addi s2, s2, -1
    j pal_loop


is_palindrome:
    la a0, yes_str
    call printf
    j done


not_palindrome:
    la a0, no_str
    call printf


done:
    mv a0, s0
    call close

    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    ret

    .data
filename:
    .asciz "input.txt"

yes_str:
    .asciz "Yes\n"

no_str:
    .asciz "No\n"

buf1:
    .byte 0

buf2:
    .byte 0