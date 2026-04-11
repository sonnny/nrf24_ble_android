from machine import Pin, PWM, I2CTarget
import utime
import time

# press ctrl+c to break
time.sleep(5)

need_update = False
my_data = bytearray(16)

def i2c_handler(i2c_target):
    global need_update
    flags = i2c_target.irq().flags()
    if flags & I2CTarget.IRQ_END_WRITE:
        need_update = True

i2c = I2CTarget(1, addr=0x42, sda=Pin(2), scl=Pin(3), mem=my_data)
i2c.irq(i2c_handler)
utime.sleep(1)

while True:
    if need_update:
        s = str(my_data, "utf-8")
        print(s)
        my_data[:] = b'\x00' * len(my_data)
        need_update = False




