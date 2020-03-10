# -*- coding: utf-8 -*-

#%%
# import various libraries necessery to run your Python code
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("JTEG_Test_File.bit"); # Configure the FPGA with this bit file

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

R_W = -1
FLAG = 0
ADDRS = -1
REG_Val = -1
START_BIT = -1
while(1):
    R_W = -1
    FLAG = 0
    ADDRS = -1
    REG_Val = -1
    START_BIT = -1
    dev.UpdateWireIns()
    while(FLAG == 0):
        print('Type 0 for Read or 1 for Write: ')
        R_W = int(input())
        if(int(R_W) == 0):
            print('Reading\n')
            FLAG = 1
        elif(int(R_W) == 1):
            print('Writting\n')
            FLAG = 1
        else:
            print('Invalid Input\n')
    START_BIT =  0
    dev.SetWireInValue(0x03, START_BIT)
    dev.UpdateWireIns()
    FLAG = 0
    while(FLAG == 0):
        print('Type Address in Decimal: ')
        ADDRS = int(input())
        if(int(ADDRS)<128):
            print('Address is '+str(ADDRS)+'\n')
            FLAG = 1
        else:
            print('Invalid Address\n')
    if(int(R_W) == 1):    
        print('Type Value for Register: ')
        REG_Val = input()
        REG_Val = int(REG_Val)
    START_BIT = 1
    dev.SetWireInValue(0x00, ADDRS) #Input data for Variable 1 using mamoery spacee 0x00
    dev.SetWireInValue(0x01, R_W) #Input data for Variable 2 using mamoery spacee 0x01
    if(R_W == 1):
        dev.SetWireInValue(0x02, REG_Val)
    dev.UpdateWireIns()  # Update the WireIns
    time.sleep(.5)
    dev.SetWireInValue(0x03, START_BIT)
    dev.UpdateWireIns()  # Update the WireIns
    time.sleep(.5)
    dev.UpdateWireOuts()
    if(R_W == 0):
        print('Read Complete ' +str(dev.GetWireOutValue(0x22)))
        read_value = dev.GetWireOutValue(0x20)
        print('Read Value '+str(read_value)+' from register '+str(ADDRS))
    elif(R_W == 1):
        while(dev.GetWireOutValue(0x21)!=1):
            continue
        print('Write Complete')
    

dev.Close
    
#%%