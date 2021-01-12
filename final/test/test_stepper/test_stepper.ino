#include <Stepper.h>
#define STEPS 200  //定義步進馬達每圈的步數

//steps:代表馬達轉完一圈需要多少步數。如果馬達上有標示每步的度數，
//將360除以這個角度，就可以得到所需要的步數(例如：360/3.6=100)。(int)

Stepper stepper(STEPS, 5, 4, 3, 2);

void setup()
{
stepper.setSpeed(150);     // 將馬達的速度設定成140RPM 最大  150~160
}

void loop()
{
//stepper.step(100);//正半圈
//delay(1000);
//stepper.step(-100);//反半圈
//delay(1000);
//stepper.step(200);//正1圈
//delay(1000);
//stepper.step(-200);//反1圈
//delay(1000);
//stepper.step(300);//正1圈半
//delay(1000);
//stepper.step(-300);//反1圈半
//delay(1000);
stepper.step(1600);//正8圈
//delay(1000);
//stepper.step(-1600);//反8圈
//delay(1000);
}
