////////// filename: main.c
#include <stdio.h>
#include "pico/stdlib.h"
#include "nrf24.h"

int main(){
  stdio_init_all();
  sleep_ms(1000);
  printf("starting...\n");
  nrf24_init();
  nrf24_modeRX();
  char message[7];
  while(1){
    if(nrf24_newMessage()){
      printf("getting new message\n");
      nrf24_getMessage((uint8_t*)&message);
      printf("data: %s\n",message);
      sleep_ms(300);
    }
  }
  return 0;
}
