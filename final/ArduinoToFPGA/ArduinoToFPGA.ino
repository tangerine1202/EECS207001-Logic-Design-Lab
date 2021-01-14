#include <SoftwareSerial.h>
#include <stdlib.h>
#include "Wire.h"
#include "I2Cdev.h"
#include "MPU6050.h"
#include "math.h"

#define sampleTime 0.005 // Don't modify this line

MPU6050 mpu;

int16_t accY, accZ, gyroX;
volatile int gyroRate;
volatile float accAngle, gyroAngle, currentAngle, prevAngle = 0;

SoftwareSerial mySerial(5, 6); //建立軟體串列埠腳位 (RX, TX)
int LED = 13;

void setup()
{
  // LED on nano board
  pinMode(LED, OUTPUT);

  // start the communication
  Serial.begin(115200);   //設定硬體串列埠速率
  mySerial.begin(115200); //設定軟體串列埠速率

  
  mpu.initialize();

  // calibrate mpu
  mpu.setYAccelOffset(-1450);
  mpu.setZAccelOffset(1450);
  mpu.setXGyroOffset(31);

//  mpu.setAccelFIFOEnabled(false);
//  mpu.setXGyroFIFOEnabled(false);
  
  // initialize PID sampling loop
  //  init_sampling_per_5ms();
}

void loop()
{
  // read acceleration and gyroscope values
  accY = mpu.getAccelerationY();
  accZ = mpu.getAccelerationZ();
  gyroX = mpu.getRotationX();

  accAngle = atan2(accY, accZ) * RAD_TO_DEG;
  gyroRate = map(gyroX, -32768, 32767, -250, 250);
  gyroAngle = (float)gyroRate * sampleTime;
  currentAngle = 0.9934 * (prevAngle + gyroAngle) + 0.0066 * (accAngle);
  prevAngle = currentAngle;

  double rx_angle = currentAngle;
  int angle = round(rx_angle) + 180; // calibrate angle from -180~180 to 0~360
  word word_angle = (word)angle;
  byte tx_angle_high = highByte(word_angle);
  byte tx_angle_low = lowByte(word_angle);
  Serial.print("Transmit : ");
  Serial.println(angle);
  Serial.print("High bits: ");
  Serial.println(tx_angle_high, BIN);
  Serial.print("Low  bits: ");
  Serial.println(tx_angle_low, BIN);
  int ret = mySerial.write(tx_angle_high); // 讀取PC傳送之字元,從軟體串列埠TX送給右方板
  Serial.println(ret);
  int ret2 = mySerial.write(tx_angle_low);
  Serial.println(ret2);

//  mpu.resetFIFO();


  if (angle >= 180)
    digitalWrite(LED, HIGH);
  else
    digitalWrite(LED, LOW);
}

//ISR(TIMER1_COMPA_vect){
//   // calculate the angle of inclination
//  accAngle = atan2(accY, accZ)*RAD_TO_DEG;
//  gyroRate = map(gyroX, -32768, 32767, -250, 250);
//  gyroAngle = (float)gyroRate*sampleTime;
//  currentAngle = 0.9934*(prevAngle + gyroAngle) + 0.0066*(accAngle);
//  prevAngle = currentAngle;
//}

//void init_sampling_per_5ms() {
//  // initialize Timer1
//  cli();          // disable global interrupts
//  TCCR1A = 0;     // set entire TCCR1A register to 0
//  TCCR1B = 0;     // same for TCCR1B
//  // set compare match register to set sample time 5ms
//  OCR1A = 9999;
//  // turn on CTC mode
//  TCCR1B |= (1 << WGM12);
//  // Set CS11 bit for prescaling by 8
//  TCCR1B |= (1 << CS11);
//  // enable timer compare interrupt
//  TIMSK1 |= (1 << OCIE1A);
//  sei();          // enable global interrupts
//}
