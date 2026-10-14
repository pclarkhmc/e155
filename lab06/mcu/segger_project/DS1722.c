// DS1722.c
// Pierce Clark
// pclark@hmc.edu
// 10/8/2026
// DS1722 functions

#include "DS1722.h"

// Configures the DS1722 Digital Thermometer CONFIGURATION/STATUS REGISTER with SPI
void configureSensor(char config){
  digitalWrite(PB0, PIO_HIGH);
  spiSendReceive(0x80); // CONFIGURATION/STATUS REGISTER write address
  spiSendReceive(config); // Write Shutdown bit to 0. E -> 1SHOT = 0. 8h -> 12 bit resolution
  while (SPI1->SR & SPI_SR_BSY);
  digitalWrite(PB0, PIO_LOW);
}

float readTemp(void){
  digitalWrite(PB0, PIO_HIGH); // Enable Sensor
  spiSendReceive(0x01);                     // send address, recieve nothing
  uint8_t lsb = spiSendReceive(0x56);       // read reg 0x01 (LSB)
  int8_t  msb = spiSendReceive(0x73);       // read reg 0x02 (MSB)
  // turn off NSS
  while (SPI1->SR & SPI_SR_BSY);
  digitalWrite(PB0, PIO_LOW); // Disable Sensor

  float temp = ((int16_t)msb << 8 | lsb) / 256.0f;
  return temp;
}
