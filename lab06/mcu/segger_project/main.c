/*
File: Lab_6_JHB.c
Author: Josh Brake
Email: jbrake@hmc.edu
Date: 9/14/19
*/


#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "main.h"

/////////////////////////////////////////////////////////////////
// Provided Constants and Functions
/////////////////////////////////////////////////////////////////

//Defining the web page in two chunks: everything before the current time, and everything after the current time
char* webpageStart = "<!DOCTYPE html><html><head><title>E155 Lab 6 Webpage</title>\
	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\
	</head>\
	<body><h1>E155 Lab 6 Webpage</h1>";
char* ledStr = "<p>LED Control:</p><form action=\"ledon\"><input type=\"submit\" value=\"Turn the LED on!\"></form>\
	<form action=\"ledoff\"><input type=\"submit\" value=\"Turn the LED off!\"></form>";
char* webpageEnd   = "</body></html>";

char* resStr = "<p>Temperature Resolution:</p>\
        <form action=\"res08\"><input type=\"submit\" value=\"8-bit\"></form>\
        <form action=\"res09\"><input type=\"submit\" value=\"9-bit\"></form>\
        <form action=\"res10\"><input type=\"submit\" value=\"10-bit\"></form>\
        <form action=\"res11\"><input type=\"submit\" value=\"11-bit\"></form>\
        <form action=\"res12\"><input type=\"submit\" value=\"12-bit\"></form>";

//determines whether a given character sequence is in a char array request, returning 1 if present, -1 if not present
int inString(char request[], char des[]) {
	if (strstr(request, des) != NULL) {return 1;}
	return -1;
}

int updateLEDStatus(char request[])
{
	int led_status = 0;
	// The request has been received. now process to determine whether to turn the LED on or off
	if (inString(request, "ledoff")==1) {
		digitalWrite(LED_PIN, PIO_LOW);
		led_status = 0;
	}
	else if (inString(request, "ledon")==1) {
		digitalWrite(LED_PIN, PIO_HIGH);
		led_status = 1;
	}

	return led_status;
}

int updateResStatus(char request[]) {
        int res_status = 12;
        if (inString(request, "res08") == 1) {
                configureSensor(0xE0);
                res_status = 8;
        }
        else if (inString(request, "res09") == 1) {
                configureSensor(0xE2);
                res_status = 9;
        }
        else if (inString(request, "res10") == 1) {
                configureSensor(0xE4);
                res_status = 10;
        }
        else if (inString(request, "res11") == 1) {
                configureSensor(0xE6);
                res_status = 11;
        }
        else if (inString(request, "res12") == 1) {
                configureSensor(0xE8);
                res_status = 12;
        }
        return res_status;
}

/////////////////////////////////////////////////////////////////
// Solution Functions
/////////////////////////////////////////////////////////////////

int main(void) {
  configureFlash();
  configureClock();

  gpioEnable(GPIO_PORT_A);
  gpioEnable(GPIO_PORT_B);
  gpioEnable(GPIO_PORT_C);

  pinMode(PB3, GPIO_OUTPUT);
  
  RCC->APB2ENR |= (RCC_APB2ENR_TIM15EN);
  initTIM(TIM15);
  
  USART_TypeDef * USART = initUSART(USART1_ID, 125000);

  // Add SPI initialization code
  int br = 0b111; // baud rate = 7
  initSPI(br, 0, 1); // cpol = 0, cpha = 1

  // Configure Sensor
  configureSensor(0xE8);

  while(1) {
    /* Wait for ESP8266 to send a request.
    Requests take the form of '/REQ:<tag>\n', with TAG begin <= 10 characters.
    Therefore the request[] array must be able to contain 18 characters.
    */

    // Receive web request from the ESP
    char request[BUFF_LEN] = "                  "; // initialize to known value
    int charIndex = 0;
  
    // Keep going until you get end of line character
    while(inString(request, "\n") == -1) {
      // Wait for a complete request to be transmitted before processing
      while(!(USART->ISR & USART_ISR_RXNE));
      request[charIndex++] = readChar(USART);
    }

    // SPI code for reading temperature
    int resolution = updateResStatus(request);
    float temp = readTemp();
    
    char tempStr[50];
    char resStatusStr[20];

    sprintf(resStatusStr, "%d", resolution);

    if (resolution == 8)
        sprintf(tempStr, "Current temperature: %.0f &deg;C", temp);
    else if (resolution == 9)
        sprintf(tempStr, "Current temperature: %.1f &deg;C", temp);
    else if (resolution == 10)
        sprintf(tempStr, "Current temperature: %.2f &deg;C", temp);
    else if (resolution == 11)
        sprintf(tempStr, "Current temperature: %.3f &deg;C", temp);
    else if (resolution == 12)
        sprintf(tempStr, "Current temperature: %.4f &deg;C", temp);
    else
        sprintf(tempStr, "Current temperature: %.1f &deg;C", temp);  // default


    // Update string with current LED state  
    int led_status = updateLEDStatus(request);

    char ledStatusStr[20];
    if (led_status == 1)
      sprintf(ledStatusStr,"LED is on!");
    else if (led_status == 0)
      sprintf(ledStatusStr,"LED is off!");

    
    // finally, transmit the webpage over UART
    sendString(USART, webpageStart); // webpage header code

    sendString(USART, ledStr); // button for controlling LED
    sendString(USART, "<h2>LED Status</h2>");
    sendString(USART, "<p>");
    sendString(USART, ledStatusStr);
    sendString(USART, "</p>");
    
    sendString(USART, resStr);              // resolution buttons
    sendString(USART, "<h2>Resolution Status</h2>");
    sendString(USART, "<p>");
    sendString(USART, resStatusStr);        
    sendString(USART, "</p>");
    sendString(USART, "<p>");
    sendString(USART, tempStr);             // temperature
    sendString(USART, "</p>");

  
    sendString(USART, webpageEnd);
  }
}


