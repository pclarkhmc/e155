// STM32L432KC_RCC.c
// Source code for RCC functions
// Modified from 155 Clock tutorial

#include "STM32L432KC_RCC.h"

void configurePLL(void) {
    // Set clock to 80 MHz
    // Output freq = (src_clk) * (N/M) / R
    // (4 MHz) * (N/M) / R = 80 MHz
    // M: 1, N: 80, R: 4
    // Use MSI as PLLSRC

    // TODO: Turn off PLL
    RCC->CR &= ~(1 << 24); // Set PPLON = 0

    // TODO: Wait till PLL is unlocked (e.g., off)
    while ((RCC->CR >> 25 & 1) != 0);

    // Load configuration
    // TODO: Set PLL SRC to MSI (4MHz on reset)
    RCC->PLLCFGR &= ~0b11;
    RCC->PLLCFGR |= 0b01; // set first bit
    RCC->PLLCFGR &= ~(0b1 << 1); // clear second bit

    // TODO: Set PLLN to 80
    RCC->PLLCFGR &= ~(0b1111111 << 8); // Clear all bits of PLLN
    RCC->PLLCFGR |= (0b1010000 << 8); // Set N = 80

    // TODO: Set PLLM to 000: PLLM = 1
    RCC->PLLCFGR &= ~(0b111 << 4);  // Clear all bits 

    // TODO: Set PLLR to 01: PLLR = 4
    RCC->PLLCFGR &= ~(1 << 26);
    RCC->PLLCFGR |= (1 << 25);

    // TODO: Enable PLLR output
    RCC->PLLCFGR |= (1 << 24);
    
    // TODO: Enable PLL
    RCC->CR |= (1 << 24);
    
    // TODO: Wait until PLL is locked
    while ((RCC->CR >> 25 & 1) != 1);
    
}

void configureClock(){
    // Configure and turn on PLL
    configurePLL();

    // Select PLL as clock source
    RCC->CFGR |= (0b11 << 0);
    while(!((RCC->CFGR >> 2) & 0b11));
}