// gameoflife.c
// Name: JIAN JIN
// JHED: jjin20

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "mpi.h"

#define ITERATIONS 64
#define GRID_WIDTH  256
#define DIM  16     // assume a square grid

int main ( int argc, char** argv ) {

  int global_grid[ 256 ] = {0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
    1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };

  // MPI Standard variable
  int num_procs;
  int ID, j;
  int iters = 0;

  // Messaging variables
  MPI_Status stat;
  // TODO add other variables as necessary
  int intervals,rowSize, ace, beta;
  int i,k;
  int *rows;
  int *fstline;
  int *sndline;
  int *thdline;
  int *result;

  // MPI Setup
  if ( MPI_Init( &argc, &argv ) != MPI_SUCCESS )
  {
    printf ( "MPI_Init error\n" );
  }

  MPI_Comm_size ( MPI_COMM_WORLD, &num_procs); // Set the num_procs
  MPI_Comm_rank ( MPI_COMM_WORLD, &ID );

  assert ( DIM % num_procs == 0 );

  // TODO Setup your environment as necessary
  if (ID != 0)
    {ace=ID-1;}
    else {ace=num_procs-1;}

  if (ID != num_procs-1)
    {
      beta=ID+1;
    }
    else
      {
        beta=0;
      }

  rowSize=GRID_WIDTH/num_procs;
  rows = malloc(sizeof(int)*rowSize);
  fstline = malloc(sizeof(int)*DIM);
  sndline = malloc(sizeof(int)*rowSize);
  thdline = malloc(sizeof(int)*DIM);
  result = malloc(sizeof(int)*GRID_WIDTH);
  intervals=(ID/num_procs)*GRID_WIDTH;
  k = DIM/num_procs-1;
  
  for(i=0; i < rowSize; i++) {
        rows[i] = global_grid[i + intervals];
  }

  for ( iters = 0; iters < ITERATIONS; iters++ ) {
    // TODO: Add Code here or a function call to you MPI code

    // Output the updated grid state
    // FIXME: Feel free to print more iterations when you debug but only 
    //  submit with the 64th iteration printing and do not change the 
    //  format of the printed output.
      if(ID % 2 == 0){
            MPI_Send(&rows[rowSize - DIM], DIM, MPI_INT, beta, 2, MPI_COMM_WORLD);
            MPI_Send(&rows[0], DIM, MPI_INT, ace, 2, MPI_COMM_WORLD);
            MPI_Recv(thdline, DIM, MPI_INT, ace, 2, MPI_COMM_WORLD, &stat);
            MPI_Recv(fstline, DIM, MPI_INT, beta, 2, MPI_COMM_WORLD, &stat);
      }

        else{
            MPI_Recv(thdline, DIM, MPI_INT, ace, 2, MPI_COMM_WORLD, &stat);
            MPI_Recv(fstline, DIM, MPI_INT, beta, 2, MPI_COMM_WORLD, &stat);
            MPI_Send(&rows[rowSize - DIM], DIM, MPI_INT, beta, 2, MPI_COMM_WORLD);
            MPI_Send(&rows[0], DIM, MPI_INT, ace, 2, MPI_COMM_WORLD);
      }

    void transform(int *input, int *a, int *b, int *c, int n){
    int i, l, r, count;
    for (i=0; i<n; i++){
      if (i==0){
        l = n - 1;
      }
      else{
        l = i - 1;
      }
      if (i==n-1){
        r = 0;
      }
      else{
        r = i+1;
      }
      count = a[i] + a[l] + a[r] + b[l] + b[r] + b[i] + c[r] +c[l];
      if ((c[i]==1&&count==2)||count==3){
        input[i]=1;
      }
      else{
        input[i]=0;
      }
    }
    }
      
    int p, l, r, count;
    for (p=0; p<DIM; p++){
          if (p==0){
              l = DIM - 1;
          }
          else{
              l = p - 1;
          }
          if (p==DIM-1){
              r = 0;
          }
          else{
              r = p+1;
          }
          count = thdline[p] + thdline[l] + thdline[r] + (&rows[DIM])[l] + (&rows[DIM])[r] + (&rows[DIM])[p] + (&rows[0])[r] +(&rows[0])[l];
          if (((&rows[0])[p]==1&&count==2)||count==3){
              (&sndline[0])[p]=1;
          }
          else{
              (&sndline[0])[p]=0;
          }
      }
      
      int x;
      for( x= 1; x< k; x++) {
          int m=DIM*x;
          for (p=0; p<DIM; p++){
              if (p==0){
                  l = DIM - 1;
              }
              else{
                  l = p - 1;
              }
              if (p==DIM-1){
                  r = 0;
              }
              else{
                  r = p+1;
              }
              count = (&rows[m - DIM])[p] + (&rows[m - DIM])[l] + (&rows[m - DIM])[r] + (&rows[m + DIM])[l] + (&rows[m + DIM])[r] + (&rows[m + DIM])[p] + (&rows[m])[r] + (&rows[m])[l];
              if (((&rows[m])[i]==1&&count==2)||count==3){
                  (&sndline[m])[p]=1;
              }
              else{
                  (&sndline[m])[p]=0;
              }
          }

      }
      
      for (p=0; p<DIM; p++){
          if (p==0){
              l = DIM - 1;
          }
          else{
              l = p - 1;
          }
          if (p==DIM-1){
              r = 0;
          }
          else{
              r = p+1;
          }
          count = (&rows[rowSize - 2*DIM])[p] + (&rows[rowSize - 2*DIM])[l] + (&rows[rowSize - 2*DIM])[r] + fstline[l] + fstline[r] + fstline[p] + (&rows[rowSize - DIM])[r] +(&rows[rowSize - DIM])[l];
          if (((&rows[rowSize - DIM])[p]==1&&count==2)||count==3){
              (&sndline[rowSize - DIM])[p]=1;
          }
          else{
              (&sndline[rowSize - DIM])[p]=0;
          }
      }
      
      
      
      
      

      /*transform(&sndline[0],thdline, &rows[DIM], &rows[0], DIM);
      for(i = 1; i< k; i++) {
      int m=DIM*i;
      transform(&sndline[m], &rows[m - DIM], &rows[m + DIM], &rows[m], DIM);
      }
      transform(&sndline[rowSize - DIM], &rows[rowSize - 2*DIM], fstline, &rows[rowSize - DIM], DIM);
       */

      for(j=0; j<rowSize; j++){
      rows[j] = sndline[j];
      }

      MPI_Gather(rows,rowSize, MPI_INT, result, rowSize, MPI_INT, 0, MPI_COMM_WORLD);

    if ( ID == 0 && iters == ITERATIONS-1) {
      printf ( "\nIteration %d: final grid:\n", iters );
      for ( j = 0; j < GRID_WIDTH; j++ ) {
        if ( j % DIM == 0 ) {
          printf( "\n" );
        }
        printf ( "%d  ", result[j] );
      }
      printf( "\n" );
    }
  }
  free(rows);
  free(fstline);
  free(sndline);
  free(thdline);
  free(result);
  // TODO: Clean up memory
  MPI_Finalize(); // finalize so I can exit
}




