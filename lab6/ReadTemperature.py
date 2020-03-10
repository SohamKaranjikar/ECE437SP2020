# This code reads data from the temperature sensor and outputs the results on the screen.
# The bit file programs OpalKelly’s XEM7310 board with a finite state machine that implements 
# I2C protocol. With this protocol, temperature data is received from the temperature sensor
# to the FPGA. Then the FPGA transfers the data from the two registers containing 
# the temperature data to the PC using OKWireOut.

# import various libraries necessery to run your Python code
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library
import visa
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import time
mpl.style.use('ggplot')

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel();  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("");      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("I2C_Temperature.bit"); # Configure the FPGA with this bit file

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.");
else:    
    print ("FrontPanel host interface not detected. The error code num ber is:" + str(int(SerialStatus)));
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

device_manager = visa.ResourceManager()
devices = device_manager.list_resources()
number_of_device = len(devices)

power_supply_id = -1;
waveform_generator_id = -1;
digital_multimeter_id = -1;
oscilloscope_id = -1;

for i in range (0, number_of_device):

# check that it is actually the power supply
    try:
        device_temp = device_manager.open_resource(devices[i])
        print("Instrument connect on USB port number [" + str(i) + "] is " + device_temp.query("*IDN?"))
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.2-6.0-2.0\r\n'):
            power_supply_id = i        
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.0-6.0-2.0\r\n'):
            power_supply_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,33511B,MY52301259,3.03-1.19-2.00-52-00\n'):
            waveform_generator_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,34461A,MY53207920,A.01.10-02.25-01.10-00.35-01-01\n'):
            digital_multimeter_id = i 
        if (device_temp.query("*IDN?") == 'Keysight Technologies,34461A,MY53212931,A.02.08-02.37-02.08-00.49-01-01\n'):
            digital_multimeter_id = i            
        if (device_temp.query("*IDN?") == 'KEYSIGHT TECHNOLOGIES,MSO-X 3024T,MY54440319,07.10.2017042905\n'):
            oscilloscope_id = i                        
        device_temp.close()
    except:
        print("Instrument on USB port number [" + str(i) + "] cannot be connected. The instrument might be powered of or you are trying to connect to a mouse or keyboard.\n")

if (power_supply_id == -1):
    print("Power supply instrument is not powered on or connected to the PC.")    
else:
    print("Power supply is connected to the PC.")
    power_supply = device_manager.open_resource(devices[power_supply_id]) 
    
output_voltage = np.arange(0, 4.7, .08 )
temp_arr1 = np.array([])
meausured_temp = np.array([])
meausured_temp_sd = np.array([])

print(power_supply.write("OUTPUT ON")) # power supply output is turned on

for v in output_voltage:
         # apply the desired voltage on teh 25V power supply and limist the output current to 0.06A
    power_supply.write("APPLy P6V, %0.2f, 0.110" % v)
     
         # pause 150ms to let things settle
    time.sleep(1.5)
         
    for x in range(100):
             
         # read the output voltage on the 25V power supply
        dev.SetWireInValue(0x00, 1); #Sending 1 at memory locaiton 0x00 starts the FSM
        dev.UpdateWireIns();  # Update the WireIns    
    
        dev.UpdateWireOuts()  # Recieve the temperature data
        time.sleep(.1)
        temperature_msb = dev.GetWireOutValue(0x20)  # MSB temperature register
        temperature_lsb = dev.GetWireOutValue(0x21)  # LSB temperature register
        temperature = ((temperature_msb<<8) + temperature_lsb)/128.0;
        temp_arr1 = np.append(temp_arr1, temperature)
        
    meausured_temp = np.append(meausured_temp, np.average(temp_arr1))
    meausured_temp_sd = np.append(meausured_temp_sd, np.std(temp_arr1))
    temp_arr1 = np.array([])
             
             
             
print(power_supply.write("OUTPUT OFF"))
power_supply.close()

plt.figure()
plt.plot(output_voltage,meausured_temp)
plt.title("Applied Volts vs. Mean Temp")
plt.xlabel("Applied Volts [V]")
plt.ylabel("Mean Temp[C]")
plt.draw()

plt.figure()
plt.plot(output_voltage,meausured_temp_sd)
plt.title("Applied Volts vs. STDV Temp")
plt.xlabel("Applied Volts [V]")
plt.ylabel("STDV Temp[C]")
plt.draw()
#%% Press control-C in the console window to stop the loop

