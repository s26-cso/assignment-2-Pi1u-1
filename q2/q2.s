.section .data
fmt_int:   .string "%d"
fmt_space: .string " "
fmt_nl:    .string "\n"

.section .bss
arr:    .space 400  # up to 100 ints
result: .space 400
stk:    .space 400  # monotone stack of indices

.section .text
.globl main

main:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)  # n
    sd s1, 40(sp)  # loop index i
    sd s2, 32(sp)  # (free)
    sd s3, 24(sp)  # arr[i] during nge
    sd s4, 16(sp)  # stack top
    sd s5,  8(sp)  # i for nge loop
    sd s6,  0(sp)  # argv

    addi s0, a0, -1     # n = argc - 1
    mv s6, a1         # argv

    li s1, 0
parse_loop:
    bge s1, s0, parse_done
    slli t0, s1, 3
    addi t0, t0, 8   # byte offset: skip argv[0] (8 bytes per ptr)
    add t0, s6, t0
    ld a0, 0(t0)  # a0 = pointer to argv[i+1] string
    call atoi
    la t0, arr
    slli t1, s1, 2
    add t0, t0, t1
    sw a0, 0(t0)  # arr[i] = atoi result
    addi s1, s1, 1
    j parse_loop
parse_done:

    li s1, 0
init_loop:
    bge s1, s0, init_done
    la t0, result
    slli t1, s1, 2
    add t0, t0, t1
    li t1, -1
    sw t1, 0(t0)
    addi s1, s1, 1
    j init_loop
init_done:

    li s4, -1   # stack top (-1 = empty)
    addi s5, s0, -1  # i = n - 1

nge_loop:
    blt s5, zero, nge_done

    la t0, arr
    slli t1, s5, 2
    add t0, t0, t1
    lw s3, 0(t0)

pop_loop:
    blt s4, zero, pop_done
    la t0, stk
    slli t1, s4, 2
    add t0, t0, t1
    lw t2, 0(t0)   # t2 = stk.top() (an index into arr)
    la t3, arr
    slli t4, t2, 2
    add t3, t3, t4
    lw t3, 0(t3)   # t3 = arr[stk.top()]
    bgt t3, s3, pop_done   # strictly greater → stop popping
    addi s4, s4, -1
    j pop_loop
pop_done:

    blt s4, zero, do_push
    la t0, stk
    slli t1, s4, 2
    add t0, t0, t1
    lw t2, 0(t0)   # t2 = stk.top()
    la t0, result
    slli t1, s5, 2
    add t0, t0, t1
    sw t2, 0(t0)  # result[i] = stk.top()

do_push:
    addi s4, s4, 1
    la t0, stk
    slli t1, s4, 2
    add t0, t0, t1
    sw s5, 0(t0)  # stk.push(i)

    addi s5, s5, -1
    j nge_loop
nge_done:

    li s1, 0
print_loop:
    bge s1, s0, print_done

    la t0, result
    slli t1, s1, 2
    add t0, t0, t1
    lw a1, 0(t0)
    la a0, fmt_int
    call printf

    addi t0, s1, 1
    bge t0, s0, skip_space
    la a0, fmt_space
    call printf
skip_space:
    addi s1, s1, 1
    j print_loop
print_done:

    la a0, fmt_nl
    call printf

    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    ld s4, 16(sp)
    ld s5,  8(sp)
    ld s6,  0(sp)
    addi sp, sp, 64
    li a0, 0
    ret