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
}
