// put implementations for functions, explain how it works
// Student names: Sid Singh & Josh Kall
// Last modification date: 5/2/18

#include <stdint.h>
#include "tm4c123gh6pm.h"

void DAC_Init(void){
	uint8_t delay;
	SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOB; // activate port B
  delay = SYSCTL_RCGC2_R;    // allow time to finish activating
  GPIO_PORTB_AMSEL_R &= ~0x07;      // no analog
  GPIO_PORTB_PCTL_R &= ~0x00000FFF; // regular GPIO function
  GPIO_PORTB_DIR_R |= 0x0F;      // make PB3-0 out 	
  GPIO_PORTB_AFSEL_R &= ~0x0F;   // disable alt funct on PB3-0
  GPIO_PORTB_DEN_R |= 0x0F;      // enable digital I/O on PB3-0
}

void DAC_Out(uint32_t data){
	GPIO_PORTB_DATA_R = data;	//write a voltage to the DAC
}
