import math


def tohex(val, nbits):
    return (val + (1 << nbits)) % (1 << nbits)

CLK_FREQ=50000000
SINE_VALUE_BITS = 7
PWM_DAC_MAX_COUNT = 2**SINE_VALUE_BITS
SINE_LUT_BITS = 12
N_SINE_VALUES = 2**SINE_LUT_BITS
# frequency of sine_LUT wave with phase increment of 1
BASE_FREQ = CLK_FREQ / (PWM_DAC_MAX_COUNT * N_SINE_VALUES)
CARRIER_FREQ = 300000
LOW_FREQ =  290000
HIGH_FREQ = 310000
MIN_DIST = 0
MAX_DIST = 2000
DIST_TO_FREQ_SCALE = (HIGH_FREQ-LOW_FREQ) / (MAX_DIST-MIN_DIST)
PHASE_WIDTH=32
PHASE_INTEGER_WIDTH = 12 # Number of bits taken as the integer table index
width=13 # Table width
size=2**width # Table size


with open("dist2freq_step_rom.txt", "w") as f:
    for i in range(size):
        if(i>MIN_DIST and i<MAX_DIST): # Inside range
            frequency=LOW_FREQ+i*DIST_TO_FREQ_SCALE # Target frequency of final pwm signal
            f.write("{:08X}\n".format(tohex(round(
                2**(PHASE_WIDTH-PHASE_INTEGER_WIDTH)*frequency/BASE_FREQ
                ),PHASE_WIDTH)))
        elif (i<=MIN_DIST): # Too close to sensor; stay at LOW_FREQ
            frequency=LOW_FREQ
            f.write("{:08X}\n".format(tohex(round(
                2**(PHASE_WIDTH-PHASE_INTEGER_WIDTH)*frequency/BASE_FREQ
                ),PHASE_WIDTH)))
        elif (i>=MAX_DIST): # Too far from sensor; set to BASE_FREQ
            frequency=CARRIER_FREQ
            f.write("{:08X}\n".format(tohex(round(
                2**(PHASE_WIDTH-PHASE_INTEGER_WIDTH)*frequency/BASE_FREQ
                ),PHASE_WIDTH)))