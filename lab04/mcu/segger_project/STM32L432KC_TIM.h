// Pierce Clark
// pclark@hmc.edu
// 9/27/2026

#ifndef STM32L4_TIM_H
#define STM32L4_TIM_H

#include <stdint.h>

// Base addresses
#define TIM15_BASE (0x40014000UL)
#define TIM16_BASE (0x40014400UL)

// TIMx Register Structures
typedef struct {
    volatile uint32_t CR1;    // 0x00: control register 1
    volatile uint32_t CR2;    // 0x04: control register 2
    volatile uint32_t SMCR;   // 0x08: slave mode control register
    volatile uint32_t DIER;   // 0x0C: DMA/interrupt enable register
    volatile uint32_t SR;     // 0x10: status register
    volatile uint32_t EGR;    // 0x14: event generation register
    volatile uint32_t CCMR1;  // 0x18: capture/compare mode register 1
    volatile uint32_t reserved1; // 0x1C 
    volatile uint32_t CCER;   // 0x20: capture/compare enable 
    volatile uint32_t CNT;    // 0x24: counter
    volatile uint32_t PSC;    // 0x28: prescaler
    volatile uint32_t ARR;    // 0x2C: auto-reload register
    volatile uint32_t RCR;    // 0x30: repetition counter register
    volatile uint32_t CCR1;   // 0x34: capture/compare register 1 
    volatile uint32_t CCR2;   // 0x38: capture/compare register 2
    volatile uint32_t reserved2; // 0x3C
    volatile uint32_t reserved3; // 0x40
    volatile uint32_t BDTR;   // 0x44: break and dead-time register
    volatile uint32_t DCR;    // 0x48: DMA control register
    volatile uint32_t DMAR;   // 0x4C: address for full transfer
    volatile uint32_t OR1;    // 0x50: option register 1
    volatile uint32_t reserved4; // 0x54
    volatile uint32_t reserved5; // 0x58
    volatile uint32_t reserved6; // 0x5C
    volatile uint32_t OR2;    // 0x60: option register 2
} TIMx_TypeDef;


#define TIM15 ((TIMx_TypeDef *) TIM15_BASE)
#define TIM16 ((TIMx_TypeDef *) TIM16_BASE)

// Function Prototypes
void play_note(uint32_t freq, uint32_t duration); // plays PWM for a certain duration.

#endif