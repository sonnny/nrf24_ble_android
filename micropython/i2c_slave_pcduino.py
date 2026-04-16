#
# process i2c data from nrf24l01 receiver
# wiring for picoduino uno
# breakdown to :
#
#    throttle: 0 - 100
#    direction: true / false
#    steering:  0, 1, 2, 3 ,4
#    lights: true / false
#
# 
import utime
from machine import I2CTarget, Pin

utime.sleep(3)

update = False
data = bytearray(16)

def i2c_handler(i2c_target):
    global update
    flags = i2c_target.irq().flags()
    if flags & I2CTarget.IRQ_END_WRITE:
        update = True

def process_data():
    global data

    #print(data.hex())

    s = str(data, "utf-8")

    if "thr " in s:
        start = s.find('thr ') + 4
        throttle_value = s[start:start + 2]
        print("throttle: " + throttle_value)

    elif "dir " in s:
        start = s.find('dir ') + 4
        direction_value = s[start:start + 4]
        print("direction: " + direction_value)

    elif "ste " in s:
        start = s.find('ste ') + 4
        steering_value = s[start:start + 1]
        print("steering: " + steering_value)

    elif "li" in s:
        #print(s.encode().hex(' '))
        start = s.find('li ')
        lights_value = s[8:12]
        print("lights value: " + lights_value) 
        
    data[:] = b'\x00' * len(data)
    

i2c = I2CTarget(0, addr=0x42, scl=Pin(5), sda=Pin(4), mem=data)
i2c.irq(i2c_handler)

while True:
    if update:
        process_data()
        update = False
        
