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
