// main.h
// Josh Brake
// jbrake@hmc.edu
// 10/31/22

#ifndef MAIN_H
#define MAIN_H

#include "STM32L432KC.h"
#include <stm32l432xx.h>

///////////////////////////////////////////////////////////////////////////////
// Custom defines
///////////////////////////////////////////////////////////////////////////////

#define LED_PIN PB3
#define DELAY_TIM TIM2


#define QUAD_ENCODER_A PA6 // Quad Encoder A
#define QUAD_ENCODER_B PA12 // Quad Encoder B

#endif // MAIN_H