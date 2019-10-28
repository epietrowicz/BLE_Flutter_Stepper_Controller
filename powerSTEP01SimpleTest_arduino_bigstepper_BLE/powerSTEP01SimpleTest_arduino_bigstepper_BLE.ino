// Program demonstrating how to control a powerSTEP01-based ST X-NUCLEO-IHM03A1 
// stepper motor driver shield on an Arduino Uno-compatible board

#include <powerSTEP01ArduinoLibrary.h>
#include <SPI.h>

// Pin definitions for the X-NUCLEO-IHM03A1 connected to an Uno-compatible board
#define nCS_PIN 10
#define STCK_PIN 9
#define nSTBY_nRESET_PIN 8
#define nBUSY_PIN 4

#define MAX_VAL 600
#define MIN_VAL 0
#define FWD_PIN A0
#define REV_PIN A1
#define SLOW_PIN A2
#define FAST_PIN A3
#define FSTEP_PIN A4
#define RSTEP_PIN A5

String incoming = "";
String cmd = "";
int val = 0;

// powerSTEP library instance, parameters are distance from the end of a daisy-chain
// of drivers, !CS pin, !STBY/!Reset pin
powerSTEP driver(0, nCS_PIN, nSTBY_nRESET_PIN);

int fwd_cmd = 0;
int rev_cmd = 0;
int slow_cmd = 0;
int fast_cmd = 0;
int fstep_cmd = 0;
int rstep_cmd = 0;
int value = 200;
bool fwd = true;

void setup() 
{
  // Start serial
  Serial.begin(9600);
  Serial.println("powerSTEP01 Arduino control initialising...");

  // Prepare pins
  pinMode(nSTBY_nRESET_PIN, OUTPUT);
  pinMode(nCS_PIN, OUTPUT);
  pinMode(MOSI, OUTPUT);
  pinMode(MISO, OUTPUT);
  pinMode(SCK, OUTPUT);

  // Reset powerSTEP and set CS
  digitalWrite(nSTBY_nRESET_PIN, HIGH);
  digitalWrite(nSTBY_nRESET_PIN, LOW);
  digitalWrite(nSTBY_nRESET_PIN, HIGH);
  digitalWrite(nCS_PIN, HIGH);

  // Start SPI
  SPI.begin();
  SPI.setDataMode(SPI_MODE3);

  // Configure powerSTEP
  driver.SPIPortConnect(&SPI); // give library the SPI port (only the one on an Uno)
  
  driver.configSyncPin(BUSY_PIN, 0); // use SYNC/nBUSY pin as nBUSY, 
                                     // thus syncSteps (2nd paramater) does nothing
                                     
  driver.configStepMode(STEP_FS_2); // 1/128 microstepping, full steps = STEP_FS,
                                // options: 1, 1/2, 1/4, 1/8, 1/16, 1/32, 1/64, 1/128
                                
  driver.setMaxSpeed(1000); // max speed in units of full steps/s 
  driver.setFullSpeed(2000); // full steps/s threshold for disabling microstepping
  driver.setAcc(100); // full steps/s^2 acceleration
  driver.setDec(100); // full steps/s^2 deceleration
  
  driver.setSlewRate(SR_980V_us); // faster may give more torque (but also EM noise),
                                  // options are: 114, 220, 400, 520, 790, 980(V/us)
                                  
  driver.setOCThreshold(200); // over-current threshold for the 2.8A NEMA23 motor
                            // used in testing. If your motor stops working for
                            // no apparent reason, it's probably this. Start low
                            // and increase until it doesn't trip, then maybe
                            // add one to avoid misfires. Can prevent catastrophic
                            // failures caused by shorts
  driver.setOCShutdown(OC_SD_ENABLE); // shutdown motor bridge on over-current event
                                      // to protect against permanant damage
  
  driver.setPWMFreq(PWM_DIV_1, PWM_MUL_0_75); // 16MHz*0.75/(512*1) = 23.4375kHz 
                            // power is supplied to stepper phases as a sin wave,  
                            // frequency is set by two PWM modulators,
                            // Fpwm = Fosc*m/(512*N), N and m are set by DIV and MUL,
                            // options: DIV: 1, 2, 3, 4, 5, 6, 7, 
                            // MUL: 0.625, 0.75, 0.875, 1, 1.25, 1.5, 1.75, 2
                            
  driver.setVoltageComp(VS_COMP_DISABLE); // no compensation for variation in Vs as
                                          // ADC voltage divider is not populated
                                          
  driver.setSwitchMode(SW_USER); // switch doesn't trigger stop, status can be read.
                                 // SW_HARD_STOP: TP1 causes hard stop on connection 
                                 // to GND, you get stuck on switch after homing
                                      
  driver.setOscMode(INT_16MHZ); // 16MHz internal oscillator as clock source

  // KVAL registers set the power to the motor by adjusting the PWM duty cycle,
  // use a value between 0-255 where 0 = no power, 255 = full power.
  // Start low and monitor the motor temperature until you find a safe balance
  // between power and temperature. Only use what you need
  driver.setRunKVAL(255);
  driver.setAccKVAL(100);
  driver.setDecKVAL(50);
  driver.setHoldKVAL(32);

  driver.setParam(ALARM_EN, 0x8F); // disable ADC UVLO (divider not populated),
                                   // disable stall detection (not configured),
                                   // disable switch (not using as hard stop)

  driver.getStatus(); // clears error flags

  Serial.println(F("Initialisation complete"));
}

void loop()
{
  fwd_cmd = analogRead(FWD_PIN);
  rev_cmd = analogRead(REV_PIN);
  slow_cmd = analogRead(SLOW_PIN);
  fast_cmd = analogRead(FAST_PIN);
  fstep_cmd = analogRead(FSTEP_PIN);
  rstep_cmd = analogRead(RSTEP_PIN);

  if (fwd_cmd > 500) {
    driver.run(FWD, value);
    fwd = true;
  } else if (rev_cmd > 500) {
    driver.run(REV, value);
    fwd = false;
  } else if (fast_cmd > 500) {
    if (value == MAX_VAL) {
      value = MAX_VAL;
    } else {
      value++;
      Serial.println(value);
      if (fwd) {
        driver.run(FWD, value);
      } else {
        driver.run(REV, value);
      }
    }
  } else if (slow_cmd > 500) {
    if (value == MIN_VAL) {
      value = MIN_VAL;
    } else {
      value--;
      Serial.println(value);
      if (fwd) {
        driver.run(FWD, value);
      } else {
        driver.run(REV, value);
      }
    }
  } else if (fstep_cmd > 500) {
    if (fwd) {
      driver.run(FWD, value);
    } else {
      driver.run(REV, value);
    }

  } else if (rstep_cmd > 500) {
    driver.softHiZ();
  } else {
    driver.softHiZ();
  }
}
