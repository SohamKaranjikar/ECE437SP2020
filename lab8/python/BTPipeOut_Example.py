# import various libraries necessery to run your Python code
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel();  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("");      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("BTPipeExample.bit"); # Configure the FPGA with this bit file

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.");
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)));
    print("Exiting the program.");
    sys.exit ();

if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.");
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)));
    print ("Exiting the progam.");
    sys.exit ();
print("----------------------------------------------------")
print("----------------------------------------------------")

#%% 
dev.SetWireInValue(0x04, 1); #Reset FIFOs and counter
dev.UpdateWireIns();  # Update the WireIns

dev.SetWireInValue(0x4, 0); #Release reset signal
dev.UpdateWireIns();  # Update the WireIns
 
buf = bytearray(1024);
dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut

f= open("data.txt","w+")

#%%
for i in range (0, 1024, 4):
    result = buf[i] + (buf[i+1]<<8) + (buf[i+2]<<16) + (buf[i+3]<<24);
    f.write("%d\r\n"%result)
    print (result)

dev.ReadFromBlockPipeOut(0xa0, 1024, buf);
for i in range (0, 1024, 4):
    result = buf[i] + (buf[i+1]<<8) + (buf[i+2]<<16) + (buf[i+3]<<24);
    f.write("%d\r\n"%result)
    print (result)
    
f.close();
#%%