// ADC.c
// Runs on LM4F120/TM4C123
// Provide functions that initialize ADC0
// Student names: Siddhant Singh and Josh Kall
// Last modification date: 5/2/18

#include <stdint.h>
#include "C:\Keil\EE319KwareSpring2018\NOTGate_4C123/tm4c123gh6pm.h"

// ADC initialization function 
// Input: none
// Output: none
// measures from PD2, analog channel 5
void ADC_Init(void){ 
	SYSCTL_RCGCGPIO_R |= 0x28;
	volatile uint16_t nothing = 0;
	nothing++;
	nothing++;
	nothing++;
	nothing++;
	GPIO_PORTD_DIR_R &=~ 0x4;
	GPIO_PORTD_AFSEL_R &= 0x4;
	GPIO_PORTD_DEN_R &=~ 0x4;
	GPIO_PORTD_AMSEL_R &= 0x4;
	
	SYSCTL_RCGCADC_R |= 0x01; //mask with 0x01
	nothing++;
	nothing++;
	nothing++;
	nothing++;							// wait for clock to stabilize
	
	ADC0_PC_R |= 0x01;
	ADC0_SSPRI_R |= 0x0123;		//pay attention in lab lecture
	ADC0_ACTSS_R |= ~0x0008;
	ADC0_EMUX_R |= ~0xF000;
	ADC0_SSMUX3_R = (ADC0_SSMUX3_R & 0xFFFFFFF0) + 5;
	ADC0_SSCTL3_R |= 0x0006;
	ADC0_IM_R |= ~0x0008;
	ADC0_ACTSS_R |= 0x0008;

}

//------------ADC_In------------
// Busy-wait Analog to digital conversion
// Input: none
// Output: 12-bit result of ADC conversion
// measures from PD2, analog channel 5
uint32_t ADC_In(void){  
	uint32_t result;
	ADC0_PSSI_R = 0x0008;
	while ((ADC0_RIS_R & 0x08) == 0) {}
	result = ADC0_SSFIFO3_R & 0xFFF;
	ADC0_ISC_R = 0x0008;
  return result; // remove this, replace with real code
}


