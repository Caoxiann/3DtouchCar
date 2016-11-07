//
// 3DTouchCar
//
// Description of the project
// Developed with [embedXcode](http://embedXcode.weebly.com)
//
// Author 		陈浩贤
// 				陈浩贤
//
// Date			2016/11/6 下午1:56
// Version		<#version#>
//
// Copyright	© 陈浩贤, 2016年
// Licence		<#licence#>
//
// See         ReadMe.txt for references
//


// Core library for code-sense - IDE-based
#if defined(WIRING) // Wiring specific
#include "Wiring.h"
#elif defined(MAPLE_IDE) // Maple specific
#include "WProgram.h"
#elif defined(MPIDE) // chipKIT specific
#include "WProgram.h"
#elif defined(DIGISPARK) // Digispark specific
#include "Arduino.h"
#elif defined(ENERGIA) // LaunchPad specific
#include "Energia.h"
#elif defined(LITTLEROBOTFRIENDS) // LittleRobotFriends specific
#include "LRF.h"
#elif defined(MICRODUINO) // Microduino specific
#include "Arduino.h"
#elif defined(SPARK) || defined(PARTICLE) // Particle / Spark specific
#include "Arduino.h"
#elif defined(TEENSYDUINO) // Teensy specific
#include "Arduino.h"
#elif defined(REDBEARLAB) // RedBearLab specific
#include "Arduino.h"
#elif defined(ESP8266) // ESP8266 specific
#include "Arduino.h"
#elif defined(ARDUINO) // Arduino 1.0 and 1.5 specific
#include "Arduino.h"
#else // error
#error Platform not defined
#endif // end IDE

// Set parameters


// Include application, user and local libraries
#include <AFMotor/AFMotor.h>
#include <SoftwareSerial.h>
// Prototypes


// Define variables and constants
//SoftwareSerial BLE(0,1);

AF_DCMotor motorRB(1);//右后轮
AF_DCMotor motorRF(2);//右前轮
AF_DCMotor motorLF(3);//左前轮
AF_DCMotor motorLB(4);//左后轮

int carSpeed; //小车的速度
int status;//小车状态
float RFzw=1,RBzw=1,LFzw=0.9,LBzw=0.9;//四个轮胎的速度系数
float trunRatio;//转向系数

void goBackward(int speed);
void trun(int angle);
void stop();
void goForward(int speed);
void setSpeed();
void turnAround(int direction);//0向左转，1向右转
// Add setup code
void setup()
{
    
    Serial.begin(9600);
    
    // turn on motor
    carSpeed=150;
    status=0;
    stop();
    
}

// Add loop code
void loop()
{
    if (Serial.available()) {
        status=Serial.read();
        status=status-'0';
        Serial.print("status:");
        Serial.print(status);
        Serial.print("\n");
    }
    switch (status) {
        case 0:
            stop();
            break;
        case 1:
            goForward(100);
            break;
        case 2:
            goBackward(100);
            break;
        case 3:
            trun(75);
            break;
        case 4:
            trun(-75);
            break;
        case 5:
            turnAround(0);
            break;
        case 6:
            turnAround(1);
            break;
        default:
            break;
    }


}

void trun(int angle){
    RFzw=1;
    RBzw=1;
    LFzw=1;
    LBzw=1;
    if (angle>=0) {
        trunRatio=1-angle/90.0;
        RBzw=trunRatio*RBzw;
        RFzw=trunRatio*RFzw;
        
    }else{
        trunRatio=1+angle/90.0;
        LBzw=trunRatio*LBzw;
        LFzw=trunRatio*LFzw;
    }
    
    setSpeed();
    
}

void goBackward(int speed){
    carSpeed=speed;
    
    motorRB.run(BACKWARD);
    motorRF.run(BACKWARD);
    motorLB.run(BACKWARD);
    motorLF.run(BACKWARD);
    
    RFzw=0.9;
    RBzw=0.9;
    LFzw=1;
    LBzw=1;
    
    setSpeed();
}

void stop(){
    motorRB.run(RELEASE);
    motorRF.run(RELEASE);
    motorLB.run(RELEASE);
    motorLF.run(RELEASE);
}

void goForward(int speed){
    
    carSpeed=speed;
    motorRB.run(FORWARD);
    motorRF.run(FORWARD);
    motorLB.run(FORWARD);
    motorLF.run(FORWARD);
    
    RFzw=1;
    RBzw=1;
    LFzw=0.9;
    LBzw=0.9;
    setSpeed();
}

void setSpeed(){
    motorRF.setSpeed(carSpeed*RFzw);
    motorLF.setSpeed(carSpeed*LFzw);
    motorLB.setSpeed(carSpeed*LBzw);
    motorRB.setSpeed(carSpeed*RBzw);
}

void turnAround(int direction){
    if (direction==0) {
        motorLB.run(BACKWARD);
        motorLF.run(BACKWARD);
        motorRB.run(FORWARD);
        motorRF.run(FORWARD);
    }else{
        motorRB.run(BACKWARD);
        motorRF.run(BACKWARD);
        motorLB.run(FORWARD);
        motorLF.run(FORWARD);
    }
    setSpeed();
}
