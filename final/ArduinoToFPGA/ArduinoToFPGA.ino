#include <SoftwareSerial.h>
#include <stdlib.h>
#include "Wire.h"
#include "I2Cdev.h"
#include "MPU6050.h"
#include "math.h"

MPU6050 mpu;

int16_t accY, accZ, gyroX;
volatile int gyroRate;
volatile float accAngle, gyroAngle, currentAngle, prevAngle = 0;

SoftwareSerial mySerial(5, 6); //建立軟體串列埠腳位 (RX, TX)
int LED = 13;

void setup()
{
  // LED on Nano board
  pinMode(LED, OUTPUT);

  // 設定硬體串列埠速率
  Serial.begin(115200);
  mySerial.begin(115200);

  mpu.initialize();

  // 校正 mpu
  mpu.setYAccelOffset(-1450);
  mpu.setZAccelOffset(1450);
  mpu.setXGyroOffset(31);
}

void loop()
{
  // 讀取加速度與陀螺儀數值
  accY = mpu.getAccelerationY();
  accZ = mpu.getAccelerationZ();
  gyroX = mpu.getRotationX();

  // 修正角度數值
  accAngle = atan2(accY, accZ) * RAD_TO_DEG;
  gyroRate = map(gyroX, -32768, 32767, -250, 250);
  gyroAngle = (float)gyroRate * 0.005;
  currentAngle = 0.9934 * (prevAngle + gyroAngle) + 0.0066 * (accAngle);
  prevAngle = currentAngle;

  // 轉換數值格式，以便於與 FPGA 溝通
  double rx_angle = currentAngle;
  int angle = round(rx_angle) + 180; // 將角度數值從 -180~180 投射到 0~360
  word word_angle = (word)angle;
  byte tx_angle_high = highByte(word_angle);
  byte tx_angle_low = lowByte(word_angle);
  // 檢視數值（Debug）
  Serial.print("Transmit : ");
  Serial.println(angle);
  Serial.print("High bits: ");
  Serial.println(tx_angle_high, BIN);
  Serial.print("Low  bits: ");
  Serial.println(tx_angle_low, BIN);
  // 讀取 PC 傳送之字元,從軟體串列埠 TX 傳送給 FPGA 板
  int ret = mySerial.write(tx_angle_high);
  int ret2 = mySerial.write(tx_angle_low);
  Serial.println(ret);
  Serial.println(ret2);

  // （Debug）
  if (angle >= 180)
    digitalWrite(LED, HIGH);
  else
    digitalWrite(LED, LOW);
}