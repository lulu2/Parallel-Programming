# Makefile for systemSolve example


INCLUDES=-I${CULA_INC_PATH}
LIBPATH32=-L${CULA_LIB_PATH_32}
LIBPATH64=-L${CULA_LIB_PATH_64}
CC=g++
ifdef debug
CFLAGS=-g
else
CFLAGS=-DNDEBUG -O3
endif

LIBS=-lcula_lapack_basic -lcublas -liomp5

usage:
	@echo "To build the program, type one of:"
	@echo ""
	@echo "    make build32"
	@echo "    make build64"
	@echo ""
	@echo "where '32' and '64' represent the platform you wish to build for"

build32:
	# sh /users/zcao8/cula/examples/checkenvironment.sh
	$(CC) -m32 -o PCA PCA.c ReadImageData.cpp $(CFLAGS) $(INCLUDES) $(LIBPATH32) $(LIBS) -lm

build64:
	# sh /users/zcao8/cula/examples/checkenvironment.sh
	$(CC) -m64 -o PCA PCA.c ReadImageData.cpp $(CFLAGS) $(INCLUDES) $(LIBPATH64) $(LIBS) -lm

clean:
	rm -f PCA

