/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Play Great Music

*/

//#include <stdint.h>
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_TIM.h"


int main(void) {
    // Enable clocks
    RCC->AHB2ENR |= (1 << 0);   // GPIOA ON
    RCC->APB2ENR |= (1 << 17);  // TIM16 ON

    // Set pin 16 to alternate function 14 (TIM16_CH1)
    GPIOA->MODER &= ~(0b11 << 12);  // clear MODE6
    GPIOA->MODER |=  (0b10 << 12);  // MODE6 = 10 (alternate function)

    // Set alternate function to 14
    GPIOA->AFRL  &= ~(0b1111 << 24);   // clear AFSEL6
    GPIOA->AFRL  |=  (14 << 24);    // AFSEL6 = 14

    // Set timer clock to 1M (MSI(4MHz) / (PSC(3) + 1) = 1 MHz
    TIM16->PSC  = 3;
    TIM16->ARR  = 999;   // initial frequency
    TIM16->CCR1 = 0;     // inital duty cycle

    TIM16->EGR = (1U << 0);      // UG: load PSC/ARR/CCR1 into shadow registers
    TIM16->SR &= ~(1U << 0);     // UG sets UIF, so clear it

    TIM16->CR1 |= (1U << 0);     // Enable the counter
    
    while (1) {	
        for (int i = 0; i < sizeof(notes)/2; i++) {
          play
        }
    }

}
/*************************** End of file ****************************/