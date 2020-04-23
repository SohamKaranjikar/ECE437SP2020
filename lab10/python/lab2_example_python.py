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
regvalues = [232,1,0,0,1,232,0,0,3,44,240,10,2,9,2,187,240,10,112,98,34,64,94,110,91,82,80,91]
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
#    print('Write to %d Complete' %regaddress[i])

#for i in range(len(regaddress)):
#    R_W = -1
#    FLAG = 0
#    ADDRS = -1
#    REG_Val = -1
#    START_BIT = -1
#    dev.UpdateWireIns()
#    START_BIT =  0
#    dev.SetWireInValue(0x03, START_BIT)
#    dev.UpdateWireIns()
#    time.sleep(.1)
#    START_BIT = 1
#    REG_ADDR = regaddress[i]
#    dev.SetWireInValue(0x00, REG_ADDR) #Input data for Variable 1 using mamoery spacee 0x00
#    dev.SetWireInValue(0x01, 0) #Input data for Variable 2 using mamoery spacee 0x01
#    dev.UpdateWireIns()  # Update the WireIns
#    time.sleep(.1)
#    dev.SetWireInValue(0x03, START_BIT)
#    dev.UpdateWireIns()  # Update the WireIns
#    time.sleep(.1)
#    dev.UpdateWireOuts()
#    readvalue = dev.GetWireOutValue(0x20)
#    print('Reg '+str(REG_ADDR)+' value = '+str(readvalue))

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
    print('Reg '+str(add)+' value = '+str(readvalue))
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

print('READ: '+str(dev.ReadFromBlockPipeOut(0xa0, 1024, buf)))

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

figure,ax = plt.subplots(1,1)
imgplot = plt.imshow(array)
imgplot.set_cmap('gray')
exp50 = np.array([])
abc = 0
totalframes = 1;
plt.ion()
def updateImage(i):
    global abc, exp50, totalframes
#    if(totalframes >= 30):
#        exit
    if(abc == 100):
        print(exp50)
    else:
        abc += 1
        dev.SetWireInValue(0x06, 1) 
        dev.UpdateWireIns()
        dev.SetWireInValue(0x06, 0)
        dev.UpdateWireIns()
        dev.ReadFromBlockPipeOut(0xa0, 1024, buf)
    #    print('READ: '+str(dev.ReadFromBlockPipeOut(0xa0, 1024, buf)))
        
    #    print("done")
        count = 0
        for x in range(0,314928*4,4):
            buf12[count]=buf[x]
            count+=1
        for i in range (0,486,1):
            for j in range (0,648,1):
                pixels[i][j] = buf12[i*648+j]
        array = np.array(pixels, dtype=np.uint8)
        imgplot.set_data(array)
        exp50  = np.append(exp50,pixels[318][16])
        return imgplot
    
#while True:
#    updateImage()
#    figure.canvas.draw_idle()
#    plt.pause(.0001)
#    print("done")
ani = FuncAnimation(figure, updateImage, interval=10, blit=False)
plt.show()
#while True:
#    updateImage()
#plt.show()
