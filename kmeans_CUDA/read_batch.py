#!/usr/bin/env python
## -*- coding: utf-8 -*-

import os
import sys, getopt
import numpy

from numpy import *
from PIL import Image
import pickle


def unpickle(file):
    import cPickle
    fo = open(file, 'rb')
    dict = cPickle.load(fo)
    fo.close()
    return dict

def main(argv):


	dict = unpickle('data_batch_1')

	#Initialize matrix
	size = len(dict['data'])
	featureSize = len(dict['data'][0])/3
	grayMatrix = numpy.zeros((size, featureSize))
	normalRGB = numpy.zeros((size, featureSize,3))

	#Compute intensity and normalize
	items = list(dict.items())
	dataItem = items[0]
	labels = numpy.array(dict['labels'])
	print labels
	dataMatrix = numpy.array(dataItem[1])
	R = dataMatrix[:,:1024]
	print R.shape
	G = dataMatrix[:,1024:2048]
	B = dataMatrix[:,2048:]
	#Construct original picture
	normalRGB = numpy.rollaxis(numpy.asarray([R,G,B]), 0,3)
	#Construct intensity Array
	grayMatrix = (R*0.2989+G*0.5870+B*0.1140)
	#Normalize
	grayMatrix -= grayMatrix.mean(axis=1)[:, None]
	(rows, cols) = grayMatrix.shape
	grayMatrix /= rows**0.5


	labelDict = {}

	for i in range(rows):
		# print labels[i]
		if labels[i] not in labelDict:
			labelDict[labels[i]] = [grayMatrix[i]]
		elif len(labelDict[labels[i]]) <= 409 :
			labelDict[labels[i]].append(grayMatrix[i])
	
	
	for i in range(4):
		labelDict[i] = labelDict[i][1:]

	# newGrayMatrix = label
	
	for i in range(10):
		labelDict[i] = vstack(labelDict[i])

	vList = []
	labelList = []
	for (k, v) in labelDict.items():
		vList.append(v)
		labelList.append(k)

	newGrayMatrix = vstack(vList)


	print newGrayMatrix.shape
	for i in range(len(labelDict)):
		print i, len(labelDict[i])



	print newGrayMatrix
	(rows, cols) = newGrayMatrix.shape
	print (rows, cols)
	arr = newGrayMatrix.T
	with open('batchData_4096.txt','w') as f:
		f.write(str(rows))
		f.write(' ')
		f.write(str(cols))
		f.write('\n')
		numpy.savetxt(f, arr, fmt="%f")


#Main entry
if __name__ == "__main__":
    main(sys.argv)