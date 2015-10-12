#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void add(int *a, int *b, int *c)
{
	/* insert correct index so that each element is calculated by a different thread */
        int i = threadIdx.x;
	c[i] = a[i] + b[i];
}

/* experiment with different values of N */
/* how large can you make it? */
#define N 512

int main()
{
    int *a, *b, *c;
	int *d_a, *d_b, *d_c;
	int size = N * sizeof( int );

	/* allocate space for device copies of a, b, c */

	cudaMalloc( (void **) &d_a, size );
	cudaMalloc( (void **) &d_b, size );
	cudaMalloc( (void **) &d_c, size );

	/* allocate space for host copies of a, b, c and setup input values */

	a = (int *)malloc( size );
	b = (int *)malloc( size );
	c = (int *)malloc( size );

	for( int i = 0; i < N; i++ )
	{
		a[i] = b[i] = i;
		c[i] = 0;
	}

	/* copy inputs to device */

	cudaMemcpy( d_a, a, size, cudaMemcpyHostToDevice );
	cudaMemcpy( d_b, b, size, cudaMemcpyHostToDevice );
	cudaMemset( d_c, 0, size );

	/* launch the kernel on the GPU */
	/* insert the correct launch parameters to use 1 block and N threads */
	/* how large can you make N?  */
	add<<< 1,N   >>>( d_a, d_b, d_c );

	/* copy result back to host */

	cudaMemcpy( c, d_c, size, cudaMemcpyDeviceToHost );

	for( int i = 0; i < N; i++ )
	{
		printf("c[%d] = %d\n",i,c[i]);
	} /* end for */

	/* clean up */

	free(a);
	free(b);
	free(c);
	cudaFree( d_a );
	cudaFree( d_b );
	cudaFree( d_c );
	
	return 0;
} /* end main */
