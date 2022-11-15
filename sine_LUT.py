import math

def tohex(val, nbits):
    return (val + (1 << nbits)) % (1 << nbits)
    
width=7 # Maximum width of sine_value = maximum width of PWM_DAC count
PHASE_INTEGER_WIDTH=7 # Number of phase bits interpreted as an integer
width_hex=str(math.ceil(width/4))
size=2**PHASE_INTEGER_WIDTH

with open("sine_rom.txt", "w") as f:
    for i in range(size):
        sine_value=round(2**(width) * (math.sin(i*2*math.pi/size)+1)/2)
        if(sine_value>=2**width): # If overflow, cap at max value
            sine_value=2**width-1
        f.write(("{:0"+width_hex+"X} \n").format(tohex(sine_value,width)))