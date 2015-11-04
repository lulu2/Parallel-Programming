#include "cuda_runtime.h"
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <stdlib.h>
#include <iostream>
#include <ctime>

#include "ReadImageData.h"
#include "PCA.h"

__global__ void kmeans_initialize(float *points, float *cores, int num_cluster, int dim, int *d_cluster_master, int* d_change)
{    
     int index = blockIdx.x * blockDim.x + threadIdx.x ;
     float bar=FLT_MAX;
     float distance;
     d_change[index]=0;
     for (int i = 0; i<num_cluster; i++){
        distance=0.0;
        for (int j=0;j<dim;j++){
             distance +=(cores[i*dim+j]-points[index*dim+j])*(cores[i*dim+j]-points[index*dim+j]);   
         }
       if (distance<bar) {
         bar = distance;
         d_cluster_master[index] = i;
            }
     }
     __syncthreads();
}

__global__ void kmeans(float *points, float *cores, int num_cluster, int dim, int *d_cluster_master, int* d_change)
{    
     int index = blockIdx.x * blockDim.x + threadIdx.x ;
     float bar=FLT_MAX;
     float distance;
     d_change[index]=0;
     int currents=d_cluster_master[index];
     for (int i = 0; i<num_cluster; i++){
        distance=0.0;
        for (int j=0;j<dim;j++){
             distance +=(cores[i*dim+j]-points[index*dim+j])*(cores[i*dim+j]-points[index*dim+j]);   
         }
       if (distance<bar) {
         bar = distance;
         d_cluster_master[index] = i;
            }
     }  
       if (d_cluster_master[index]!= currents) {
         d_change[index] = 1;
         }
     __syncthreads();
}

__global__ void updata_cluster(float *points, float *cores, int num_data, int dim, int *d_cluster_master, int *d_number_member, float *sum, int offset)
{   
    int index = threadIdx.x ;
    index+=offset*8;
    d_number_member[index]=0;
    for (int k=0;k<dim;k++){
        sum[index*dim+k]=0.0;
    }
 for (int i = 0; i<num_data; i++){
        if (d_cluster_master[i]==index){
        for (int j=0;j<dim;j++){
            sum[index*dim+j] += points[i*dim+j];
        }
            d_number_member[index]++;
        }
    }

    for (int p=0; p<dim; p++){
        cores[index*dim+p]=sum[index*dim+p]/d_number_member[index];
    }
    __syncthreads();
}

__global__ void data_transform(float *d_input_data, float *d_transform_data, int dim)
{
    int index = blockIdx.x * blockDim.x + threadIdx.x ;
    d_transform_data[index]=d_input_data[(index%dim)*dim+index/dim];
    __syncthreads();
}

