#include "hardware/pwm.h"

#define SERVO_PIN       2

uint servo_slice_num;

void set_servo_angle(float angle){
  uint16_t level = (uint16_t)(500.0f + (angle * 11.11f));
  pwm_set_chan_level(servo_slice_num, PWM_CHAN_A, level);
}

void servo_init(){
  gpio_set_function(SERVO_PIN, GPIO_FUNC_PWM);
  servo_slice_num = pwm_gpio_to_slice_num(SERVO_PIN);
  pwm_set_clkdiv(servo_slice_num, 125.0f);
  pwm_set_wrap(servo_slice_num, 20000);
  pwm_set_enabled(servo_slice_num, true);
  set_servo_angle(100.0f);
}
