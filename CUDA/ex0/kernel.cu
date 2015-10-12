#include "cuda_runtime.h"
#include <stdio.h>

__global__ void mykernel(){
	printf("Hello world from device!\n");
} /* end kernel */

int main(void) 
{
	mykernel<<<1,10>>>();
 	cudaDeviceSynchronize();
	printf("Hello World from Host\n");
	return 0;
} /* end main */
