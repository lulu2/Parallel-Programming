#!/usr/bin/env python
import sys

current_key1 = None
current_key2 = None
current_lst=None
key1=None
key2=None
lst=None

for line in sys.stdin:
	line = line.strip()
	key1,key2,lst = line.split('\t',2)
	if current_key1 == key1 and current_key2 == key2:
		current_lst=current_lst.strip('[]')
		lst=lst.strip('[]')
		a=current_lst.split(', ')
		b=lst.split(', ')
		for i in a:
			for j in b:
				if i==j:
					if int(key2)<int (j[1:(len(j)-1)]):
						print key1+" "+ key2+" "+j[1:(len(j)-1)]
	else:
		current_key1 = key1
		current_key2 = key2
		current_lst=lst