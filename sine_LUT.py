import math

def tohex(val, nbits):
    return (val + (1 << nbits)) % (1 << nbits)
    
width=8
width_hex=str(math.floor(width/4))
size=2**width

with open("sine_rom.txt", "w") as f:
    for i in range(size):
        f.write(("{:0"+width_hex+"X} \n").format(tohex(round(2**(width) * math.sin(i*2*math.pi/size)),width)))