#include "pico/stdlib.h"
#include "hardware/pwm.h"

#define PWM1 3
#define DIR1 2
int main(){
  gpio_init(DIR1);
  gpio_set_dir(DIR1,GPIO_OUT);
  gpio_put(DIR1,0);

  gpio_set_function(PWM1,GPIO_FUNC_PWM);
  pwm_set_wrap(1,5000);
  pwm_set_clkdiv(1,25.0f);
  pwm_set_chan_level(1,PWM_CHAN_B,500);
  pwm_set_enabled(1,true);
  
}
