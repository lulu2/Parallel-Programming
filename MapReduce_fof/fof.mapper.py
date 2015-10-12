#!/usr/bin/env python
import sys
for line in sys.stdin:
	line = line.strip()
	flist = line.split()
	name = flist.pop(0)
	for f in flist:
			print '%s\t%s\t%s' % (name, f,flist)
			print '%s\t%s\t%s' % (f, name,flist)