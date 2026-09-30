// Pierce Clark
// pclark@hmc.edu
// 9/27/2026

#include "STM32L432KC_TIM.h"

void play_note(uint32_t freq, uint32_t duration){
    uint32_t n; // number of overflows

    if (freq == 0){
        TIM16->ARR  = 999; // 1 ms cycle time
        TIM16->CCR1 = 0;
        n = duration;
    } else {
        TIM16->ARR  = (1000000/freq) - 1;
        TIM16->CCR1 = (TIM16->ARR) >> 1; // 50% duty cycle
        n = freq * duration / 1000;
    }
    TIM16->EGR = 1; // Update counter
    TIM16->SR &= ~1;
    for (uint32_t i = 0; i < n; i++) {
        while (!(TIM16->SR & 1));    // wait for overflow
        TIM16->SR &= ~1;
    }

}
