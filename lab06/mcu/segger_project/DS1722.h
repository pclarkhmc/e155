// DS1722.h
// Pierce Clark
// pclark@hmc.edu
// 10/8/2026
// Header for DS1722 functions

#ifndef DS1722_H
#define DS1722_H

#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_SPI.h"


///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void configureSensor(char config);

float readTemp(void);


#endif