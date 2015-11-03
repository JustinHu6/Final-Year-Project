// Multi-channel potentiostat with 5 channels to drive 80 electrodes in total (16 per channel)

#include "mbed.h"
//#include <string>

// LEDs
DigitalOut myled1(LED1);
DigitalOut myled2(LED2);
DigitalOut myled3(LED3);
DigitalOut myled4(LED4);

// DAC
AnalogOut dac(p18);

// ADCs
AnalogIn adc5(p15); // Channel 5
AnalogIn adc4(p16); // Channel 4
AnalogIn adc3(p17); // Channel 3
AnalogIn adc2(p19); // Channel 2
AnalogIn adc1(p20); // Channel 1

// Serial
Serial pc(USBTX, USBRX);

// SPI
SPI mux(p11,NC,p13);    // mosi, miso, sck (miso not used)

// Digital control signals
DigitalOut cs_ref(p9);  // SYNC signal (active low) for all octal switches connected to fixed reference
DigitalOut cs_amp(p10); // SYNC signal (active low) for all octal switches connected to amplifier
DigitalOut cs_ch1_fb1(p21); // Channel 1 feedback path select input IN2
DigitalOut cs_ch1_fb2(p22); // Channel 1 feedback path select input IN1
DigitalOut cs_ch2_fb1(p23); // Channel 2 feedback path select input IN2
DigitalOut cs_ch2_fb2(p24); // Channel 2 feedback path select input IN1
DigitalOut cs_ch3_fb1(p25); // Channel 3 feedback path select input IN2
DigitalOut cs_ch3_fb2(p26); // Channel 3 feedback path select input IN1
DigitalOut cs_ch4_fb1(p27); // Channel 4 feedback path select input IN2
DigitalOut cs_ch4_fb2(p28); // Channel 4 feedback path select input IN1
DigitalOut cs_ch5_fb1(p29); // Channel 5 feedback path select input IN2
DigitalOut cs_ch5_fb2(p30); // Channel 5 feedback path select input IN1

//  IN2     IN1     Path    Res     Max Current     Feedback #
//   0       0      None    16M     100nA               3
//   0       1      NO0     1.6M    1uA                 2
//   1       0      NO1     160k    10uA                1
//   1       1      NO2     16k     100uA               0

