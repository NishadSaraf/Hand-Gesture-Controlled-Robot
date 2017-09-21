'''*************************************************************
  Created by:	Vipul Sharma 
  Reference: https://github.com/vipul-sharma20/gesture-opencv
  Description: This code captures video detects the finger count and 
				transmits signal to FPGA board using python serial communicatation
				library
  Modified by:  Nishad Saraf,Parimal Kularni, Chaitanya Deshpande, Joel Jacob
  Modification: Added functionality for serial communication to communicate
				Also added a counter logic for limiting number of tarnsmissions for
				proper communication with the board	
				with one of the FPGAarduino   
 *************************************************************'''
 
#Importing opencv and numpy as well as serial communication libraries
import serial
import cv2
import numpy as np
import math
import time

#Defining port number for writing data
port = "COM24"
baud = 115200
ser = serial.Serial(port, baud, timeout=1)
rvs_count=0
rght_count=0
lft_count=0
frwd_count=0
stop_count=0

#Checking if video is captured or not
cap = cv2.VideoCapture(0)
while(cap.isOpened()):
    ret, img = cap.read()
	# Drawing rectangle which restricts area of operation of image processing
    cv2.rectangle(img,(300,300),(100,100),(0,255,0),0)
    crop_img = img[100:300, 100:300]
    grey = cv2.cvtColor(crop_img, cv2.COLOR_BGR2GRAY)
    value = (35, 35)
	#Use of gaussianBlur function is to blur backround and making hand gestures more prominent 
    blurred = cv2.GaussianBlur(grey, value, 0)
    _, thresh1 = cv2.threshold(blurred, 127, 255,
                               cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)
    cv2.imshow('Thresholded', thresh1)

    (version, _, _) = cv2.__version__.split('.')

    if version is '3':
        image, contours, hierarchy = cv2.findContours(thresh1.copy(), \
               cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
    elif version is '2':
        contours, hierarchy = cv2.findContours(thresh1.copy(),cv2.RETR_TREE, \
               cv2.CHAIN_APPROX_NONE)

    cnt = max(contours, key = lambda x: cv2.contourArea(x))
    
    x,y,w,h = cv2.boundingRect(cnt)
    cv2.rectangle(crop_img,(x,y),(x+w,y+h),(0,0,255),0)
	
	#Check how many times contour bulged in and out to calculate number of objects
    hull = cv2.convexHull(cnt)
    drawing = np.zeros(crop_img.shape,np.uint8)
    cv2.drawContours(drawing,[cnt],0,(0,255,0),0)
    cv2.drawContours(drawing,[hull],0,(0,0,255),0)
    hull = cv2.convexHull(cnt,returnPoints = False)
    defects = cv2.convexityDefects(cnt,hull)
    count_defects = 0
	#Drawing counter area around the edges of fingers
    cv2.drawContours(thresh1, contours, -1, (0,255,0), 3)
    for i in range(defects.shape[0]):
        s,e,f,d = defects[i,0]
        start = tuple(cnt[s][0])
        end = tuple(cnt[e][0])
        far = tuple(cnt[f][0])
        a = math.sqrt((end[0] - start[0])**2 + (end[1] - start[1])**2)
        b = math.sqrt((far[0] - start[0])**2 + (far[1] - start[1])**2)
        c = math.sqrt((end[0] - far[0])**2 + (end[1] - far[1])**2)
        angle = math.acos((b**2 + c**2 - a**2)/(2*b*c)) * 57
		#If the value of angle is less than 90 the count the gestures.
        if angle <= 90:
            count_defects += 1
            cv2.circle(crop_img,far,1,[0,0,255],-1)
        
        cv2.line(crop_img,start,end,[0,255,0],2)
        
    #forward
    if count_defects == 1:
        cv2.putText(img,"Go Forward", (50,50), cv2.FONT_HERSHEY_SIMPLEX, 1, 2)
       #added logic for limiting number of transmissions
        if(frwd_count==50):
            ser.write('W')
            frwd_count=0
        else:    
            frwd_count+=1
	#Right
    elif count_defects == 2:
        cv2.putText(img, "Turn Right", (50,50), cv2.FONT_HERSHEY_SIMPLEX, 1, 2)
       
        if(rght_count==50):
            ser.write('D')
            rght_count=0
        else:    
            rght_count+=1
	#Left
    elif count_defects == 3:
        cv2.putText(img,"Turn Left", (50,50), cv2.FONT_HERSHEY_SIMPLEX, 1, 2)
        
        if(lft_count==50):
            ser.write('A')
            lft_count=0
        else:    
            lft_count+=1
	#Reverse
    elif count_defects == 4:
        cv2.putText(img,"Go Reverse", (50,50), cv2.FONT_HERSHEY_SIMPLEX, 1, 2)
        
        if(rvs_count==10):
            ser.write('S')
            rvs_count=0
        else:    
            rvs_count+=1
    else:
        cv2.putText(img,"2:Forward 3:Right 4:Left 5:Reverse", (50,50),\
                    cv2.FONT_HERSHEY_SIMPLEX, 1, 2)
        
        if(stop_count==10):
            ser.write('Q')
            stop_count=0
        else:    
            stop_count+=1
   
    cv2.imshow('Gesture', img)
    all_img = np.hstack((drawing, crop_img))
    cv2.imshow('Contours', all_img)
    k = cv2.waitKey(10)
    if k == 27:
        break
