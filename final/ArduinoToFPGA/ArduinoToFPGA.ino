#include <SoftwareSerial.h>

SoftwareSerial mySerial(5, 6); //建立軟體串列埠腳位 (RX, TX)
int LED = 13;

void setup()
{
//  pinMode(LED, OUTPUT);
  Serial.begin(9600);   //設定硬體串列埠速率
  mySerial.begin(9600); //設定軟體串列埠速率
}

void loop()
{
  while (Serial.available())
  {
    int num = Serial.read();
    Serial.println(num);
    int ret = mySerial.write(num); //讀取PC傳送之字元,從軟體串列埠TX送給右方板
    Serial.println(ret);
//    while (mySerial.available())
//    {
//      //led_blink();
//      //led_blink();
//      Serial.println(mySerial.read()); //左方板向PC傳送字串
//    }
  }
}

void led_blink()
{
  digitalWrite(LED, HIGH);
  delay(1000);
  digitalWrite(LED, LOW);
  delay(500);
}
