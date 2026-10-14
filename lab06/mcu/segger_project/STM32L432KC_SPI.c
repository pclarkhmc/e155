// STM32L432KC_SPI.c
// Pierce Clark
// pclark@hmc.edu
// 10/8/2026
// SPI functions

#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"
#include <stm32l432xx.h>

/* Enables the SPI peripheral and intializes its clock speed (baud rate), polarity, and phase.
 *    -- br: (0b000 - 0b111). The SPI clk will be the master clock / 2^(BR+1).
 *    -- cpol: clock polarity (0: inactive state is logical 0, 1: inactive state is logical 1).
 *    -- cpha: clock phase (0: data captured on leading edge of clk and changed on next edge, 
 *          1: data changed on leading edge of clk and captured on next edge)
 * Refer to the datasheet for more low-level details. */ 
void initSPI(int br, int cpol, int cpha){
  // Turn on SPI Clock
  RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;
  // Disable SPI
  SPI1->CR1 &= ~SPI_CR1_SPE_Msk;

  //  1. Write proper GPIO registers: Configure GPIO for MOSI, MISO and SCK pins.
  // Set alt functions to 5

  //NSS - Chip Enable
  pinMode(PB0, GPIO_OUTPUT);
  digitalWrite(PB0, PIO_LOW);
  //SCK
  GPIOA->AFR[0] &= ~GPIO_AFRL_AFSEL5_Msk;
  GPIOA->AFR[0] |= (0b0101 << GPIO_AFRL_AFSEL5_Pos);
  pinMode(PA5, GPIO_ALT);
  //MISO
  GPIOA->AFR[0] &= ~GPIO_AFRL_AFSEL6_Msk;
  GPIOA->AFR[0] |= (0b0101 << GPIO_AFRL_AFSEL6_Pos);
  pinMode(PA6, GPIO_ALT);
  //MOSI
  GPIOB->AFR[0] &= ~GPIO_AFRL_AFSEL5_Msk;
  GPIOB->AFR[0] |= (0b0101 << GPIO_AFRL_AFSEL5_Pos);
  pinMode(PB5, GPIO_ALT);

  //2. Write to the SPI_CR1 register:
  //a) Configure the serial clock baud rate using the BR[2:0] bits (Note: 4).
  SPI1->CR1 &= ~SPI_CR1_BR_Msk;
  SPI1->CR1 |= (br << SPI_CR1_BR_Pos);
  
  //b) Configure the CPOL and CPHA bits combination to define one of the four
  //relationships between the data transfer and the serial clock (CPHA must be
  //cleared in NSSP mode). (Note: 2 - except the case when CRC is enabled at TI
  //mode).
  SPI1->CR1 &= ~(SPI_CR1_CPOL_Msk | SPI_CR1_CPHA_Msk); // clear bits
  SPI1->CR1 |= (cpol << SPI_CR1_CPOL_Pos);
  SPI1->CR1 |= (cpha << SPI_CR1_CPHA_Pos);


  //c) Select simplex or half-duplex mode by configuring RXONLY or BIDIMODE and
  //BIDIOE (RXONLY and BIDIMODE can't be set at the same time).
  // Default in Full Duplex mode
  SPI1->CR1 &= ~(SPI_CR1_BIDIMODE | SPI_CR1_RXONLY); // both 0, full duplex

  //d) Configure the LSBFIRST bit to define the frame format (Note: 2).
  SPI1->CR1 &= ~SPI_CR1_LSBFIRST_Msk; // 0: data is transmitted / received with the MSB first

  //e) Configure the CRCL and CRCEN bits if CRC is needed (while SCK clock signal is
  //at idle state).
  SPI1->CR1 &= ~SPI_CR1_CRCEN_Msk; // disable CRC

  //f) Configure SSM and SSI (Notes: 2 & 3).
  SPI1->CR1 |= SPI_CR1_SSM_Msk; // 1: Software slave management enabled
  SPI1->CR1 |= SPI_CR1_SSI_Msk; // SS = 1

  //g) Configure the MSTR bit (in multimaster NSS configuration, avoid conflict state on
  //NSS if master is configured to prevent MODF error).
  SPI1->CR1 |= SPI_CR1_MSTR_Msk; // 1: Master configuration

  //3. Write to SPI_CR2 register:
  //a) Configure the DS[3:0] bits to select the data length for the transfer.
  SPI1->CR2 &= ~SPI_CR2_DS_Msk;
  SPI1->CR2 |= (0b0111 << SPI_CR2_DS_Pos); // 0111: 8-bit

  //b) Configure SSOE (Notes: 1 & 2 & 3).
  SPI1->CR2 &= ~SPI_CR2_SSOE_Msk;

  //c) Set the FRF bit if the TI protocol is required (keep NSSP bit cleared in TI mode).
  SPI1->CR2 &= ~SPI_CR2_FRF_Msk; 

  //d) Set the NSSP bit if the NSS pulse mode between two data units is required (keep
  //CHPA and TI bits cleared in NSSP mode).
  SPI1->CR2 &= ~SPI_CR2_NSSP_Msk;

  //e) Configure the FRXTH bit. The RXFIFO threshold must be aligned to the read
  //access size for the SPIx_DR register.
  SPI1->CR2 |= SPI_CR2_FRXTH_Msk; // 1: RXNE event is generated if the FIFO level is greater than or equal to 1/4 (8-bit)

  //f) Initialize LDMA_TX and LDMA_RX bits if DMA is used in packed mode.
  SPI1->CR2 &= ~SPI_CR2_LDMATX_Msk;
  SPI1->CR2 &= ~SPI_CR2_LDMARX_Msk;

  //4. Write to SPI_CRCPR register: Configure the CRC polynomial if needed.
  // Keep at reset value

  //5. Write proper DMA registers: Configure DMA streams dedicated for SPI Tx and Rx in
  //DMA registers if the DMA streams are used.
  // keep at reset value

  // ENABLE SPI
  SPI1->CR1 |= SPI_CR1_SPE_Msk;
}

/* Transmits a byte over SPI and recieves 1 byte
 *    -- send: the character to send over SPI
 *    -- return: the character received over SPI */
char spiSendReceive(char send){
  // Send Data
  while(!(SPI1->SR & SPI_SR_TXE));           // wait for room in transmit buffer
  *(volatile char *)(&SPI1->DR) = send;      // 8-bit write

  // Read Data
  while(!(SPI1->SR & SPI_SR_RXNE));          // wait while recieve buffer is empty
  return *(volatile char *)(&SPI1->DR);      // read byte
}

 
  
  
  