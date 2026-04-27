////////// filename: main.c
// make sure to review nrf24.h for pin definitions and spi0 or spi1
// one pinconfig is for pcduino
// one pinconfig is for rp2040zero
// 
#include <stdio.h>
#include "pico/stdlib.h"
#include "nrf24.h"
#include "motor.h"

#define BACK_MOTOR_DIRECTION 5

int motor_speed;
bool neutral = false;

int main(){
  stdio_init_all();
  sleep_ms(300);

  // init back motor direction pin
  gpio_init(BACK_MOTOR_DIRECTION);
  gpio_set_dir(BACK_MOTOR_DIRECTION, GPIO_OUT);
  
  motor_init();
  // printf("starting...\n");
  nrf24_init();
  nrf24_modeRX();
  char message[16];
  while(1){
    if(nrf24_newMessage()){
      nrf24_getMessage((uint8_t*)&message);

      switch(message[0]){
        case 'T': motor_speed = (message[3] - 0x30) * 10;
                  if (!neutral) set_motor_speed(motor_speed);
                  break;

        case 'D': switch(message[3]){
                  case 0x30: gpio_put(BACK_MOTOR_DIRECTION, 1);
                             printf("drive\n");
                             neutral = false;
                             break;
                              
                  case 0x32: gpio_put(BACK_MOTOR_DIRECTION, 0);
                             printf("reverse\n");
                             neutral = false;
                             break;
                             
                  case 0x31: neutral = true;
                             printf("neutral\n");
                             set_motor_speed(0);
                             break;
          }

        //  case 'D': if (message[3] == 't') gpio_put(BACK_MOTOR_DIRECTION, 1);
            //      else gpio_put(BACK_MOTOR_DIRECTION, 0);
              //    break;

        case 'S': switch(message[3]){
                    case 0x30: printf("max left\n"); break;
                    case 0x31: printf("left\n"); break;
                    case 0x32: printf("center\n"); break;
                    case 0x33: printf("right\n"); break;
                    case 0x34: printf("max right\n"); break;
          }

        case 'L': switch(message[1]){
                    case 0x31: printf("lights 1\n"); break;
                    case 0x32: printf("lights 2\n"); break;
          }
      }
        for(int i=0; i<16; i++) printf(" %02x ",message[i]);
        printf("\n");
      sleep_ms(20);
    }
  }
  return 0;
}
