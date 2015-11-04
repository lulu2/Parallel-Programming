"""
Author: Jian JIn
Name: triangle_count.py

Get the list of cycle triangles in the graph
"""

from pyspark import SparkContext
from time import time
import sys, os

#TODO: Possibly define functions up here
def lessoutput(lst):
    h=int(lst[0])
    for i in lst:
        k=int(i)
        if k<h:
            yield (h,k)

def getpair(a,b):
    temp=[]
    for i in b:
        temp.append(i)
    length=len(temp)
    for j in range (0,length):
        for p in range (j+1,length):
            if temp[j]>temp[p]:
                yield ((temp[j],temp[p]),int(a))
            if temp[j]<temp[p]:
                yield ((temp[p],temp[j]),int(a))


# NOTE: Do not change the name/signature of this function
def count_triangles(data, master="local[2]"):
    """
    @brief: Count triangles using Spark
    @param data: The data location for the input files
    @param master: The master URL as defined at
        https://spark.apache.org/docs/1.1.0/submitting-applications.html#master-urls
    """

    #################  NO EDITS HERE ###################
    assert not os.path.exists("triangles.out"), "File: triangles.out \
            already exists"
    sc = SparkContext(master, "Triangle Count")
    start = time()
    ###############  END NO EDITS HERE  ################

    # TODO: Your code goes here!
    file=sc.textFile(data)
    edgeSet= file.map(lambda line: line.strip().split()).flatMap(lessoutput)
    comparison=edgeSet.map(lambda a:(a,'edge'))
    threes=edgeSet.groupByKey().flatMap(lambda (a,b):getpair(a,b))
    output=threes.join(comparison).map(lambda ((a,b),(c,d)): sorted((a,b,c),reverse=True))
    outputs=output.collect()

    #################  NO EDITS HERE  ###################
    print "\n\n*****************************************"
    print "\nTotal algorithm time: %.4f sec \n" % (time()-start)
    print "*****************************************\n\n""" 
    ###############  END NO EDITS HERE ################

    with open("triangles.out", "wb") as f:
        for i in outputs:
            f.write(str(i).strip('[]')+'\n') # TODO: Loop with f to write your result to file serially
        pass

#################  NO EDITS HERE  ###################
if __name__ == "__main__":
    if len(sys.argv) == 2:
        print "Counting triangles with master as 'local[2]'"
        count_triangles(sys.argv[1])
    elif len(sys.argv) == 3: 
        print "Counting triangles with master as '%s'" % sys.argv[2]
        count_triangles(sys.argv[1], sys.argv[2])
    else:
        sys.stderr.write("\nusage: SPARK_ROOT/bin/spark-submit \
            example/python/tri_count.py data_dir [master-url]")
        exit(1)
############### NO EDITS BELOW EITHER ################
