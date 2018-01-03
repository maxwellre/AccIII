# Demo of AccIII device
# Created on 08/09/2017
# Author: Yitian Shao (syt@ece.ucsb.edu)
# Updated on 08/15/2017 Corrected unit scale
#-----------------------------------------------------------------------------------------------------------------------
import matplotlib.pyplot as plt
import numpy as np
import binascii
#-----------------------------------------------------------------------------------------------------------------------
print('Processing data... wait for 30 secs')
#-----------------------------------------------------------------------------------------------------------------------
# Configuration
read_num = 48
half_read = int(0.5*read_num) # Must be a integer
#-----------------------------------------------------------------------------------------------------------------------
# Import data rate
file_h = open('data_rate.txt', 'r')
Fs = file_h.read()
file_h.close()
Fs = float(Fs)
T = 1/Fs # Sampling time interval

#-----------------------------------------------------------------------------------------------------------------------
# Import data
file_h = open('data.bin', 'rb')
data_in = file_h.read()
file_h.close()

data_in = data_in[1:]
read_byte_num = len(data_in)
actual_sample_num = read_byte_num/read_num
data_num = np.floor(actual_sample_num)-1
samp_num = int(np.floor(data_num/6))
t = [x*T for x in range(samp_num)]

print('Total sample number = %d, sample time = %.1f secs' % (samp_num ,t[-1]))

if data_num < actual_sample_num:
    hex_data = data_in[int(read_num):int((data_num +1)*read_num)]
else:
    print('Data did not read correctly!')

# Hex string to decimal data conversion---------------------------------------------------------------------------------
odd_ind = range(0,48,2)
even_ind = range(1,48,2)

acc_data = np.zeros((samp_num, read_num, 3))
count = 0
for i in range(samp_num):
    # Odd number sensor
    for j in range(3):
        for k in range(half_read):
            temp = 256*int(binascii.hexlify(hex_data[(48*count)+half_read+k]), base=16) + \
            int(binascii.hexlify(hex_data[(48*count)+k]), base=16)
            if (temp > 32767):
                temp = temp -65536 # Format correction
            acc_data[i][odd_ind[k]][j] = temp
        count = count + 1

    # Even number sensor
    for j in range(3):
        for k in range(half_read):
            temp = 256 * int(binascii.hexlify(hex_data[(48*count)+half_read+k]), base=16) + \
                                         int(binascii.hexlify(hex_data[(48*count)+k]), base=16)
            if (temp > 32767):
                temp = temp -65536 # Format correction
            acc_data[i][even_ind[k]][j] = temp
        count = count + 1

#-----------------------------------------------------------------------------------------------------------------------
# Display data
GSCALE = 0.00073 # Accelerometer scale: 0.73 mg/digit
#ax = 2 # 0:X-axis, 1:Y-axis, 2:Z-axis
acc_ind = np.concatenate((range(9),range(10,19),range(20,29),range(30,39),range(40,46)))

for ax in range(3):
    plt.figure()
    for k in range(42):
        plt.subplot(14,3,k+1)
        plt.plot(t,GSCALE*acc_data[:,acc_ind[k],ax],linewidth=0.3)
        plt.xlim(t[0], t[-1])
        plt.ylim( -16, 16 )
        if (k==0):
            plt.yticks(range(-16,16+1,8), range(-16,16+1,8), size='small')
            plt.ylabel('Acceleration (m/s2) \n Acc1', fontsize=10)
        else:
            plt.yticks([], [])
            plt.ylabel('Acc%d' % (acc_ind[k]+1), fontsize=10)

        if (k==41):
            plt.xlabel('Time (secs)', fontsize=10)
        else:
            plt.xticks([], [])

    plt.get_current_fig_manager().window.state('zoomed')
    plt.show()

#-----------------------------------------------------------------------------------------------------------------------
# Display spectrum
# FFT_bin_num = int(0.5*samp_num)+1
# freq = 0.5*Fs*np.linspace(0, 1, num=FFT_bin_num)
#
# plt.figure()
# for k in range(42):
#     plt.subplot(14,3,k+1)
#     a_chan = acc_data[:,acc_ind[k],ax]
#     spectr = abs(np.fft.fft(a_chan)/samp_num)
#     #spectr = 20*np.log10(2*spectr[np.arange(FFT_bin_num)])
#     spectr = 2*spectr[np.arange(FFT_bin_num)]
#
#     plt.plot(freq,spectr,linewidth=0.3)
#     plt.xlim(freq[0], freq[-1])
#
#     plt.yticks([], [])
#     plt.ylabel('Acc%d' % (acc_ind[k]+1), fontsize=10)
#
#     if (k>=39):
#         plt.xlabel('Frequency (Hz)', fontsize=10)
#     else:
#         plt.xticks([], [])
#
# plt.get_current_fig_manager().window.state('zoomed')
# plt.show()