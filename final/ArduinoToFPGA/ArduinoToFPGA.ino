#include <SoftwareSerial.h>
#include <stdlib.h>
#include "Wire.h"
#include "I2Cdev.h"
#include "MPU6050.h"
#include "math.h"

MPU6050 mpu;

int16_t accY, accZ;
float accAngle;

SoftwareSerial mySerial(5, 6); //建立軟體串列埠腳位 (RX, TX)
int LED = 13;

void setup()
{
  //  pinMode(LED, OUTPUT);
  Serial.begin(115200);   //設定硬體串列埠速率
  mySerial.begin(115200); //設定軟體串列埠速率
  mpu.initialize();
}

void loop()
{
  accZ = mpu.getAccelerationZ();
  accY = mpu.getAccelerationY();
  accAngle = atan2(accY, accZ) * RAD_TO_DEG;

  if (isnan(accAngle))
    Serial.println("angle is nan");
  else
  {
    Serial.print("angle: ");
    Serial.print(accAngle);
    Serial.print("\n");
  }

  //  while (Serial.available())
  //  {
  //    Serial.read();
  //    double rx_angle = random(0, 360); // random angle for test
  double rx_angle = accAngle; // angle read from gy521

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

  // TODO: use ISR to sample angle every # milliseconds
  delay(150);
  //  }
}

void led_blink()
{
  digitalWrite(LED, HIGH);
  delay(500);
  digitalWrite(LED, LOW);
  delay(500);
}
