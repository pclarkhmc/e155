// button_interrupt.c
// Josh Brake
// jbrake@hmc.edu
// 10/31/22

#include "main.h"

int main(void) {

    // Enable PA6, PA12 as inputs
    gpioEnable(GPIO_PORT_A);
    pinMode(QUAD_ENCODER_A, GPIO_INPUT);
    pinMode(QUAD_ENCODER_B, GPIO_INPUT);

    GPIOA->PUPDR |= (0b01 << 2*gpioPinOffset(QUAD_ENCODER_A)); // Set PA6 as pull-up (PUPD5 = 01)
    GPIOA->PUPDR |= (0b01 << 2*gpioPinOffset(QUAD_ENCODER_B)); // Set PA12 as pull-up (PUPD6 = 01)

    // 1. Enable SYSCFG clock domain in RCC
    RCC->APB2ENR |= (1 << 0); // SYSCFGEN

    // 2. Configure EXTICR for the input button interrupt
    SYSCFG->EXTICR[1] &= ~(0b111 << 8); // SET EXTI6[2:0]  = PA[6] pin
    SYSCFG->EXTICR[3] &= ~(0b111 << 0); // SET EXTI12[2:0]  = PA[12] pin

    // Enable interrupts globally
    __enable_irq();

    // Configure interrupt for falling edge of GPIO pin for button
    EXTI->IMR1 |= (1 << gpioPinOffset(QUAD_ENCODER_A));   // 1. Configure mask bit
    EXTI->RTSR1 |= (1 << gpioPinOffset(QUAD_ENCODER_A)); // 2. Enable rising edge trigger
    EXTI->FTSR1 |= (1 << gpioPinOffset(QUAD_ENCODER_A));  // 3. Enable falling edge trigger
    
    EXTI->IMR1 |= (1 << gpioPinOffset(QUAD_ENCODER_B));   // 1. Configure mask bit
    EXTI->RTSR1 |= (1 << gpioPinOffset(QUAD_ENCODER_B)); // 2. Enable rising edge trigger
    EXTI->FTSR1 |= (1 << gpioPinOffset(QUAD_ENCODER_B));  // 3. Enable falling edge trigger

    NVIC->ISER[0] |= (1 << 23);                       // Turn on EXTI interrupt in NVIC_ISER (EXTI9_5 is IRQ 23)
    NVIC->ISER[1] = (1 << (EXTI15_10_IRQn - 32));     // Turn on EXTI Line[15:10] interrupts, IRQ 40

    while(1){
        // Calculate Speed
      
        // Calculate Direction
        // Get directions

        printf("RPM:");
    }

}

// EXTI lines 5-9 share this handler
void EXTI9_5_IRQHandler(void){
    // Check that the button was what triggered our interrupt
    if (EXTI->PR1 & (1 << gpioPinOffset(QUAD_ENCODER_A))){
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 = (1 << gpioPinOffset(QUAD_ENCODER_A));

        // DO SOMETHING
        // GET TIME

    }
}

void EXTI15_10_IRQHandler(void){
  if (EXTI->PR1 & (1 << gpioPinOffset(QUAD_ENCODER_A))){
        // If so, clear the interrupt (NB: Write 1 to reset.)
        EXTI->PR1 = (1 << gpioPinOffset(QUAD_ENCODER_A));

        // DO SOMETHING
        // GET TIME

    }
}