#!/usr/bin/python

import os
import sys
import time
import shutil

from sys import argv

def force_rmdir(dir) :
	for root, dirs, files in os.walk(dir, False) :
		for name in files :
			os.remove(os.path.join(root, name))
		for name in dirs :
			os.rmdir(os.path.join(root, name))
	os.rmdir(dir)

def walk_dir(srcDir, dstDir, topdown = True) :
	copyCount = 0
	syncCount = 0
	rmFileCount = 0
	rmDirCount = 0
	for root, srcDirs, srcFiles in os.walk(srcDir, topdown) :
		if not os.path.basename(root).startswith('.') :

			dstPath = os.path.join(dstDir, os.path.relpath(root, srcDir))
			if not os.path.isdir(dstPath) :
				os.makedirs(dstPath)
			dstFiles = os.listdir(dstPath)

			for name in srcFiles :
				if not name.startswith('.') :
					try :
						dstFiles.remove(name)
					except :
						pass
					srcFileName = os.path.join(root, name)
					dstFileName = os.path.join(dstPath, name)
					#print dstFileName, os.path.isfile(dstFileName)
					#statinfo = os.stat(dstFileName)
					if (not os.path.isfile(dstFileName)) or (os.stat(srcFileName).st_size != os.stat(dstFileName).st_size) :
						print "copy [" + srcFileName + "] -> [" + dstFileName + "]"
						shutil.copy(srcFileName, dstFileName)
						copyCount += 1
					else :
						#print "skip [" + srcFileName + "]"
						syncCount += 1

			for name in srcDirs :
				try :
					dstFiles.remove(name)
				except :
					pass

			for name in dstFiles:
				fileToRemove = os.path.join(dstPath, name)
				if os.path.isfile(fileToRemove) :
					print "remove file [" + fileToRemove + "]"
					os.remove(fileToRemove)
					rmFileCount += 1
				else :
					print "remove dir  [" + fileToRemove + "]"
					force_rmdir(fileToRemove)
					rmDirCount += 1

	return copyCount, syncCount, rmFileCount, rmDirCount

beginTime = time.time()
script, srcDir, dstDir = argv

copyCount, syncCount, rmFileCount, rmDirCount = walk_dir(srcDir, dstDir)

print "Total copied files :", copyCount
print "Total synced files :", syncCount
print "Total removed files:", rmFileCount
print "Total removed dirs :", rmDirCount
endTime = time.time()

seconds = endTime - beginTime
m, s = divmod(seconds, 60)
h, m = divmod(m, 60)
print "%d:%02d:%02d" % (h, m, s)