int main() {
    
    float dac_tmp;  // intermediate variable to store dac value sent from PC
    dac_tmp = 2;    // dummy value
    
    float adc1_tmp, adc2_tmp, adc3_tmp, adc4_tmp, adc5_tmp; // intermediate variables to store ADC values

    uint16_t elect_sel; // select electrode to connect to channel
    elect_sel = 1;  // select first electrode initially
    
    // arrays that store previous feedback selection #
    uint8_t prev_ch1 [16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    uint8_t prev_ch2 [16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    uint8_t prev_ch3 [16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    uint8_t prev_ch4 [16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    uint8_t prev_ch5 [16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    uint8_t elect_index;    // index for array
    elect_index = 0;    // select first electrode (array indexes start from 0)
    
    uint8_t mbed_ready, pc_ready;   // ready signals to synchronize data transfer
    mbed_ready = 1;
    pc_ready = 0;
    
    // set initial feedback path for each channel (see lines 42-46)
    uint8_t fb_ch1_sel, fb_ch2_sel, fb_ch3_sel, fb_ch4_sel, fb_ch5_sel; // feedback selection # (3 represents largest resistor and 0 the smallest)
    fb_ch1_sel = 0;
    cs_ch1_fb2 = 1; cs_ch1_fb1 = 1;
    fb_ch2_sel = 0;
    cs_ch2_fb2 = 1; cs_ch2_fb1 = 1;
    fb_ch3_sel = 0;
    cs_ch3_fb2 = 1; cs_ch3_fb1 = 1;
    fb_ch4_sel = 0;
    cs_ch4_fb2 = 1; cs_ch4_fb1 = 1;
    fb_ch5_sel = 0;
    cs_ch5_fb2 = 1; cs_ch5_fb1 = 1;
    
    // logic 0 enables shift register; logic 1 updates switch condition (and disables shift register)
    cs_ref = 1;
    cs_amp = 1;
    
    // configure SPI properties
    mux.format(16,1);   // 16-bit word for 2 daisy-chained octal switches
    mux.frequency(1000000);    // set SPI clock frequency
    
    // default states of octal switches
    cs_ref = 0;
    mux.write(0x0000);
    cs_ref = 1;
    
    cs_amp = 0;
    mux.write(0x0000);
    cs_amp = 1;
    
    dac = 0.5;
    
    while (1)
    {        
        myled1 = !myled1;
        
        // read DAC value from PC
        if (pc.readable())
        {
            myled2 = !myled2;
            pc.scanf("%f",&dac_tmp);    // read float value from MATLAB and store in an intermediate variable
            dac = dac_tmp;  // cannot directly use scanf and store in a pin variable
            //wait(1);
        }
        
        // if DAC value is set, start sending sampled data
        if (dac_tmp < 1)
        {
            // hybrid parallel-sequential make-before-break multiplexing
            cs_ref = 0;
            mux.write(0xFFFF);  // close all reference switches (in fact only one closes)
            cs_ref = 1;
            
            wait_ms(1);
            
            cs_amp = 0;
            mux.write(elect_sel);   // close the single switch to connect the selected electrode to the amplifier (and open the previous electrode's switch)
            cs_amp = 1;
            
            wait_ms(1);
            
            cs_ref = 0;
            mux.write(~elect_sel);  // open selected electrode's reference switch
            cs_ref = 1;

            if (pc.writeable())
            {
                pc.printf("%hhu\n",mbed_ready); // sends ready signal to pc
                
                while (pc_ready == 0)   // loop if pc is not ready to receive data
                {
                    if (pc.readable())
                    {
                        pc_ready = pc.getc();   // reads ready signal from pc
                        myled3 = !myled3;
                    }
                }
                
                pc_ready = 0;   // reset pc ready signal
                
                wait_ms(95);
                
                // ********** Channel 1 **********
                adc1_tmp = adc1.read(); // get ADC value with current feedback path
                
                // loop to update feedback path for best ADC output (this assumes that the current doesn't change drastically during the loop time)
                while ((adc1_tmp < 0.545 && adc1_tmp > 0.455) || (adc1_tmp > 0.95 || adc1_tmp < 0.05))
                {
                    if (adc1_tmp < 0.545 && adc1_tmp > 0.455) // voltage change about fixed reference (0.5) too small; needs amplification
                    {
                        if (fb_ch1_sel == 3)    // already using largest feedback path
                            break;  // break out of loop
                        fb_ch1_sel++;   // increment feedback selection # (amplify by 1 stage)
                    }
                    else if (adc1_tmp > 0.95 || adc1_tmp < 0.05)  // output saturates (leading to inaccurate estimation); needs attenuation
                    {
                        if (fb_ch1_sel == 0)    // already using smallest feedback path
                            break;  // break out of loop
                        fb_ch1_sel--;   // decrement feedback selection # (attenuate by 1 stage)
                    }
                    
                    switch (fb_ch1_sel) // update feedback path (see lines 42-46)
                    {
                        case 3:
                            cs_ch1_fb2 = 0; cs_ch1_fb1 = 0;
                            wait_ms(400);
                            break;
                        case 2:
                            cs_ch1_fb2 = 0; cs_ch1_fb1 = 1;
                            wait_ms(95);
                            break;
                        case 1:
                            cs_ch1_fb2 = 1; cs_ch1_fb1 = 0;
                            wait_ms(80);
                            break;
                        case 0:
                            cs_ch1_fb2 = 1; cs_ch1_fb1 = 1;
                            wait_ms(10);
                            break;
                    }
                    
                    adc1_tmp = adc1.read(); // get ADC value with new feedback path
                }
                
                prev_ch1[elect_index] = fb_ch1_sel; // store this electrode's feedback selection #
                pc.printf("%f\n",adc1_tmp); // send input as float value between 0.0 and 1.0
                pc.printf("%hhu\n",fb_ch1_sel); // send selected feedback path

                // ********** Channel 2 **********
                adc2_tmp = adc2.read(); // get ADC value with current feedback path
                
                // loop to update feedback path for best ADC output (this assumes that the current doesn't change drastically during the loop time)
                while ((adc2_tmp < 0.545 && adc2_tmp > 0.455) || (adc2_tmp > 0.95 || adc2_tmp < 0.05))
                {
                    if (adc2_tmp < 0.545 && adc2_tmp > 0.455) // voltage change about fixed reference (0.5) too small; needs amplification
                    {
                        if (fb_ch2_sel == 3)    // already using largest feedback path
                            break;  // break out of loop
                        fb_ch2_sel++;   // increment feedback selection # (amplify by 1 stage)
                    }
                    else if (adc2_tmp > 0.95 || adc2_tmp < 0.05)    // output saturates (leading to inaccurate estimation); needs attenuation
                    {
                        if (fb_ch2_sel == 0)    // already using smallest feedback path
                            break;  // break out of loop
                        fb_ch2_sel--;   // decrement feedback selection # (attenuate by 1 stage)
                    }
                    
                    switch (fb_ch2_sel) // update feedback path (see lines 42-46)
                    {
                        case 3:
                            cs_ch2_fb2 = 0; cs_ch2_fb1 = 0;
                            wait_ms(400);
                            break;
                        case 2:
                            cs_ch2_fb2 = 0; cs_ch2_fb1 = 1;
                            wait_ms(95);
                            break;
                        case 1:
                            cs_ch2_fb2 = 1; cs_ch2_fb1 = 0;
                            wait_ms(80);
                            break;
                        case 0:
                            cs_ch2_fb2 = 1; cs_ch2_fb1 = 1;
                            wait_ms(10);
                            break;
                    }
                    
                    adc2_tmp = adc2.read(); // get ADC value with new feedback path
                }
                
                prev_ch2[elect_index] = fb_ch2_sel; // store this electrode's feedback selection #
                pc.printf("%f\n",adc2_tmp); // send input as float value between 0.0 and 1.0
                pc.printf("%hhu\n",fb_ch2_sel); // send selected feedback path
                
                // ********** Channel 3 **********
                adc3_tmp = adc3.read(); // get ADC value with current feedback path
                
                // loop to update feedback path for best ADC output (this assumes that the current doesn't change drastically during the loop time)
                while ((adc3_tmp < 0.545 && adc3_tmp > 0.455) || (adc3_tmp > 0.95 || adc3_tmp < 0.05))
                {
                    if (adc3_tmp < 0.545 && adc3_tmp > 0.455) // voltage change about fixed reference (0.5) too small; needs amplification
                    {
                        if (fb_ch3_sel == 3)    // already using largest feedback path
                            break;  // break out of loop
                        fb_ch3_sel++;   // increment feedback selection # (amplify by 1 stage)
                    }
                    else if (adc3_tmp > 0.95 || adc3_tmp < 0.05)    // output saturates (leading to inaccurate estimation); needs attenuation
                    {
                        if (fb_ch3_sel == 0)    // already using smallest feedback path
                            break;  // break out of loop
                        fb_ch3_sel--;   // decrement feedback selection # (attenuate by 1 stage)
                    }
                    
                    switch (fb_ch3_sel) // update feedback path (see lines 42-46)
                    {
                        case 3:
                            cs_ch3_fb2 = 0; cs_ch3_fb1 = 0;
                            wait_ms(400);
                            break;
                        case 2:
                            cs_ch3_fb2 = 0; cs_ch3_fb1 = 1;
                            wait_ms(95);
                            break;
                        case 1:
                            cs_ch3_fb2 = 1; cs_ch3_fb1 = 0;
                            wait_ms(80);
                            break;
                        case 0:
                            cs_ch3_fb2 = 1; cs_ch3_fb1 = 1;
                            wait_ms(10);
                            break;
                    }
                    
                    adc3_tmp = adc3.read(); // get ADC value with new feedback path
                }
                
                prev_ch3[elect_index] = fb_ch3_sel; // store this electrode's feedback selection #
                pc.printf("%f\n",adc3_tmp); // send input as float value between 0.0 and 1.0
                pc.printf("%hhu\n",fb_ch3_sel); // send selected feedback path
                
                // ********** Channel 4 **********
                adc4_tmp = adc4.read(); // get ADC value with current feedback path
                
                // loop to update feedback path for best ADC output (this assumes that the current doesn't change drastically during the loop time)
                while ((adc4_tmp < 0.545 && adc4_tmp > 0.455) || (adc4_tmp > 0.95 || adc4_tmp < 0.05))
                {
                    if (adc4_tmp < 0.545 && adc4_tmp > 0.455) // voltage change about fixed reference (0.5) too small; needs amplification
                    {
                        if (fb_ch4_sel == 3)    // already using largest feedback path
                            break;  // break out of loop
                        fb_ch4_sel++;   // increment feedback selection # (amplify by 1 stage)
                    }
                    else if (adc4_tmp > 0.95 || adc4_tmp < 0.05)    // output saturates (leading to inaccurate estimation); needs attenuation
                    {
                        if (fb_ch4_sel == 0)    // already using smallest feedback path
                            break;  // break out of loop
                        fb_ch4_sel--;   // decrement feedback selection # (attenuate by 1 stage)
                    }
                    
                    switch (fb_ch4_sel) // update feedback path (see lines 42-46)
                    {
                        case 3:
                            cs_ch4_fb2 = 0; cs_ch4_fb1 = 0;
                            wait_ms(400);
                            break;
                        case 2:
                            cs_ch4_fb2 = 0; cs_ch4_fb1 = 1;
                            wait_ms(95);
                            break;
                        case 1:
                            cs_ch4_fb2 = 1; cs_ch4_fb1 = 0;
                            wait_ms(80);
                            break;
                        case 0:
                            cs_ch4_fb2 = 1; cs_ch4_fb1 = 1;
                            wait_ms(10);
                            break;;
                    }
                    
                    adc4_tmp = adc4.read(); // get ADC value with new feedback path
                }

                prev_ch4[elect_index] = fb_ch4_sel; // store this electrode's feedback selection #
                pc.printf("%f\n",adc4_tmp); // send input as float value between 0.0 and 1.0
                pc.printf("%hhu\n",fb_ch4_sel); // send selected feedback path
                
                // ********** Channel 5 **********
                adc5_tmp = adc5.read(); // get ADC value with current feedback path
                
                // loop to update feedback path for best ADC output (this assumes that the current doesn't change drastically during the loop time)
                while ((adc5_tmp < 0.545 && adc5_tmp > 0.455) || (adc5_tmp > 0.95 || adc5_tmp < 0.05))
                {
                    if (adc5_tmp < 0.545 && adc5_tmp > 0.455) // voltage change about fixed reference (0.5) too small; needs amplification
                    {
                        if (fb_ch5_sel == 3)    // already using largest feedback path
                            break;  // break out of loop
                        fb_ch5_sel++;   // increment feedback selection # (amplify by 1 stage)
                    }
                    else if (adc5_tmp > 0.95 || adc5_tmp < 0.05)    // output saturates (leading to inaccurate estimation); needs attenuation
                    {
                        if (fb_ch5_sel == 0)    // already using smallest feedback path
                            break;  // break out of loop
                        fb_ch5_sel--;   // decrement feedback selection # (attenuate by 1 stage)
                    }
                    
                    switch (fb_ch5_sel) // update feedback path (see lines 42-46)
                    {
                        case 3:
                            cs_ch5_fb2 = 0; cs_ch5_fb1 = 0;
                            wait_ms(400);
                            break;
                        case 2:
                            cs_ch5_fb2 = 0; cs_ch5_fb1 = 1;
                            wait_ms(95);
                            break;
                        case 1:
                            cs_ch5_fb2 = 1; cs_ch5_fb1 = 0;
                            wait_ms(80);
                            break;
                        case 0:
                            cs_ch5_fb2 = 1; cs_ch5_fb1 = 1;
                            wait_ms(10);
                            break;
                    }
                    
                    adc5_tmp = adc5.read(); // get ADC value with new feedback path
                }
                
                prev_ch5[elect_index] = fb_ch5_sel; // store this electrode's feedback selection #
                pc.printf("%f\n",adc5_tmp); // send input as float value between 0.0 and 1.0
                pc.printf("%hhu\n",fb_ch5_sel); // send selected feedback path
                
                myled4 = !myled4;
                //wait(0.2);    // set delay to increase sampling period (and reduce overall number of samples)
            }
            
            elect_sel = elect_sel*2;    // update electrode selection
            elect_index++;  // update array index
            if (elect_sel == 0)
            {
                elect_sel = 1;  // reset to 1 after 16-bit overflow
                elect_index = 0;    // reset array index
            }
            
            // feedback estimation (to prevent op-amp saturation)
            if ((fb_ch1_sel > prev_ch1[elect_index]) || (fb_ch1_sel == prev_ch1[elect_index]))
            {
                switch (prev_ch1[elect_index])  // change to previous feedback selection # - 1 (in case current rose to higher stage)
                {
                    case 3:
                        fb_ch1_sel = 2;
                        cs_ch1_fb2 = 0; cs_ch1_fb1 = 1;
                        break;
                    case 2:
                        fb_ch1_sel = 1;
                        cs_ch1_fb2 = 1; cs_ch1_fb1 = 0;
                        break;
                    case 1:
                        fb_ch1_sel = 0;
                        cs_ch1_fb2 = 1; cs_ch1_fb1 = 1;
                        break;
                    case 0:
                        fb_ch1_sel = 0;
                        cs_ch1_fb2 = 1; cs_ch1_fb1 = 1;
                        break;
                }
            }
            
            if ((fb_ch2_sel > prev_ch2[elect_index]) || (fb_ch2_sel == prev_ch2[elect_index]))
            {
                switch (prev_ch2[elect_index])  // change to previous feedback selection # - 1 (in case current rose to higher stage)
                {
                    case 3:
                        fb_ch2_sel = 2;
                        cs_ch2_fb2 = 0; cs_ch2_fb1 = 1;
                        break;
                    case 2:
                        fb_ch2_sel = 1;
                        cs_ch2_fb2 = 1; cs_ch2_fb1 = 0;
                        break;
                    case 1:
                        fb_ch2_sel = 0;
                        cs_ch2_fb2 = 1; cs_ch2_fb1 = 1;
                        break;
                    case 0:
                        fb_ch2_sel = 0;
                        cs_ch2_fb2 = 1; cs_ch2_fb1 = 1;
                        break;
                }
            }
            
            if ((fb_ch3_sel > prev_ch3[elect_index]) || (fb_ch3_sel == prev_ch3[elect_index]))
            {
                switch (prev_ch3[elect_index])  // change to previous feedback selection # - 1 (in case current rose to higher stage)
                {
                    case 3:
                        fb_ch3_sel = 2;
                        cs_ch3_fb2 = 0; cs_ch3_fb1 = 1;
                        break;
                    case 2:
                        fb_ch3_sel = 1;
                        cs_ch3_fb2 = 1; cs_ch3_fb1 = 0;
                        break;
                    case 1:
                        fb_ch3_sel = 0;
                        cs_ch3_fb2 = 1; cs_ch3_fb1 = 1;
                        break;
                    case 0:
                        fb_ch3_sel = 0;
                        cs_ch3_fb2 = 1; cs_ch3_fb1 = 1;
                        break;
                }
            }
            
            if ((fb_ch4_sel > prev_ch4[elect_index]) || (fb_ch4_sel == prev_ch4[elect_index]))
            {
                switch (prev_ch4[elect_index])  // change to previous feedback selection # - 1 (in case current rose to higher stage)
                {
                    case 3:
                        fb_ch4_sel = 2;
                        cs_ch4_fb2 = 0; cs_ch4_fb1 = 1;
                        break;
                    case 2:
                        fb_ch4_sel = 1;
                        cs_ch4_fb2 = 1; cs_ch4_fb1 = 0;
                        break;
                    case 1:
                        fb_ch4_sel = 0;
                        cs_ch4_fb2 = 1; cs_ch4_fb1 = 1;
                        break;
                    case 0:
                        fb_ch4_sel = 0;
                        cs_ch4_fb2 = 1; cs_ch4_fb1 = 1;
                        break;
                }
            }
            
            if ((fb_ch5_sel > prev_ch5[elect_index]) || (fb_ch5_sel == prev_ch5[elect_index]))
            {
                switch (prev_ch5[elect_index])  // change to previous feedback selection # - 1 (in case current rose to higher stage)
                {
                    case 3:
                        fb_ch5_sel = 2;
                        cs_ch5_fb2 = 0; cs_ch5_fb1 = 1;
                        break;
                    case 2:
                        fb_ch5_sel = 1;
                        cs_ch5_fb2 = 1; cs_ch5_fb1 = 0;
                        break;
                    case 1:
                        fb_ch5_sel = 0;
                        cs_ch5_fb2 = 1; cs_ch5_fb1 = 1;
                        break;
                    case 0:
                        fb_ch5_sel = 0;
                        cs_ch5_fb2 = 1; cs_ch5_fb1 = 1;
                        break;
                }
            }
        }
    }
}