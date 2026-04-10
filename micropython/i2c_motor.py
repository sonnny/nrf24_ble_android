from machine import Pin, PWM, I2CTarget
import utime
import time

# press ctrl+c to break
time.sleep(5)

FRONT_MOTOR_PWM       = 5
REAR_MOTOR_PWM        = 9
FRONT_MOTOR_DIRECTION = 8
REAR_MOTOR_DIRECTION  = 7

front_motor_pwm = PWM(Pin(FRONT_MOTOR_PWM), freq=1000, duty_u16=0)
rear_motor_pwm  = PWM(Pin(REAR_MOTOR_PWM), freq=1000, duty_u16=0)

front_motor_direction = Pin(FRONT_MOTOR_DIRECTION, Pin.OUT)
rear_motor_direction  = Pin(REAR_MOTOR_DIRECTION, Pin.OUT)
front_motor_direction.on()
rear_motor_direction.on()

need_update = False
my_data = bytearray(16)

def i2c_handler(i2c_target):
    global need_update
    flags = i2c_target.irq().flags()
    if flags & I2CTarget.IRQ_END_WRITE:
        need_update = True

i2c = I2CTarget(1, addr=0x42, sda=Pin(26), scl=Pin(27), mem=my_data)
i2c.irq(i2c_handler)
utime.sleep(1)

while True:
    if need_update:
        s = str(my_data, "utf-8")
        print(s)
        if "thr " in s: # check if throttle settings
            start = s.find('thr ') + 4
            throttle_value = int(s[start:start + 2])
            print(throttle_value)
            if throttle_value != 55:
                rear_motor_pwm.duty_u16(throttle_value * 300)
                front_motor_pwm.duty_u16(throttle_value * 300)

        elif "ste " in s: # check if steering settings
            start = s.find('ste ') + 4
            steering_value = int(s[start:start + 1])
            
        my_data[:] = b'\x00' * len(my_data)
        need_update = False




