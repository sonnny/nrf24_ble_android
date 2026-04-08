#
# sample code for i2c master
# 
# from machine import I2C, Pin
# i2c = I2C(1, sda=Pin(10), scl=Pin(11))
# i2c.writeto_mem(0x42,0x00,b'Speed 99.9')
#
# 
import utime
# import uos
from color_setup import ssd
# On a monochrome display Writer is more efficient than CWriter.
from gui.core.writer import Writer
from gui.core.nanogui import refresh
from gui.core.colors import *
from gui.widgets.label import Label

from machine import I2CTarget,Pin

# Fonts
import gui.fonts.freesans20 as freesans20
import gui.fonts.arial10 as arial10
import gui.fonts.courier20 as fixed
import gui.fonts.font6 as small

need_update = False
my_data = bytearray(16)
wri=CWriter
text1=Label

def i2c_handler(i2c_target):
    global need_update
    flags=i2c_target.irq().flags()
    if flags & I2CTarget.IRQ_END_WRITE:
        need_update = True


i2c=I2CTarget(1,addr=0x42,sda=Pin(10),scl=Pin(11),mem=my_data)
i2c.irq(i2c_handler)
ssd.fill(0)
refresh(ssd)
CWriter.set_textpos(ssd,0,0)
wri = Writer(ssd, fixed, verbose=False)
# wri=CWriter(ssd,freesans20,GREEN,BLACK,verbose=False)
wri.set_clip(False,False,False)
textfield = Label(wri,0,2,wri.stringlen('0123456789012345'))
#valuefield = Label(wri,2,80,wri.stringlen('123456'))
textfield.value('starting.......')
refresh(ssd)
utime.sleep(3)
while True:
    if need_update:
        #if my_data[0] == 0x41: textfield.value("Accelerati")  # 0x41 = 'A'
        #elif my_data[0] == 0x44: textfield.value("Direction ") # 0x44 = 'D'
        #elif my_data[0] == 0x53: textfield.value("Steering  ") # 0x53 = 'S' 
        s=str(my_data, "utf-8")
        #s=my_data.decode('ascii')
        #words=s.split
        #textfield.value(words()[0])
        textfield.value(s)
        #valuefield.value(words()[1])
        #textfield.value(s)
        refresh(ssd)
        my_data[:] = b'\x00' * len(my_data)
        need_update=False
        #utime.sleep(1)
        
        
    
