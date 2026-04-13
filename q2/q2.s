    .text
    .globl main
    .extern atoi
    .extern printf

# Registers:
# s0 → n
# s1 → arr base
# s2 → result base
# s3 → stack base
# s4 → stack top index

main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    sd s4, 0(sp)

    addi s0, a0, -1       # n = argc - 1
    mv t0, a1           # argv

    # allocate arr (n * 4)
    slli a0, s0, 2
    call malloc
    mv s1, a0

    # allocate result
    slli a0, s0, 2
    call malloc
    mv s2, a0

    # allocate stack (n * 4 for indices)
    slli a0, s0, 2
    call malloc
    mv s3, a0

    li s4, -1           # stack top = -1


    li t1, 1              # i = 1

parse_loop:
    bgt t1, s0, parse_done

    slli t2, t1, 3        # argv[i]
    add t3, t0, t2
    ld a0, 0(t3)
    call atoi

    addi t4, t1, -1
    slli t4, t4, 2
    add t5, s1, t4
    sw a0, 0(t5)

    addi t1, t1, 1
    j parse_loop

parse_done:


    li t1, 0

init_loop:
    bge t1, s0, nge_start
    slli t2, t1, 2
    add t3, s2, t2
    li t4, -1
    sw t4, 0(t3)
    addi t1, t1, 1
    j init_loop


nge_start:
    addi t1, s0, -1       # i = n-1

nge_loop:
    blt t1, zero, print_result

    # current value = arr[i]
    slli t2, t1, 2
    add t3, s1, t2
    lw t4, 0(t3)

nge_pop:
    blt s4, zero, nge_check

    # top index
    slli t5, s4, 2
    add t6, s3, t5
    lw t7, 0(t6)

    # arr[top]
    slli t8, t7, 2
    add t9, s1, t8
    lw t10, 0(t9)

    ble t10, t4, pop_stack
    j nge_check

pop_stack:
    addi s4, s4, -1
    j nge_pop

nge_check:
    blt s4, zero, push_stack

    # result[i] = stack[top]
    slli t5, s4, 2
    add t6, s3, t5
    lw t7, 0(t6)

    slli t8, t1, 2
    add t9, s2, t8
    sw t7, 0(t9)

push_stack:
    addi s4, s4, 1
    slli t5, s4, 2
    add t6, s3, t5
    sw t1, 0(t6)

    addi t1, t1, -1
    j nge_loop


print_result:
    li t1, 0

print_loop:
    bge t1, s0, done

    slli t2, t1, 2
    add t3, s2, t2
    lw a1, 0(t3)

    la a0, fmt
    call printf

    addi t1, t1, 1
    j print_loop

done:
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    ld s4, 0(sp)
    addi sp, sp, 48
    ret


    .data
fmt:
    .asciz "%d "