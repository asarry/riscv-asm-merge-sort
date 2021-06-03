    .text
    .globl tri_fusion_as

tri_fusion_as:
    /* if (indice_bas < indice_haut) */
    bge a1, a2, tri_fusion_end
    /* réserve de la place dans le stack pour les indices et m */
    addi sp, sp, -20
    /* sauvegarde la return adresse */
    sw ra, 16(sp)

    /* sauvegardes les indices et m */
    sw t0, 12(sp)
    sw a2, 8(sp)
    sw a1, 4(sp)
    sw a0, 0(sp)
    /* t0 = indice_haut - indice_bas*/
    sub t0, a2, a1
    /* t0 = (indice_haut - indice_bas) / 2 */
    srl t0, t0, 1
    /* t0 = m = indice_bas + (indice_haut - indice_bas) / 2 */
    add t0, a1, t0

    /* récursion 1 */
    /* met en place les bons arguments */
    mv a2, t0
    jal tri_fusion_as
    /* récursion 2 */
    lw a2, 8(sp)
    /* met en place les bons arguments */
    /* t1 = m + 1 */
    addi t1, t0, 1
    mv a1, t1
    jal tri_fusion_as

    /* préparation des arguments de fusion */
    lw a1, 4(sp)
    mv a3, a2
    mv a2, a1
    mv a1, t0
    /* fusion */
    j fct_fusion
    mv a0, zero

tri_fusion_end:
    ret


fct_fusion:
/* a0 = tableau
 * a1 = m
 * a2 = indice_bas
 * a3 = indice_haut
 * t0 = i
 * t1 = j
 * t2 = k
 * t3 = longueur_gauche
 * t4 = longueur_droite
 */
    mv s0, zero
    /* longueur_gauche = m - indice_bas + 1 */
    sub t3, a1, a2
    addi t3, t3, 1
    /* longueur_droite = indice_haut - m */
    sub t4, a3, a1

    /* crée des tableaux temporaires dans le stack */
    /* t5 = longueur_gauche + longueur_droite*/
    add t5, t3, t4
    slli t5, t5, 2
    sub sp, sp, t5
    mv t5, zero

    /* copie les valeurs du tableau originel dans les tableaux temporaires */
    /* i = j = 0 */
    mv t0, zero
    mv t1, zero

    /* for (i = 0; i < longueur_gauche; i++) */
copie1:
    /* condition de sortie */
    bge t0, t3, copie2
    /* t5 = indice_bas + i */
    add t5, a2, t0
    /* t6 = tableau[indice_bas + i] */
    slli s0, t5, 2
    add s0, a0, s0
    lw t6, 0(s0)
    /* sp = gauche[i] */
    slli s0, t0, 2
    add s0, sp, s0
    sw t6, 0(s0)
    /* i++ */
    addi t0, t0, 1
    j copie1

    /* for (j = 0; j < longueur_droite; j++) */
copie2:
    /* condition de sortie */
    bge t1, t4, fusion
    /* t5 = m + 1 + j */
    mv t5, a1
    addi t5, t5, 1
    add t5, t5, t1
    /* t6 = tableau[m + 1 + j] */
    slli s0, t5, 2
    add s0, a0, s0
    lw t6, 0(s0)
    /* sp = droite[longueur_gauche + j] */
    add s0, t3, t1
    slli s0, s0, 2
    add s0, sp, s0
    sw t6, 0(s0)
    /* j++ */
    addi t1, t1, 1
    j copie2

fusion:
    /* i = j = 0 */
    mv t0, zero
    mv t1, zero
    mv t2, a2
    /* k = indice_bas */

while:
    /* t5 = i < longueur_gauche */
    slt t5, t0, t3
    /* t6 = j < longueur_droite */
    slt t6, t1, t4
    /* t5 = t5 and t6 */
    and t5, t5, t6
    /* condition */
    beqz t5, copie_reste_gauche
    /* t5 = gauche[i] */
    slli s0, t0, 2
    add s0, sp, s0
    lw t5, 0(s0)
    /* t6 = droite[j+longueur_gauche] */
    add s0, t1, t3
    slli s0, s0, 2
    add s0, sp, s0
    lw t6, 0(s0)

    /* if (gauche[i] <= droite[j]) */
    bgt t5, t6, else
    /* tableau[k] = gauche[i] */
    slli s0, t2, 2
    add s0, a0, s0
    sw t5, 0(s0)
    /* i++ */
    addi t0, t0, 1
    /* k++ */
    addi t2, t2, 1
    j while

else:
    /* tableau[k] = droite[j] */
    slli s0, t2, 2
    add s0, a0, s0
    sw t6, 0(s0)
    /* j++ */
    addi t1, t1, 1
    /* k++ */
    addi t2, t2, 1
    j while

copie_reste_gauche:
    /* t5 = i < longueur_gauche */
    slt t5, t0, t3
    /* condition */
    beqz t5, copie_reste_droite
    /* t5 = gauche[i] */
    slli s0, t0, 2
    add s0, sp, s0
    lw t5, 0(s0)
    /* tableau[k] = gauche[i] */
    slli s0, t2, 2
    add s0, a0, s0
    sw t5, 0(s0)

    /* i++ */
    addi t0, t0, 1
    /* k++ */
    addi t2, t2, 1
    j copie_reste_gauche

copie_reste_droite:
    /* t5 = j < longueur_droite */
    slt t5, t1, t4
    /* condition */
    beqz t5, fusion_end
    /* t5 = droite[j+longueur_gauche] */
    add s0, t1, t3
    slli s0, s0, 2
    add s0, sp, s0
    lw t5, 0(s0)
    /* tableau[k] = droite[j] */
    slli s0, t2, 2
    add s0, a0, s0
    sw t5, 0(s0)

    /* j++ */
    addi t1, t1, 1
    /* k++ */
    addi t2, t2, 1
    j copie_reste_droite

fusion_end:
    /* on dépile la copie du tableau */
    mv t5, zero
    add t5, t3, t4
    slli t5, t5, 2
    add sp, sp, t5
    mv t5, zero
    /* on dépile les arguments */
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw t0, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, +20
    ret

