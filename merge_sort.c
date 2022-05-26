#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#define SIZE 10

int32_t array[SIZE];
int32_t ref[SIZE];
void merge_sort_asm(int32_t[], int32_t, int32_t);

static void print_array(int32_t array[], uint32_t length)
{
   for (uint32_t i = 0; i < length; i++)
      printf("%" PRId32 " ", array[i]);
   printf("\n");
}

static void init_arrays(int32_t array[], int32_t ref[], uint32_t length)
{
   for (uint32_t i = 0; i < length; i++)
      array[i] = length-1-i;
   memcpy(ref, array, sizeof(int32_t) * length);
}

void merge_c(int32_t *array, int m, int lower_index, int higher_index)
{
    int i, j, k;
    int left_length = m - lower_index + 1;
    int right_length = higher_index - m;
    int left[left_length], right[right_length];

    for (i = 0; i < left_length; i++)
        left[i] = array[lower_index + i];
    for (j = 0; j < right_length; j++)
        right[j] = array[m + 1 + j];

    i = 0;
    j = 0;
    k = lower_index;
    while (i < left_length && j < right_length) {
        if (left[i] <= right[j]) {
            array[k] = left[i];
            i++;
        } else {
            array[k] = right[j];
            j++;
        }
        k++;
    }

    while (i < left_length) {
        array[k] = left[i];
        i++;
        k++;
    }

    while (j < right_length) {
        array[k] = right[j];
        j++;
        k++;
    }
}

void merge_sort(int32_t *array, int lower_index, int higher_index)
{
    if (lower_index < higher_index) {
        int m = lower_index + (higher_index - lower_index) / 2;
        merge_sort(array, lower_index, m);
        merge_sort(array, m + 1, higher_index);
        merge_c(array, m, lower_index, higher_index);
    }
}

int main()
{
    int32_t array1[SIZE]= {9, 8, 7, 6, 5, 4, 3, 2, 1, 0};
    printf("Initial array (C):\n");
    print_array(array1, SIZE);
    merge_sort(array1, 0, SIZE - 1);
    print_array(array1, SIZE);

    printf("Initial array (ASM):\n");
    init_arrays(array, ref, SIZE);
    print_array(array, SIZE);
    merge_sort_asm(array, 0, SIZE - 1);
    print_array(array, SIZE);
    return 0;
}
