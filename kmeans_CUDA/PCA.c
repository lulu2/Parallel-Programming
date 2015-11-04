#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <cula_blas.h>
#include <cula_lapack.h>
#include "ReadImageData.h"
#define min(x, y) (x < y? x : y)




void checkStatus(culaStatus status)
{
    char buf[256];

    if(!status)
        return;

    culaGetErrorInfoString(status, culaGetErrorInfo(), buf, sizeof(buf));
    printf("%s\n", buf);

    culaShutdown();
    exit(EXIT_FAILURE);
}


// Given an N*D matrix X, perform PCA and yield a new projected matrix Y
void PCA(float *X, int N, int D, int M, float *P, float *Y)
{
    int i;
    float* mean;
    culaStatus status;

    float* x_temp = NULL;
    float* I = NULL;
    float* S = NULL;
    float* U = NULL;
    float* VT = NULL;
    float* V = NULL;


    printf("Allocating Matrices\n");
    x_temp = (float*)malloc(N*D*sizeof(float));
    I = (float*)malloc(D*D*sizeof(float));
    S = (float*)malloc((min(N, D))*sizeof(float));
    U = (float*)malloc(N*N*sizeof(float));
    VT = (float*)malloc(D*D*sizeof(float));
    V = (float*)malloc(D*D*sizeof(float));

    if(!I || !S || !U || !VT || !V)
        exit(EXIT_FAILURE);

    if (M > N && M > N) {
        printf("M must satify M <= min(N, D)!\n");
        exit(EXIT_FAILURE);
    }
        

    printf("Initializing CULA\n");
    status = culaInitialize();
    checkStatus(status);

    // printf("input matrix:\n");
    // for (i = 0; i < N * D; i++) {
    //     if (i < N)
    //     printf("X[%d]: %.2f\n",i, X[i]);
    // }

    //calculate mean
    mean = (float*)malloc(N*sizeof(float));
    memset(mean, 0.0, N*sizeof(float));

    for(i = 0; i < N*D; ++i) {
        mean[i % N] += X[i];
    }
    for (i = 0; i < N; i++) {
        mean[i] /= D;
        // printf("mean[%d]: %.2f\n",i, mean[i]);
    }
        
    //calculate covariance matrix
    for(i = 0; i < N*D; ++i) {
        X[i] -= mean[i % N];
        X[i] /= sqrt(N);
    }

    // for (i = 0; i < N * D; i++) {
    //     printf("X[%d]: %.2f\n",i, X[i]);
    // }

    memcpy(x_temp, X, N * D * sizeof(float));


    printf("Calling culaDeviceSgesvd\n");
    status = culaSgesvd('A', 'A', N, D, x_temp, N, S, U, N, VT, D);
    checkStatus(status);


    // for (i = 0; i < N * D; i++) {
    //     printf("x_temp[%d]: %.2f\n",i, x_temp[i]);
    // }
    // for (i = 0; i < N; i++) {
    //     printf("S[%d]: %.2f\n",i, S[i]);
    // }
    // for (i = 0; i < N * N; i++) {
    //     printf("U[%d]: %.2f\n",i, U[i]);
    // }
    // for (i = 0; i < D * D; i++) {
    //     printf("VT[%d]: %.2f\n",i, VT[i]);
    // }

    for (i = 0; i < D * D; i++) {
        I[i] = 0;
        if (i % (D + 1) == 0)
            I[i] = 1;
    }

    status = culaSgemm('T', 'N', D, D, D, 1, VT, D, I, D, 0, V, D);
    checkStatus(status);  

    // for (i = 0; i < D * D; i++) {
    //     printf("V[%d]: %.2f\n",i, V[i]);
    // }

    //Pick M eigenvectors
    memcpy(P, V, D * M * sizeof(float));

    // for (i = 0; i < D * M; i++) {
    //     printf("P[%d]: %.2f\n",i, P[i]);
    // }

    status = culaSgemm('N', 'N', N, M, D, 1, X, N, P, D, 0, Y, N);       
    checkStatus(status);

    // for (i = 0; i < N * M; i++) {
    //     printf("Y[%d]: %.2f\n",i, Y[i]);
    // }

    printf("Shutting down CULA\n\n");
    culaShutdown();


    free(I);
    free(mean);
    free(S);
    free(U);
    free(VT);
    free(V);
    free(x_temp);
}


int main(int argc, char** argv)
{
    int i = 0;
    int N = 0;
    int D = 0;
    int M = 10;

    if (argc != 2) {
        printf("Please only specify the path of image data!\n");
        return 0;
    }
    
    float* X = readFile(argv[1], &N, &D);

    printf("N = %d\n", N);
    printf("D = %d\n", D);

    //projected N*M matrix
    float* Y = (float*)malloc(N*M*sizeof(float));

    //eigenvectors, e.g. [eigv1;eigv2;eigv3; ...]
    float* P = (float*)malloc(D*M*sizeof(float));

    //perform PCA
    PCA(X, N, D, M, P, Y);

   //  for (i = 0; i < D*M; i++) {
   //      printf("P[%d]: %.2f\n",i, P[i]);
   //  }

   for (i = 0; i < N*M; i++) {
        printf("Y[%d]: %.2f\n",i, Y[i]);
    }

    

    free(P);
    free(X);
    free(Y);
    


    return EXIT_SUCCESS;
}

