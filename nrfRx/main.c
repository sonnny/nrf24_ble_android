////////// filename: main.c
// make sure to review nrf24.h for pin definitions and spi0 or spi1
// one pinconfig is for pcduino
// one pinconfig is for rp2040zero
// 
#include <stdio.h>
#include "pico/stdlib.h"
#include "nrf24.h"

int motor_speed;

int main(){
  stdio_init_all();
  // i2c_init(i2c0, 400 * 1000);
  // gpio_set_function(4,GPIO_FUNC_I2C);
  // gpio_set_function(5,GPIO_FUNC_I2C);
  // gpio_pull_up(4);
  // gpio_pull_up(5);
  sleep_ms(1000);
  // printf("starting...\n");
  nrf24_init();
  nrf24_modeRX();
  char message[16];
  while(1){
    if(nrf24_newMessage()){
      // printf("getting new message\n");
      nrf24_getMessage((uint8_t*)&message);

      switch(message[0]){
        case 'T': motor_speed = (message[3] - 0x30) * 10;
                  printf("motor speed: %d\n", motor_speed);
                  break;

        case 'D': if (message[3] == 't') printf("forward direction\n");
                  else printf("reverse direction\n");
                  break;

        case 'S': switch(message[3]){
                    case 0x30: printf("max left\n"); break;
                    case 0x31: printf("left\n"); break;
                    case 0x32: printf("center\n"); break;
                    case 0x33: printf("right\n"); break;
                    case 0x34: printf("max right\n"); break;
          }
      }
      // for(int i=0; i<16; i++) printf("%02x ",message[i]);
      // printf("\n");
      // printf("data: %s\n", message);
     //  i2c_write_blocking(i2c0, 0x42, (uint8_t*)message, 16, false);
      sleep_ms(20);
    }
  }
  return 0;
}
