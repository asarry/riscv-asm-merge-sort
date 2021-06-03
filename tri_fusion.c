#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#define SIZE 10

int32_t tab[SIZE];
int32_t ref[SIZE];
// Déclaration de la fonction tri_fusion_as définie dans fct_tri_fusion.s
void tri_fusion_as(int32_t[], int32_t, int32_t);

static void afficher_tab(int32_t tab[], uint32_t taille)
{
   for (uint32_t i = 0; i < taille; i++) {
      printf("%" PRId32 " ", tab[i]);
   }
   printf("\n");
}

static void init_tabs(int32_t tab[], int32_t ref[], uint32_t taille)
{
   for (uint32_t i = 0; i < taille; i++) {
      tab[i] = taille-1-i;
   }
   memcpy(ref, tab, sizeof(int32_t) * taille);
}

void fusion_c(int32_t *tableau, int m, int indice_bas, int indice_haut)
{
    int i, j, k;
    int longueur_gauche = m - indice_bas + 1;
    int longueur_droite = indice_haut - m;
    // Crée des tableaux tempoaires
    int gauche[longueur_gauche], droite[longueur_droite];

    // Copie les valeurs du tableau originel dans les tableaux temporaires
    for (i = 0; i < longueur_gauche; i++)
        gauche[i] = tableau[indice_bas + i];
    for (j = 0; j < longueur_droite; j++)
        droite[j] = tableau[m + 1 + j];

    // Fusion
    i = 0;
    j = 0;
    k = indice_bas;
    while (i < longueur_gauche && j < longueur_droite) {
        if (gauche[i] <= droite[j]) {
            tableau[k] = gauche[i];
            i++;
        } else {
            tableau[k] = droite[j];
            j++;
        }
        k++;
    }

    // Copie les éléments restants du tableau de gauche s'il en reste
    while (i < longueur_gauche) {
        tableau[k] = gauche[i];
        i++;
        k++;
    }

    // Copie les éléments restants du tableau de droite s'il en reste
    while (j < longueur_droite) {
        tableau[k] = droite[j];
        j++;
        k++;
    }
}

void tri_fusion(int32_t *tableau, int indice_bas, int indice_haut)
{
    if (indice_bas < indice_haut) {
        int m = indice_bas + (indice_haut - indice_bas) / 2;
        tri_fusion(tableau, indice_bas, m);
        tri_fusion(tableau, m + 1, indice_haut);
        fusion_c(tableau, m, indice_bas, indice_haut);
    }
}

int main()
{
    int32_t tableau1[SIZE]= {9, 8, 7, 6, 5, 4, 3, 2, 1, 0};
    printf("Tableau initial en C:\n");
    afficher_tab(tableau1, SIZE);

    tri_fusion(tableau1, 0, SIZE - 1);
    afficher_tab(tableau1, SIZE);


    printf("Tableau initial en assembleur:\n");
    init_tabs(tab, ref, SIZE);
    afficher_tab(tab, SIZE);

    tri_fusion_as(tab, 0, SIZE - 1);
    afficher_tab(tab, SIZE);
    return 0;
}
