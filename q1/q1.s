# q1.s — Binary Search Tree in RISC-V Assembly

# struct Node {
#   int val;        (offset 0)
#   padding         (offset 4)
#   Node* left;     (offset 8)
#   Node* right;    (offset 16)
# } size = 24

    .text
    .globl make_node
make_node:
    addi sp, sp, -16
    sw ra, 8(sp)
    sw s0, 0(sp)  

    mv s0, a0         # save val

    li a0, 24
    call malloc       # a0 = new node

    sw s0, 0(a0)      # node->val = val
    sw zero, 8(a0)    # node->left = NULL
    sw zero, 16(a0)   # node->right = NULL

    lw ra, 8(sp)
    lw s0, 0(sp)
    addi sp, sp, 16
    ret

    .globl insert
insert:
    addi sp, sp, -32
    sw ra, 24(sp)
    sw s0, 16(sp)   # root
    sw s1, 8(sp)    # val

    mv s0, a0
    mv s1, a1

    # if root == NULL → create node
    bne s0, zero, insert_normal
    mv a0, s1
    call make_node
    j insert_done

insert_normal:
    lw t0, 0(s0)       # root->val

    blt s1, t0, go_left
    bgt s1, t0, go_right

    # equal → do nothing
    mv a0, s0
    j insert_done

go_left:
    lw a0, 8(s0)       # root->left
    mv a1, s1
    call insert
    sw a0, 8(s0)       # update left
    mv a0, s0
    j insert_done

go_right:
    lw a0, 16(s0)      # root->right
    mv a1, s1
    call insert
    sw a0, 16(s0)      # update right
    mv a0, s0

insert_done:
    lw ra, 24(sp)
    lw s0, 16(sp)
    lw s1, 8(sp)
    addi sp, sp, 32
    ret

    .globl get
get:
    beq a0, zero, get_done

    lw t0, 0(a0)     # root->val

    beq a1, t0, get_done
    blt a1, t0, get_left

get_right:
    lw a0, 16(a0)
    j get

get_left:
    lw a0, 8(a0)
    j get

get_done:
    ret

    .globl getAtMost
getAtMost:
    addi sp, sp, -24
    sw ra, 16(sp)
    sw s0, 8(sp)    # val
    sw s1, 0(sp)    # root

    mv s0, a0       # val
    mv s1, a1       # root

    li t0, -1       # answer = -1

loop_atmost:
    beq s1, zero, done_atmost

    lw t1, 0(s1)    # curr = root->val

    bgt t1, s0, go_left_atmost

    # valid candidate
    mv t0, t1
    lw s1, 16(s1)   # go right
    j loop_atmost

go_left_atmost:
    lw s1, 8(s1)
    j loop_atmost

done_atmost:
    mv a0, t0

    lw ra, 16(sp)
    lw s0, 8(sp)
    lw s1, 0(sp)
    addi sp, sp, 24
    ret
