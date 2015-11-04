#ifndef PCA_H
#define PCA_H

#include <cula_blas.h>
#include <cula_lapack.h>

void checkStatus(culaStatus status);
void PCA(float *X, int N, int D, int M, float *P, float *Y);

#endif