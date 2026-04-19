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
  Text('maxleft'),
  Text('left'),
  Text('center'),
  Text('right'),
  Text('maxright'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: connect,
        // backgroundColor: bleConnected ? Colors.blue : Colors.red,
        child: Icon(
          Icons.bluetooth,
          size: 30.0,
          color: bleConnected ? Colors.blue : Colors.red,
        ),
      ),
      body: Column(
        spacing: 35,
        children: [
          SizedBox(height: 50),
          Visibility(
            visible: bleConnected,
            child: Column(
              spacing: 50,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Text(
                        'Throttle:',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),

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
                  constraints: BoxConstraints(minHeight: 40.0, minWidth: 60.0),
                  isSelected: _selectedSteering,
                  children: steering_dir,
                ),

                IconButton(
                  color: lightsOn ? Colors.red : Colors.green,
                  iconSize: 50,
                  icon: Icon(Icons.lightbulb),
                  onPressed: () {
                    setState(() {
                      lightsOn = !lightsOn;
                      //send('llig ' + lightsOn.toString());
                      send('x' + lightsOn.toString() + 'li ');
                    });
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
        
////////// filename: main.c
// make sure to review nrf24.h for pin definitions and spi0 or spi1
// one pinconfig is for pcduino
// one pinconfig is for rp2040zero
// 
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"
#include "nrf24.h"

int main(){
  stdio_init_all();
  i2c_init(i2c0, 400 * 1000);
  gpio_set_function(4,GPIO_FUNC_I2C);
  gpio_set_function(5,GPIO_FUNC_I2C);
  gpio_pull_up(4);
  gpio_pull_up(5);
  sleep_ms(1000);
  // printf("starting...\n");
  nrf24_init();
  nrf24_modeRX();
  char message[16];
  while(1){
    if(nrf24_newMessage()){
      // printf("getting new message\n");
      nrf24_getMessage((uint8_t*)&message);
      // printf("data: %s\n", message);
      i2c_write_blocking(i2c0, 0x42, (uint8_t*)message, 16, false);
      sleep_ms(20);
    }
  }
  return 0;
}

// https://github.com/guser210/NRF_Pico_Arduino/blob/main/Pico/NRF_Transmitter/src/NRF24.cpp

#include <string.h>
#include "pico/stdlib.h"
#include "pico/stdio.h"
#include "hardware/spi.h"
#include "hardware/gpio.h"

#define HIGH 1
#define LOW 0
#define CHANNEL 2
#define CS_LOW  gpio_put(CS,LOW)
#define CS_HIGH gpio_put(CS,HIGH)
#define CE_LOW  gpio_put(CE,LOW)
#define CE_HIGH gpio_put(CE,HIGH)

// pin definitions for rp2040zero
// #define CS 9
// #define CE 8
// #define SCK 10
// #define MOSI 11
// #define MISO 12
//
// pin definitions for pcduino
#define CS   17
#define CE   11
#define SCK  18
#define MOSI 19
#define MISO 16

uint16_t packetsLost = 0;

void writeCommand(uint8_t cmd){
  CS_LOW;
  spi_write_blocking(spi0,&cmd,1);
  CS_HIGH;
}

uint8_t readReg(uint8_t reg){
  reg = 0b00011111 & reg;
  uint8_t result = 0;
  CS_LOW;
  spi_write_blocking(spi0,&reg,1);
  spi_read_blocking(spi0,0xff,&result,1);
  CS_HIGH;
  return result;
}

void writeReg1(uint8_t reg, uint8_t data){
      // write bit | mask bit
  reg = 0b00100000 | (0b00011111 & reg);
  uint8_t buf[2];
  buf[0] = reg;
  buf[1] = data;
  CS_LOW;
  spi_write_blocking(spi0,buf,2);
  CS_HIGH;
}

void writeReg2(uint8_t reg, uint8_t *data, uint8_t size){
  reg = 0b00100000 | (0b00011111 & reg);
  CS_LOW;
  spi_write_blocking(spi0,&reg,1);
  spi_write_blocking(spi0,(uint8_t*)data,size);
  CS_HIGH;
}

void nrf24_init(){

  //hardware init
  spi_init(spi0,8000000);
  gpio_set_function(18,GPIO_FUNC_SPI);
  gpio_set_function(16,GPIO_FUNC_SPI);
  gpio_set_function(19,GPIO_FUNC_SPI);

  gpio_init(CS); gpio_set_dir(CS,HIGH); CS_HIGH;
  gpio_init(CE); gpio_set_dir(CE,HIGH); CE_LOW;

  sleep_ms(10);

  //start config
  CS_HIGH;
  CE_LOW;
  sleep_ms(11);
  writeReg1(0,0b00001110); //confir crc, 2bytes, crd power up
  sleep_us(1500);
  writeReg1(1,0b0); //disable ack
  writeReg1(3,0b00000011); //5 byte rxtx address
  writeReg1(4,0b00000000); //250us autoretrans delay
  writeReg1(5,2); //channel
  writeReg1(6,0b00001110); //2mbs, 0dbm... max power
  writeReg2(0x0a,(uint8_t*)"gyroc",5); //address
  writeReg2(0x010,(uint8_t*)"gyroc",5); //address
  writeReg1(0x11,16); //message length
}

void nrf24_modeTX(){
  uint8_t config = readReg(0);
  config &= ~(1<<0); //clear prim_rx bit
  writeReg1(0,config);
  CE_LOW;
  sleep_us(130); //130us settling time
}

void nrf24_modeRX(){
  uint8_t config = readReg(0);
  config |= (1<<0); // set PRIM_RX bit
  writeReg1(0,config);
  CE_HIGH;
  sleep_us(130);
}

uint8_t nrf24_newMessage(){
    uint8_t status = readReg(0x07);
    if (status & (1 << 6)){ // check new data arrives
      writeReg1(0x07,status | (1 << 6)); // write 1 to clear bit
      return true;
    }
    return false;
  // creturn !(0x00000001 & fifo_status);
   // return((readReg(7) & 0b00001110) < 11);
}

void nrf24_getMessage(uint8_t *buffer){
  uint8_t rx_payload = 0b01100001;
  CS_LOW;
  spi_write_blocking(spi0,&rx_payload,1);
  spi_read_blocking(spi0,0xff,(uint8_t*)buffer,16); // 7 is message length
  CS_HIGH;
  // writeReg1(7,0b01000000);  
}

void nrf24_sendMessage(uint8_t *data){
  uint8_t flush_tx = 0b11100001;
  uint8_t tx_payload = 0b10100000;
  uint8_t status = readReg(7);
  uint8_t buffer[16] = {0};

  memcpy(buffer,data,16);

  if (status & 1){
    writeCommand(flush_tx);
  }

  if (status & 0b00110000)
    writeReg1(7,0b00110000); //clear max_rt bit and dat send(TX_DS)

  CS_LOW;
  spi_write_blocking(spi0,&tx_payload,1);
  spi_write_blocking(spi0,buffer,16);
  CS_HIGH;
  CE_HIGH;

  while((readReg(7) & 0b00110000) == 0){} //wait until data sent or max rt

  CE_LOW;
  writeReg1(7,0b00110000);

  uint8_t observer = readReg(8);
  if (observer & 0b11110000){
    packetsLost += (observer>>4); //keep track of packet lost
    writeReg1(5,CHANNEL);
  }
}

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
