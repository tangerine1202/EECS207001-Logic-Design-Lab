#include <SoftwareSerial.h>
#include <stdlib.h>

SoftwareSerial mySerial(5, 6); //建立軟體串列埠腳位 (RX, TX)
int LED = 13;

void setup()
{
  //  pinMode(LED, OUTPUT);
  Serial.begin(115200);   //設定硬體串列埠速率
  mySerial.begin(115200); //設定軟體串列埠速率
}

void loop()
{
  while (Serial.available())
  {
    double rx_angle = random(0, 360); // angle read from gy521

    Serial.read();
    int angle = round(rx_angle);
    if (angle < 0)
      angle = -angle;
    word word_angle = (word)angle;
    byte tx_angle_high = highByte(word_angle);
    byte tx_angle_low = lowByte(word_angle);
    Serial.print("Transmit: ");
    Serial.println(angle);
    Serial.print("High: ");
    Serial.println(tx_angle_high, BIN);
    Serial.print("Low: ");
    Serial.println(tx_angle_low, BIN);
    int ret = mySerial.write(tx_angle_high); //讀取PC傳送之字元,從軟體串列埠TX送給右方板
    Serial.println(ret);
    int ret2 = mySerial.write(tx_angle_low);
    Serial.println(ret2);
    // blink LED and sleep for 1.5 sec
    led_blink();
  }
}

void led_blink()
{
  digitalWrite(LED, HIGH);
  delay(1000);
  digitalWrite(LED, LOW);
  delay(500);
}
