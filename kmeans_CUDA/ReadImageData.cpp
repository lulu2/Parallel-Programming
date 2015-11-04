#include <fstream>
#include <iostream>
#include <stdlib.h>
using namespace std;

float* readFile(char* path, int *rows, int *cols) {

	ifstream fin(path);


	// int rows;
	// int cols;
	fin >> *rows;
	fin >> *cols;

	float *X = (float*)malloc((*rows)*(*cols)*sizeof(float));

	cout << "rows of the image: " << *rows << endl;
	cout << "cols of the image: " << *cols << endl;

	int i = 0;
	while(!fin.eof()) {
		fin >> X[i];
		i++;
	}

	cout << "total pixel = " << i << endl;

	return X;
	// delete X;
}

// int main(int argc, char** argv) {

// 	if (argc != 2) {
// 		cout << "Please only specify the path of image data!" << endl;
// 		return 0;
// 	}

// 	readFile(argv[1]);


// }