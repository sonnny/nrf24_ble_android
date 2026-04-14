////////// filename: source.dart
import 'package:flutter/material.dart';

class Source extends StatelessWidget {
  @override
  Widget build(BuildContext bc) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Text('''
////////// filename: main.dart
import 'package:flutter/material.dart';
import './bottom_nav.dart';
import './home.dart';
import './app.dart';
import './source.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});
  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  int page = 0;

  @override
  Widget build(BuildContext bc) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'bottom nav demo',
      home: Scaffold(
        body: [Home(), App(), Source()][page],

        bottomNavigationBar: NavigationBar(
          selectedIndex: page,
          onDestinationSelected: (int i) {
            setState(() {
              page = i;
            });
          },
          destinations: bottom_nav,
        ),
      ),
    );
  }
}

////////// filename: bottom_nav.dart
import 'package:flutter/material.dart';

List<NavigationDestination> bottom_nav = [
  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),

  NavigationDestination(icon: Icon(Icons.bluetooth), label: 'App'),

  NavigationDestination(icon: Icon(Icons.note), label: 'Source'),
];

////////// filename: app.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

// label for steering row buttons
const List<Widget> steering_dir = <Widget>[
  Text('max left'),
  Text('left'),
  Text('center'),
  Text('right'),
  Text('max right'),
];

class App extends StatefulWidget {
  App({super.key});
  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  bool bleConnected = false;
  late BluetoothCharacteristic bleTx;
  double _value = 0.0;
  bool direction = false;
  bool lightsOn = false;
  List<bool> _selectedSteering = <bool>[false, false, true, false, false];

  Future<void> connect() async {
    final BluetoothDevice bleDevice = BluetoothDevice.fromId(
      "28:CD:C1:08:28:9C",
    );
    late BluetoothService bleService;
    await bleDevice.connect(license: License.free);
    List<BluetoothService> services = await bleDevice.discoverServices();
    services.forEach((s) {
      if (s.serviceUuid.toString() == "ff10") bleService = s;
    });
    for (BluetoothCharacteristic c in bleService.characteristics) {
      if (c.characteristicUuid.toString() == "ff11") {
        bleTx = c;
        setState(() {
          bleConnected = true;
        });
      }
    }
  }

  void send(val) async {
    List<int> data = utf8.encode(val);
    await bleTx.write(data);
  }

  @override
  Widget build(BuildContext bc) {
    return Scaffold(
      body: Column(
        spacing: 50,
        children: [
          SizedBox(height: 50),
          ElevatedButton(child: Text('ble connect'), onPressed: connect),
          Visibility(
            visible: bleConnected,
            child: Column(
              spacing: 50,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Throttle:',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),

                      // SizedBox(width: 5),
                      Expanded(
                        child: Slider(
                          value: _value,
                          min: 0.0,
                          max: 100.0,
                          divisions: 10,
                          label: _value.round().toString(),
                          onChanged: (double d) {
                            setState(() {
                              _value = d;
                            });
                          },
                          onChangeEnd: (double newValue) {
                            setState(() {
                              _value = newValue;
                              send('tthr ' + newValue.round().toString());
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SwitchListTile(
                  value: direction,
                  title: Text(
                    'Direction',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  subtitle: Text('forward or reverse'),
                  onChanged: (bool value) {
                    setState(() {
                      direction = !direction;
                      send('ddir ' + direction.toString());
                    });
                  },
                ),
                Center(
                  child: Text(
                    'Steering',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                // single choice horizontal toggle buttons
                ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    send('sste ' + index.toString());
                    setState(() {
                      for (int i = 0; i < _selectedSteering.length; i++) {
                        _selectedSteering[i] = i == index;
                      }
                    });
                  },
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: Colors.red[700],
                  selectedColor: Colors.white,
                  fillColor: Colors.red[200],
                  color: Colors.red[400],
                  constraints: BoxConstraints(minHeight: 40.0, minWidth: 80.0),
                  isSelected: _selectedSteering,
                  children: steering_dir,
                ),

                IconButton(
                  iconSize: 30,
                  icon: Icon(Icons.lightbulb),
                  onPressed: () {
                    lightsOn = !lightsOn;
                    send('llig ' + lightsOn.toString());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
throttle = Label(wri,2,2,wri.stringlen('0123456789012345'))
direction = Label(wri,40,2,wri.stringlen('0123456789012345'))
steering = Label(wri,80,2,wri.stringlen('0123456789012345'))
throttle.value('starting.......')
refresh(ssd)
utime.sleep(1)
while True:
    if need_update:
        s=str(my_data, "utf-8")
        print(s)
        if "thr " in s:
            start = s.find('thr ') + 4
            thr_value = s[start:start + 2]
            #print('throttle: ' + thr_value)
            throttle.value("throttle: " + thr_value)
        elif "dir " in s:
            start = s.find('dir ') + 4
            dir_value = s[start:start + 4]
            direction.value("direction: " + dir_value)
        elif "ste " in s:
            start = s.find('ste ') + 4
            ste_value = s[start:start + 1]
            steering.value("steering: " + ste_value)
        refresh(ssd)
        my_data[:] = b'\x00' * len(my_data)
        need_update=False
        #utime.sleep(1)
        
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

import machine
import utime

servo = machine.PWM(machine.Pin(13))
servo.freq(50)

def interval_mapping(x, in_min, in_max, out_min, out_max):
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

def servo_write(pin,angle):
    pulse_width=interval_mapping(angle, 0, 180, 0.5,2.5)
    duty=int(interval_mapping(pulse_width, 0, 20, 0,65535))
    pin.duty_u16(duty)

while True:
    for angle in range(180):
        servo_write(servo,angle)
        utime.sleep_ms(20)
    for angle in range(180,-1,-1):
        servo_write(servo,angle)
        utime.sleep_ms(20)



////////// filename: main.c
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "nrf24.h"

int main(){
  stdio_init_all();
  i2c_init(i2c1, 400 * 1000);
  gpio_set_function(2,GPIO_FUNC_I2C);
  gpio_set_function(3,GPIO_FUNC_I2C);
  gpio_pull_up(2);
  gpio_pull_up(3);
  sleep_ms(1000);
  printf("starting...\n");
  nrf24_init();
  nrf24_modeRX();
  char message[16];
  while(1){
    if(nrf24_newMessage()){
      // printf("getting new message\n");
      nrf24_getMessage((uint8_t*)&message);
      // printf("data: %s\n", message);
      i2c_write_blocking(i2c1, 0x42, (uint8_t*)message, 16, false);
      sleep_ms(50);
    }
  }
  return 0;


////////// filename: main.c
#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/multicore.h"
#include "thread/pt_cornell_rp2040_v1_3.h"
#include "ble/ble.h"
#include "nrf24.h"

char ble_data[16];

static PT_THREAD (ble_thread(struct pt *pt)){
  PT_BEGIN(pt);
  while(1){
    PT_SEM_SAFE_WAIT(pt, &BLUETOOTH_READY);
    nrf24_sendMessage(ble_data);
    // printf("data from ble: %s\n", ble_data);
  }
  PT_END(pt);}
  
static PT_THREAD (blink_thread(struct pt *pt)){
  PT_BEGIN(pt);
 static bool led_state = false;
  gpio_init(13);
  gpio_set_dir(13, GPIO_OUT);
  PT_INTERVAL_INIT();
  while(1){
    led_state = !led_state;
    gpio_put(13, led_state);
    PT_YIELD_INTERVAL(1000000);}
  PT_END(pt);}

void main(void){

stdio_init_all();
nrf24_init(); // init nrf24 radio
nrf24_modeTX(); // put nrf24 radio in transmit mode
sleep_ms(500);
multicore_launch_core1(bt_main);
pt_add_thread(ble_thread);
pt_add_thread(blink_thread);
pt_sched_method = SCHED_ROUND_ROBIN;
pt_schedule_start;}



        
      '''),
        ),
      ),
    );
  }
}
