# -*- coding: utf-8 -*-

#%%
# import various libraries necessery to run your Python code
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import threading
import cv2

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("BTPipeExample.bit"); # Configure the FPGA with this bit file

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()

if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.")
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)))
    print ("Exiting the progam.")
    sys.exit ()
print("----------------------------------------------------")
print("----------------------------------------------------")

#%% 
# Define the two variables that will send data to the FPGA
# We will use WireIn instructions to send data to the FPGA
dev.UpdateWireOuts()
regaddress = [1,2,3,4,39,42,43,44,57,58,59,60,68,69,80,83,97,98,100,101,102,103,106,107,108,109,110,117]
regvalues = [232,1,0,0,1,232,15,0,3,44,240,10,2,9,2,187,240,10,112,98,34,64,94,110,91,82,80,91]
R_W = -1
FLAG = 0
ADDRS = -1
REG_Val = -1
START_BIT = -1

dev.SetWireInValue(0x06, 0)

while(dev.GetWireOutValue(0x24) != 1):
    dev.UpdateWireOuts()
    continue
print("Setting register values to required")
for i in range(len(regaddress)):
    R_W = -1
    FLAG = 0
    ADDRS = -1
    REG_Val = -1
    START_BIT = -1
    dev.UpdateWireIns()
    START_BIT =  0
    dev.SetWireInValue(0x03, START_BIT)
    dev.UpdateWireIns()
    time.sleep(.1)
    START_BIT = 1
    REG_ADDR = regaddress[i]
    dev.SetWireInValue(0x00, REG_ADDR) #Input data for Variable 1 using mamoery spacee 0x00
    dev.SetWireInValue(0x01, 1) #Input data for Variable 2 using mamoery spacee 0x01
    REG_VAL = regvalues[i]
    dev.SetWireInValue(0x02, REG_VAL)
    dev.UpdateWireIns()  # Update the WireIns
    time.sleep(.1)
    dev.SetWireInValue(0x03, START_BIT)
    dev.UpdateWireIns()  # Update the WireIns
    time.sleep(.1)
    dev.UpdateWireOuts()
    while(dev.GetWireOutValue(0x21)!=1):
            continue

print('Configuring required registers completed')
    
def writeToReg(add, val):
    R_W = -1
    FLAG = 0
    START_BIT = -1
    dev.UpdateWireIns()
    START_BIT =  0
    dev.SetWireInValue(0x03, START_BIT)
    dev.UpdateWireIns()
    time.sleep(.1)
    START_BIT = 1
    dev.SetWireInValue(0x00, add) #Input data for Variable 1 using mamoery spacee 0x00
    dev.SetWireInValue(0x01, 1) #Input data for Variable 2 using mamoery spacee 0x01
    dev.SetWireInValue(0x02, val)
    dev.UpdateWireIns()  # Update the WireIns
    time.sleep(.1)
    dev.SetWireInValue(0x03, START_BIT)
    dev.UpdateWireIns()  # Update the WireIns
    time.sleep(.1)
    dev.UpdateWireOuts()
    while(dev.GetWireOutValue(0x21)!=1):
            continue
#    print('Write to %d Complete' %add)

def readFromReg(add):
    START_BIT = -1
    dev.UpdateWireIns()
    START_BIT =  0
    dev.SetWireInValue(0x03, START_BIT)
    dev.UpdateWireIns()
    time.sleep(.1)
    START_BIT = 1
    dev.SetWireInValue(0x00, add) #Input data for Variable 1 using mamoery spacee 0x00
    dev.SetWireInValue(0x01, 0) #Input data for Variable 2 using mamoery spacee 0x01
    dev.UpdateWireIns()  # Update the WireIns
    time.sleep(.1)
    dev.SetWireInValue(0x03, START_BIT)
    dev.UpdateWireIns()  # Update the WireIns
    time.sleep(.1)
    dev.UpdateWireOuts()
    readvalue = dev.GetWireOutValue(0x20)
#    print('Reg '+str(add)+' value = '+str(readvalue))
#dev.UpdateWireOuts()
#print('imgreadcompleteval: '+str(dev.GetWireOutValue(0x23)))
dev.SetWireInValue(0x05, 1); #Reset FIFOs and counter
dev.UpdateWireIns();  # Update the WireIns

time.sleep(.01)
#print('next step')

dev.SetWireInValue(0x05, 0); #Release reset signal
dev.UpdateWireIns();  # Update the WireIns

buf = bytearray(315392*4)
buf12 = bytearray(314928*100)

while(dev.GetWireOutValue(0x24) != 1):
    dev.UpdateWireOuts()
    continue

print("start")
print("done: "+str(dev.ReadFromBlockPipeOut(0xa0, 1024, buf)))

print("done")
count = 0;
for x in range(0,314928*4,4):
    buf12[count]=buf[x]
    count+=1
        
        
pixels = np.arange(648*486).reshape(486,648).astype('uint8')

for i in range (0,486,1):
    for j in range (0,648,1):
        pixels[i][j] = buf12[i*648+j]
array = np.array(pixels, dtype=np.uint8)

#figure,ax = plt.subplots(1,1)
#imgplot = plt.imshow(array)
#imgplot.set_cmap('gray')
#exp50 = np.array([])
#abc = 0
#plt.ion()


#reading temp:

def readTemp():
    count = 0
    print(dev.SetWireInValue(0x07,1))
    dev.UpdateWireIns()
    time.sleep(.01)
    while(1):
        dev.UpdateWireOuts()
       # print(dev.GetWireOutValue(0x20))  # Transfer the recived data in result_sum variable
        # convert number into binary first
        Final_Temp = dev.GetWireOutValue(0x25)
        if((float(Final_Temp)/128.0) == 0.0):
            continue
        elif(count == 0):
            average = (float(Final_Temp)/16.0)
            count = count + 1;
        else:
            None
#            print("The Temperature is: "+str((average+(float(Final_Temp)/16.0))/2));

	
# Create a Thread with a function without any arguments
th = threading.Thread(target=readTemp)

#th.start()
global abc
def updateImage():
    global abc
    dev.SetWireInValue(0x06, 1) 
    dev.UpdateWireIns()
    dev.SetWireInValue(0x06, 0)
    dev.UpdateWireIns()
    print("start")
    print("done: "+str(dev.ReadFromBlockPipeOut(0xa0, 1024, buf)))
    count = 0
    for x in range(0,314928*4,4):
        buf12[count]=buf[x]
        count+=1
    for i in range (0,486,1):
        for j in range (0,648,1):
            pixels[i][j] = buf12[i*648+j]
    array = np.array(pixels, dtype=np.uint8)
    return array
    
#    imgplot.set_data(array)
#    return imgplot



while True:
    array = updateImage()
    cv2.imshow('test',array)
    cv2.waitKey(1)
        
#th2 = threading.Thread(target = readImage)
#th2.start()

#ani = FuncAnimation(figure, updateImage, interval=10, blit=False)

#print(abc)
#plt.show()


        
    

dev.Close
    
#%%