int main(int argc, char **argv)
{
    int dim;
    int num_data;
    int num_cluster;
    char* path;


    if (argc != 2) {
        printf("Please input file!\n");
        return 1;
    }
    dim = 500;
    num_cluster = 10;
    path = argv[1];
    int D = 0;


    float* X = readFile(path, &num_data, &D);
    float* input_data = (float*)malloc(num_data*dim*sizeof(float));
    float* P = (float*)malloc(D*dim*sizeof(float));

    PCA(X, num_data, D, dim, P, input_data);

    free(X);
    free(P);

    int size_data = num_data * dim * sizeof(float);
    int size_cluster = num_cluster * dim *sizeof(float);

    float *h_cores=(float*) malloc (size_cluster);
    int *h_change=(int *) malloc (num_data*sizeof(int));
    int *h_cluster_master=(int *) malloc (num_data*sizeof(int));
    int *h_label=(int *) malloc (num_data*sizeof(int));

    int *d_cluster_master;
    float *d_points;
    float *d_cores;
    int *d_change;
    int *d_number_member;
    float *d_sum;
    cudaMalloc(&d_sum, size_cluster);
    cudaMalloc(&d_cluster_master, num_data*sizeof(int));
    cudaMalloc(&d_points, size_data);
    cudaMalloc(&d_cores, size_cluster);
    cudaMalloc(&d_change, num_data*sizeof(int));
    cudaMalloc(&d_number_member, num_cluster*sizeof(int));

    float *h_input_data=input_data;
    float *h_transform_data=(float*) malloc (size_data);
    float *d_input_data;
    float *d_transform_data;
    cudaMalloc(&d_input_data, size_data);
    cudaMalloc(&d_transform_data, size_data);


//Set labels
    int small_group=num_data/10;
    int big_group=(num_data/10)+1;
    int num_big=num_data%10;
    int num_small=10-num_big;
    
    for (int i=0;i<num_small;i++){
    for (int j=0;j<small_group;j++){
    h_label[i*small_group+j]=i;
    }
    }

    for (int i=num_small;i<10;i++){
    for (int j=0;j<big_group;j++){
    h_label[num_small*small_group+(i-num_small)*big_group+j]=i;
    }
    }

/*
    for (int i=0;i<4;i++){
    for (int j=0;j<409;j++){
    h_label[i*409+j]=i;
    }
    }

    for (int i=4;i<10;i++){
    for (int j=0;j<410;j++){
    h_label[4*409+(i-4)*410+j]=i;
    }
    }
*/

    std::clock_t t1, t2, t3, t4;

    t1 = std::clock();

    cudaMemcpy(d_input_data, h_input_data, size_data, cudaMemcpyHostToDevice);
    if (num_data<512){
    data_transform<<<1, 256>>>(d_input_data, d_transform_data, dim);
    }
    else {
    data_transform<<<num_data/512, 512>>>(d_input_data, d_transform_data, dim);
    }
    //data_transform<<<8, 512>>>(d_input_data, d_transform_data, dim);
    cudaMemcpy(h_transform_data, d_transform_data, size_data, cudaMemcpyDeviceToHost);
    t2 = std::clock();


    for (int i=0;i<num_cluster;i++){
        //int tempt = rand() % num_data;
        //std::cout<<tempt<<std::endl;
        int tempt=(i+1)*(num_data/10)-8;
        for (int j=0;j<dim;j++){
            h_cores[i*dim+j]=h_transform_data[tempt*dim+j];
        }
    }

    //std::cout<<num_data<<std::endl;
    //for (int i=0;i<50;i++){
    //std::cout<<h_cores[i]<<std::endl;
    //}

    cudaMemcpy(d_points, h_transform_data, size_data, cudaMemcpyHostToDevice);
    cudaMemcpy(d_cores, h_cores, size_cluster, cudaMemcpyHostToDevice);

    t3 = std::clock();
    //Initialize update
    if (num_data<512){
    kmeans_initialize<<<1, 256>>>(d_points, d_cores, num_cluster, dim, d_cluster_master, d_change);
    }
    else {
    kmeans_initialize<<<num_data/512, 512>>>(d_points, d_cores, num_cluster, dim, d_cluster_master, d_change);
    }
    cudaDeviceSynchronize();
    updata_cluster<<< 1, 8>>>(d_points, d_cores, num_data, dim, d_cluster_master, d_number_member,d_sum, 0);
    cudaDeviceSynchronize();
    updata_cluster<<< 1, 2>>>(d_points, d_cores, num_data, dim, d_cluster_master, d_number_member,d_sum, 1);
    cudaDeviceSynchronize();

    //update
    //while(fluctuation>threshold){
    for (int kk=0;kk<50;kk++){
    if (num_data<512){
    kmeans<<<1, 256>>>(d_points, d_cores, num_cluster, dim, d_cluster_master, d_change);
    }
    else {
    kmeans<<<num_data/512, 512>>>(d_points, d_cores, num_cluster, dim, d_cluster_master, d_change);
    }
    cudaDeviceSynchronize();
    updata_cluster<<< 1, 8>>>(d_points, d_cores, num_data, dim, d_cluster_master, d_number_member,d_sum, 0);
    cudaDeviceSynchronize();
    updata_cluster<<< 1, 2>>>(d_points, d_cores, num_data, dim, d_cluster_master, d_number_member,d_sum, 1);
    cudaMemcpy(h_change, d_change, num_data*sizeof(int), cudaMemcpyDeviceToHost);
//    fluctuation=0;
 //       for (int m=0;m<num_data;m++){
 //           if (h_change[m]==1){
  //          fluctuation++;
   //         }
     //   }
    }

    int* h_number_member = (int *) malloc (num_cluster*sizeof(int));
    cudaMemcpy(h_number_member, d_number_member, num_cluster*sizeof(int), cudaMemcpyDeviceToHost);
    t4 = std::clock();

    float time_data_transform=(t2-t1)/(float) CLOCKS_PER_SEC;
    float time_kmeans_transform=(t4-t3)/(float) CLOCKS_PER_SEC;

    std::cout<<"Call for transform_data kernel takes "<<time_data_transform<<" seconds"<<std::endl;
    std::cout<<"Call for k-means kernel takes "<<time_kmeans_transform<<" seconds"<<std::endl;
    
    free(h_change);
    free(h_cores);
    free(h_input_data);
    free(h_transform_data);
    free(h_cluster_master);
    free(h_number_member);
    cudaFree(d_points);
    cudaFree(d_cores);
    cudaFree(d_cluster_master);
    cudaFree(d_number_member);
    cudaFree(d_change);
    cudaFree(d_sum);
    cudaFree(d_transform_data);

    return 0;
}

