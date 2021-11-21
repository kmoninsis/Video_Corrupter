#! /usr/bin/python3

import subprocess
import time
from PIL import Image
import random
import shlex
import errno
import keyboard

width = 640
height = 480
streamkey = 'live_xxxxxxxxxxxxxxxxxxxxxxxxxx'
bufsize = width * height * 3
pos = int(bufsize/2)

scrambleLength = 5
# print(scrambleLength)

playCommand = shlex.split(f'ffmpeg -loglevel error -hide_banner -i - -c:v copy -f flv rtmp://live-fra.twitch.tv/app/{streamkey}')
readCommand = shlex.split(f'ffmpeg -loglevel error -hide_banner -y -threads 1 -probesize 10M -analyzeduration 2147483647 -f v4l2 -i /dev/video0 -pix_fmt yuv420p -c:v libx264 -preset ultrafast -tune zerolatency -an -f matroska -')
#-bufsize {bufsize} -maxrate {maxrate} -profile:v baseline
#ffmpeg -loglevel error -hide_banner -y -threads 1 -probesize 10M -analyzeduration 2147483647 -f v4l2 -i /dev/video0 -pix_fmt yuv420p -c:v libx264 -x264opts keyint=15 -preset ultrafast -tune zerolatency -an -f matroska - | ffplay -i -
#ffmpeg -re -f lavfi -i testsrc2=size=640x480 -f lavfi -i aevalsrc="sin(0*2*PI*t)" -vcodec libx264 -r 30 -g 30 -preset fast -b:v 3000k -pix_fmt rgb24 -pix_fmt yuv420p -f flv rtmp://live-fra.twitch.tv/app/
playStream = subprocess.Popen(playCommand, stdin=subprocess.PIPE)
readStream = subprocess.Popen(readCommand, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

while(True):
	data = readStream.stdout.read(bufsize)
	readStream.stdout.flush()
	
	bCopy = bytearray(bufsize)
	bCopy[:] = data
	
	# bCopy[pos:pos+1] = b'0000'

	# PosA = random.randint(scrambleStart,scrambleEnd)
	# PosB = random.randint(scrambleStart,scrambleEnd)
	# tmp = bCopy[PosA]
	# bCopy[PosA] = bCopy[PosB]
	# bCopy[PosB] = tmp

	scrambleStart = 20
	scrambleEnd = bufsize
	
	for i in range(scrambleLength):
		PosA = random.randint(scrambleStart,scrambleEnd)
		PosB = random.randint(scrambleStart,scrambleEnd)
		tmp = bCopy[PosA]
		bCopy[PosA] = bCopy[PosB]
		bCopy[PosB] = tmp

	try:
		playStream.stdin.write(bCopy)
		
		playStream.stdin.flush()


	except IOError as e:
	    if e.errno != errno.EPIPE and e.errno != errno.EINVAL:
	        print(e)
	        break
	    else:
	        raise

playStream.stdin.close()
playStream.wait()	
