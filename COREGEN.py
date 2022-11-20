from math import *
PW = 12
NSTAGES = 11
OW = 32
angle = NSTAGES * [0.0]

for k in range(NSTAGES):
    angle[k] = 2**(PW) / (2.0*pi) * atan2(1.0, 2**k)
    angle_value = int(angle[k])
    print("assign angle_table[{:02d}] = {}'h{:03X};".format(k,PW,angle_value))

gain = 1.0
for k in range(NSTAGES):
    stage_gain = 1.0 + pow(2.0,-2*k)
    stage_gain = sqrt(stage_gain)
    gain = gain * stage_gain
print("Total gain of: {}".format(gain))
print("Eliminate the gain by multiplying by {:02X} then shifting {} bits right".format(round(2**OW / gain),OW))