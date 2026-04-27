#include "hardware/pwm.h"

#define MOTOR_PIN       6
#define SPEED_RATE 130 // adjust for speed

uint motor_slice_num;

void motor_init(){
  
   gpio_set_function(MOTOR_PIN, GPIO_FUNC_PWM);
   motor_slice_num = pwm_gpio_to_slice_num(MOTOR_PIN);
   pwm_set_clkdiv(motor_slice_num, 6.25f);
   pwm_set_wrap(motor_slice_num, 19999);
   pwm_set_enabled(motor_slice_num, true);
   pwm_set_chan_level(motor_slice_num, PWM_CHAN_A, 0);
   // pwm_config cfg = pwm_get_default_config();
   // pwm_config_set_clkdiv(&cfg, 6.25f); // set for 1khz
   // pwm_config_set_wrap(&cfg, 19999); // full power level 19999
   // pwm_init(MOTOR_SLICE_NUM, &cfg, true);
   // pwm_set_chan_level(MOTOR_SLICE_NUM, PWM_CHAN_A, 0); // start with 0 duty cycle
}

// set speed max of 75% of 19999 about 15000
void set_motor_speed(int s){
  pwm_set_chan_level(motor_slice_num, PWM_CHAN_A, s * SPEED_RATE);
}
