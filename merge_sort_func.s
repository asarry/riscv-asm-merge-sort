    .text
    .globl merge_sort_asm

merge_sort_asm:
    /* if (lower_index < higher_index) */
    bge a1, a2, merge_sort_end
    /* get some place on the stack for the indexes and m */
    addi sp, sp, -20
    /* save the return register */
    sw ra, 16(sp)

    /* save the indexes and m */
    sw t0, 12(sp)
    sw a2, 8(sp)
    sw a1, 4(sp)
    sw a0, 0(sp)
    /* t0 = higher_index - lower_index */
    sub t0, a2, a1
    /* t0 = (higher_index - lower_index) / 2 */
    srl t0, t0, 1
    /* t0 = m = lower_index + (higher_index - lower_index) / 2 */
    add t0, a1, t0

    /* first recursion */
    /* sets the right args */
    mv a2, t0
    jal merge_sort_asm
    /* second recursion */
    lw a2, 8(sp)
    /* sets the right args */
    /* t1 = m + 1 */
    addi t1, t0, 1
    mv a1, t1
    jal merge_sort_asm

    /* sets the right args */
    lw a1, 4(sp)
    mv a3, a2
    mv a2, a1
    mv a1, t0
    /* merge */
    j merge_func
    mv a0, zero

merge_sort_end:
    ret


merge_func:
/* a0 = array
 * a1 = m
 * a2 = lower_index
 * a3 = higher_index
 * t0 = i
 * t1 = j
 * t2 = k
 * t3 = left_length
 * t4 = right_length
 */
    mv s0, zero
    /* left_length = m - lower_index + 1 */
    sub t3, a1, a2
    addi t3, t3, 1
    /* right_length = higher_index - m */
    sub t4, a3, a1

    /* create a temporary array on the stack */
    /* t5 = left_length + right_length*/
    add t5, t3, t4
    slli t5, t5, 2
    sub sp, sp, t5
    mv t5, zero

    /* copy the original array into the temporary one */
    /* i = j = 0 */
    mv t0, zero
    mv t1, zero

    /* for (i = 0; i < left_length; i++) */
copy1:
    /* exit condition */
    bge t0, t3, copy2
    /* t5 = lower_index + i */
    add t5, a2, t0
    /* t6 = array[lower_index + i] */
    slli s0, t5, 2
    add s0, a0, s0
    lw t6, 0(s0)
    /* sp = left[i] */
    slli s0, t0, 2
    add s0, sp, s0
    sw t6, 0(s0)
    /* i++ */
    addi t0, t0, 1
    j copy1

    /* for (j = 0; j < right_length; j++) */
copy2:
    /* exit condition */
    bge t1, t4, merge
    /* t5 = m + 1 + j */
    mv t5, a1
    addi t5, t5, 1
    add t5, t5, t1
    /* t6 = array[m + 1 + j] */
    slli s0, t5, 2
    add s0, a0, s0
    lw t6, 0(s0)
    /* sp = right[left_length + j] */
    add s0, t3, t1
    slli s0, s0, 2
    add s0, sp, s0
    sw t6, 0(s0)
    /* j++ */
    addi t1, t1, 1
    j copy2

merge:
    /* i = j = 0 */
    mv t0, zero
    mv t1, zero
    mv t2, a2
    /* k = lower_index */

while:
    /* t5 = i < left_length */
    slt t5, t0, t3
    /* t6 = j < right_length */
    slt t6, t1, t4
    /* t5 = t5 and t6 */
    and t5, t5, t6
    /* condition */
    beqz t5, copy_remaining_left
    /* t5 = left[i] */
    slli s0, t0, 2
    add s0, sp, s0
    lw t5, 0(s0)
    /* t6 = right[j+left_length] */
    add s0, t1, t3
    slli s0, s0, 2
    add s0, sp, s0
    lw t6, 0(s0)

    /* if (left[i] <= right[j]) */
    bgt t5, t6, else
    /* array[k] = left[i] */
    slli s0, t2, 2
    add s0, a0, s0
    sw t5, 0(s0)
    /* i++ */
    addi t0, t0, 1
    /* k++ */
    addi t2, t2, 1
    j while

else:
    /* array[k] = right[j] */
    slli s0, t2, 2
    add s0, a0, s0
    sw t6, 0(s0)
    /* j++ */
    addi t1, t1, 1
    /* k++ */
    addi t2, t2, 1
    j while

copy_remaining_left:
    /* t5 = i < left_length */
    slt t5, t0, t3
    /* condition */
    beqz t5, copy_remaining_right
    /* t5 = left[i] */
    slli s0, t0, 2
    add s0, sp, s0
    lw t5, 0(s0)
    /* array[k] = left[i] */
    slli s0, t2, 2
    add s0, a0, s0
    sw t5, 0(s0)

    /* i++ */
    addi t0, t0, 1
    /* k++ */
    addi t2, t2, 1
    j copy_remaining_left

copy_remaining_right:
    /* t5 = j < right_length */
    slt t5, t1, t4
    /* condition */
    beqz t5, merge_end
    /* t5 = right[j+left_length] */
    add s0, t1, t3
    slli s0, s0, 2
    add s0, sp, s0
    lw t5, 0(s0)
    /* array[k] = right[j] */
    slli s0, t2, 2
    add s0, a0, s0
    sw t5, 0(s0)

    /* j++ */
    addi t1, t1, 1
    /* k++ */
    addi t2, t2, 1
    j copy_remaining_right

merge_end:
    /* unstack the array copy */
    mv t5, zero
    add t5, t3, t4
    slli t5, t5, 2
    add sp, sp, t5
    mv t5, zero
    /* unstack args */
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, +20
    ret

