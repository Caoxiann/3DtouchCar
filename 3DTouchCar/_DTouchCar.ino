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
long status;//小车状态
int changed;
float RFzw=1,RBzw=1,LFzw=0.9,LBzw=0.9;//四个轮胎的速度系数
String readStr;
String pressureStr;
String pitchStr;
String statusStr;
float pressure,pitch;
void goBackward(float speed);
void trun(float angle);
void stop();
void goForward(float speed);
void setSpeed();
void turnAround(int direction);//0向左转，1向右转

// Add setup code
void setup()
{
    
    Serial.begin(9600);
    changed=0;
    // turn on motor
    carSpeed=150;
    status=0;
    stop();
    
}

// Add loop code
void loop()
{
    if (Serial.available()) {
        readStr=Serial.readStringUntil('c');
        pressureStr=readStr.substring(0, 5);
        pitchStr=readStr.substring(7, 12);
        statusStr=readStr.substring(14, 15);
        
        pressure=pressureStr.toFloat();
        pitch=pitchStr.toFloat();
        status=statusStr.toInt();
        Serial.print("read:");
        Serial.print(readStr);
        Serial.print("\tpressure:");
        Serial.print(pressure);
        Serial.print("\tpitch:");
        Serial.print(pitch);
        Serial.print("\tstatus:");
        Serial.print(status);
        Serial.print("\n");
        changed=0;
    }else{
        changed++;
    }
    if (changed>=300){
        if (changed>=1000) {
            changed=300;
        }
        stop();
    }else{
        trun(pitch);
        if (status==0) {
            goForward(pressure);
        }else{
            goBackward(pressure);
        }
        
    }
    
    

}

void trun(float angle){
    RFzw=1;
    RBzw=1;
    LFzw=0.9;
    LBzw=0.9;
    if (angle>=0) {
        if (angle>=1) {
            angle=1;
        }
        angle=1-angle;
        LBzw=angle*LBzw;
        LFzw=angle*LFzw;
        
    }else{
        if (angle<=-1) {
            angle=-1;
        }
        angle=1+angle;
        RBzw=angle*RBzw;
        RFzw=angle*RFzw;
    }
    
}

void goBackward(float speed){
    speed=speed/6.666;
    carSpeed=speed*255;
    motorRB.run(BACKWARD);
    motorRF.run(BACKWARD);
    motorLB.run(BACKWARD);
    motorLF.run(BACKWARD);

    setSpeed();
}

void stop(){
    motorRB.run(RELEASE);
    motorRF.run(RELEASE);
    motorLB.run(RELEASE);
    motorLF.run(RELEASE);
}

void goForward(float speed){
    speed=speed/6.666;
    carSpeed=speed*255;
    motorRB.run(FORWARD);
    motorRF.run(FORWARD);
    motorLB.run(FORWARD);
    motorLF.run(FORWARD);
    
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
