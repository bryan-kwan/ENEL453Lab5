import math


def tohex(val, nbits):
    return (val + (1 << nbits)) % (1 << nbits)

CLK_FREQ=50000000
BASE_FREQ = 300000
LOW_FREQ =  290000
HIGH_FREQ = 310000
MIN_DIST = 0
MAX_DIST = 2000
DIST_TO_FREQ_SCALE = (HIGH_FREQ-LOW_FREQ) / (MAX_DIST-MIN_DIST)
PHASE_WIDTH=32
width=13 # Table width
size=2**width # Table size

with open("dist2freq_step_rom.txt", "w") as f:
    for i in range(size):
        if(i>MIN_DIST and i<MAX_DIST): # Inside range
            frequency=LOW_FREQ+i*int(DIST_TO_FREQ_SCALE) # Target frequency
            f.write("{:08X}\n".format(tohex(round(
                2**PHASE_WIDTH*frequency/CLK_FREQ
                ),PHASE_WIDTH)))
        elif (i<=MIN_DIST): # Too close to sensor; stay at LOW_FREQ
            frequency=LOW_FREQ
            f.write("{:08X}\n".format(tohex(round(
                2**PHASE_WIDTH*frequency/CLK_FREQ
                ),PHASE_WIDTH)))
        elif (i>=MAX_DIST): # Too far from sensor; cap at HIGH_FREQ
            frequency=HIGH_FREQ
            f.write("{:08X}\n".format(tohex(round(
                2**PHASE_WIDTH*frequency/CLK_FREQ
                ),PHASE_WIDTH)))