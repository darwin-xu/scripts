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
	skipCount = 0
	removeCount = 0
	for root, srcDirs, srcFiles in os.walk(srcDir, topdown) :
		# Skip all files start with '.'
		if not os.path.basename(root).startswith('.') :

			# Get the dest file path and files list.
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
						skipCount += 1

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
					removeCount += 1
				else :
					print "remove dir  [" + fileToRemove + "]"
					force_rmdir(fileToRemove)
					removeCount += 1

	return copyCount, skipCount, removeCount

beginTime = time.time()
script, srcDir, dstDir = argv

copyCount, skipCount, removeCount = walk_dir(srcDir, dstDir)

print "Total copied file: ", copyCount
print "Total skipped file:", skipCount
print "Total removed file:", removeCount
endTime = time.time()

seconds = endTime - beginTime
m, s = divmod(seconds, 60)
h, m = divmod(m, 60)
print "%d:%02d:%02d" % (h, m, s)
