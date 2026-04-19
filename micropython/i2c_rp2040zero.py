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
from micropython import const
from machine import I2CTarget, Pin, PWM

STEERING = const(8)

SPEED_RATE = const(280)

PWM1 = const(2)
DIR1 = const(3)

PWM2 = const(0)
DIR2 = const(1)

utime.sleep(3)

update = False
data = bytearray(16)

steering = PWM(Pin(STEERING), freq=50)

def i2c_handler(i2c_target):
    global update
    flags = i2c_target.irq().flags()
    if flags & I2CTarget.IRQ_END_WRITE:
        update = True

def interval_mapping(x, in_min, in_max, out_min, out_max):
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

def servo_write(angle):
    pulse_width = interval_mapping(angle, 0, 180, 0.5, 2.5)
    duty = int(interval_mapping(pulse_width, 0, 20, 0, 65535))
    steering.duty_u16(duty)
    
def process_data():
    global data

    #print(data.hex())

    s = str(data, "utf-8")

    if "thr " in s:
        start = s.find('thr ') + 4
        throttle_value = s[start:start + 2]
        try:
            print("throttle: " + throttle_value)
            motor_rear.duty_u16(int(throttle_value) * SPEED_RATE)
            motor_front.duty_u16(int(throttle_value) * SPEED_RATE)
        except ValueError:
            print("error")

    elif "dir " in s:
        start = s.find('dir ') + 4
        direction_value = s[start:start + 4]
        if direction_value == 'true':
            dir_rear.on()
            dir_front.on()
        else:
            dir_rear.off()
            dir_front.off()
        print("direction: " + direction_value)

    elif "ste " in s:
        start = s.find('ste ') + 4
        steering_value = s[start:start + 1]
        if steering_value == '0': servo_write(30)
        elif steering_value == '1': servo_write(80) # left
        elif steering_value == '2': servo_write(110) # center
        elif steering_value == '3': servo_write(135) # right
        elif steering_value == '4': servo_write(180)
        print("steering: " + steering_value)

    elif "li" in s:
        #print(s.encode().hex(' '))
        start = s.find('li ')
        lights_value = s[8:12]
        print("lights value: " + lights_value) 
        
    data[:] = b'\x00' * len(data)

# start
i2c = I2CTarget(0, addr=0x42, scl=Pin(5), sda=Pin(4), mem=data)
i2c.irq(i2c_handler)

motor_rear = PWM(Pin(PWM2), freq=1000, duty_u16=0)
motor_front = PWM(Pin(PWM1), freq=1000, duty_u16=0)

dir_rear = Pin(DIR2, Pin.OUT)
dir_front = Pin(DIR1, Pin.OUT)

dir_rear.on()
dir_front.on()

print('ready...')
while True:
    if update:
        process_data()
        update = False
        
