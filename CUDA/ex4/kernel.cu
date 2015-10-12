#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void add(int *a, int *b, int *c)
{
    /* finish this code to calculate c element-wise from a and b where each block calculates one element */
        int i = blockIdx.x;
	c[i] = a[i] + b[i];
}


/* experiment with different values of N.  */
/* how large can it be? */
#define N 2048*32

int main()
{
    int *a, *b, *c;
	int *d_a, *d_b, *d_c;
	int size = N * sizeof( int );

	/* allocate space for device copies of a, b, c */
	
	cudaMalloc( (void **) &d_a, size );
	/* insert code here for d_b and d_c */
        
        cudaMalloc( (void **) &d_b, size );
        cudaMalloc( (void **) &d_c, size );
	/* allocate space for host copies of a, b, c and setup input values */

	a = (int *)malloc( size );
	b = (int *)malloc( size );
	c = (int *)malloc( size );

	/* intializing a, b, c on host */
	
	for( int i = 0; i < N; i++ )
	{
		a[i] = b[i] = i;
		c[i] = 0;
	}

	/* copy inputs to device */
	
	cudaMemcpy( d_a, a, size, cudaMemcpyHostToDevice );
	/* insert code to copy b to the device */
        
        cudaMemcpy( d_b, b, size, cudaMemcpyHostToDevice );
        cudaMemset( d_c, 0, size );

	/* launch the kernel on the GPU */
	/* finish this kernel launch with N blocks and 1 thread per block */
	add<<< N, 1  >>>( d_a, d_b, d_c );

	/* copy result back to host */

	cudaMemcpy( c, d_c, size, cudaMemcpyDeviceToHost );

/*	for( int i = 0; i < N; i++ )
	{
		printf(" c[%d] = %d\n",i,c[i]);
	}*/ /* end for */

       printf("The last element is c[%d] = %d\n",N-1,c[N-1]);
	/* clean up */

	free(a);
	free(b);
	free(c);
	cudaFree( d_a );
	cudaFree( d_b );
	cudaFree( d_c );
	
	return 0;
} /* end main */
