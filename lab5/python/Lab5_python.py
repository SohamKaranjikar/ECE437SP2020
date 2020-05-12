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
#variable_1 = 50; # variable_1 is initilized to digitla number 50
#variable_2 = 14; # # variable_2 is initilized to digitla number 14
#print("Variable 1 is initilized to " + str(int(variable_1)))
#print("Variable 2 is initilized to " + str(int(variable_2)))

#dev.SetWireInValue(0x00, variable_1) #Input data for Variable 1 using mamoery spacee 0x00
#dev.SetWireInValue(0x01, variable_2) #Input data for Variable 2 using mamoery spacee 0x01
#dev.SetWireInValue(0x02, 0) #Input data for Variable 2 using mamoery spacee 0x02
#dev.SetWireInValue(0x03, 10000000) #Input data for Variable 2 using mamoery spacee 0x02
#dev.UpdateWireIns()  # Update the WireIns

#%% 
# We will read data from the FPGA in two different variables
# Since we are using a slow clock on the FPGA to compute the results
# we need to wait for the resutl to be computed
#time.sleep(0.5)                 

# First recieve data from the FPGA by using UpdateWireOuts
count = 0;
average = 0;
print(dev.SetWireInValue(0x00,1))
dev.UpdateWireIns()
time.sleep(.01)
while(1):
    dev.UpdateWireOuts()
   # print(dev.GetWireOutValue(0x20))  # Transfer the recived data in result_sum variable
    # convert number into binary first
    Final_Temp = dev.GetWireOutValue(0x20)
    if((float(Final_Temp)/128.0) == 0.0):
         continue
    elif(count == 0):
        average = (float(Final_Temp)/16.0)
        count = count + 1;
    else:
        average = (average+(float(Final_Temp)/16.0))/2;
        count = count + 1;
    
    if(count == 10):
        print("The temperature is: "+str(average))
        average = 0
        count = 0
        
    

dev.Close
    
#%%