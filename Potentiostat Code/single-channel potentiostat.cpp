// Single-channel potentiostat to drive 8 electrodes

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
AnalogIn adc1(p15);
AnalogIn adc2(p16);
AnalogIn adc3(p17);
AnalogIn adc4(p19);
AnalogIn adc5(p20); // All ADCs are connected together

// Serial
Serial pc(USBTX, USBRX);

// SPI
SPI mux(p11,NC,p13);   // mosi, miso, sck (miso not used)

// Digital control signals
DigitalOut cs_amp(p21); // SYNC signal (active low) for amplifier octal switch
DigitalOut cs_ref(p22); // SYNC signal (active low) for fixed reference octal switch
DigitalOut cs_fb1(p24); // Feedback path select input IN1
DigitalOut cs_fb2(p23); // Feedback path select input IN2

//  IN2     IN1     Path    Res     Max Current     Feedback #
//   0       0      None    16M     100nA               3
//   0       1      NO0     1.6M    1uA                 2
//   1       0      NO1     160k    10uA                1
//   1       1      NO2     16k     100uA               0

int main() {
    
    float dac_tmp;  // intermediate variable to store dac value sent from PC
    dac_tmp = 2;    // dummy value
    
    float adc1_tmp; // intermediate variable to store ADC value
    
    uint8_t elect_sel;  // select electrode to connect to channel
    elect_sel = 1;  // select first electrode initially
    
    uint8_t mbed_ready, pc_ready;   // ready signals to synchronize data transfer
    mbed_ready = 1;
    pc_ready = 0;
    
    // set initial feedback path (see lines 34-38)
    uint8_t fb_sel; // feedback selection number (3 represents largest resistor and 0 the smallest)
    fb_sel = 2;
    cs_fb2 = 0; cs_fb1 = 1;
    
    // logic 0 enables shift register; logic 1 updates switch condition (and disables shift register)
    cs_amp = 1;
    cs_ref = 1;
    
    // configure SPI properties
    mux.format(8,1);
    mux.frequency(1000000);
    
    // default octal switches states
    cs_ref = 0;
    mux.write(0x00);
    cs_ref = 1;
    
    cs_amp = 0;
    mux.write(0x00);
    cs_amp = 1;
    
    //dac = 0.5;
    
    while (1)
    {        
        myled1 = !myled1;
        
        // read DAC value from PC
        if (pc.readable())
        {
            myled2 = !myled2;
            pc.scanf("%f",&dac_tmp); // read float value from MATLAB and store in an intermediate variable
            dac = dac_tmp;  // cannot directly use scanf and store in a pin variable
            //wait(1);
        }
        
        // if DAC value is set, start sending sampled data
        if (dac_tmp < 1)
        {
            // make-before-break sequential multiplexing
            cs_ref = 0;
            mux.write(0xFF);    // close all ground switches (in fact only closes one)
            cs_ref = 1;
            
            cs_amp = 0;
            mux.write(elect_sel);   // close the single switch to connect the selected electrode to the amplifier
            cs_amp = 1;
            
            cs_ref = 0;
            mux.write(~elect_sel);  // open selected electrode ground switch
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
                
                adc1_tmp = adc1.read(); // get ADC value with current feedback path
                
                // loop to update feedback path for best ADC output (this assumes that the current doesn't change drastically during the loop time)
                while ((adc1_tmp < 0.55 && adc1_tmp > 0.45) || (adc1_tmp > 0.99 || adc1_tmp < 0.01))
                {
                    if (adc1_tmp < 0.55 && adc1_tmp > 0.45) // voltage change about fixed reference (0.5) too small; needs amplification
                    {
                        if (fb_sel == 3)    // already using largest feedback path
                            break;          // break out of loop
                        fb_sel++;           // increment feedback selection number (amplify by 1 stage)
                    }
                    else if (adc1_tmp > 0.99 || adc1_tmp < 0.01)  // output saturates (leading to inaccurate estimation); needs attenuation
                    {
                        if (fb_sel == 0)    // already using smallest feedback path
                            break;          // break out of loop
                        fb_sel--;           // decrement feedback selection number (attenuate by 1 stage)
                    }
                    
                    switch (fb_sel) // update feedback path (see lines 32-36)
                    {
                        case 0:
                            cs_fb2 = 1; cs_fb1 = 1;
                            break;
                        case 1:
                            cs_fb2 = 1; cs_fb1 = 0;
                            break;
                        case 2:
                            cs_fb2 = 0; cs_fb1 = 1;
                            break;
                        case 3:
                            cs_fb2 = 0; cs_fb1 = 0;
                            break;
                    }
                    
                    wait_ms(100);  // need to wait because the feedback path cannot change quick enough before the ADC value is read again
                    adc1_tmp = adc1.read(); // get ADC value with new feedback path
                }
                
                //wait(1);    // set delay to increase sampling period (and reduce overall number of samples)
                
                pc.printf("%f\n",adc1_tmp); // send input as float value between 0.0 and 1.0
                pc.printf("%hhu\n",fb_sel); // send selected feedback path
                
                myled4 = !myled4;
                //wait(0.1);
            }
            
            elect_sel = elect_sel*2;    // update electrode selection
            if (elect_sel == 0) // reset to 1 after 8-bit overflow
                elect_sel = 1;
        }
    }
    
}