/* Glove code for a DUE as the message handler (BBS)
 * Messages are sent as 4 bytes, with the first byte corresponding to a command, and the 
 * remaining 3 bytes as a message of commanded velocity or planar position based on the 
 * direction of the message
 * 20190422 RPMatthew
 */

 //yellow wire SCA, blue SDA

#include <HX711.h>    //include load cell amp library
#include <Wire.h>     //include wire comms library

const int ledR = 2;       //Red RGB LED
const int ledB = 3;       //Blue RGB LED
const int ledG = 4;       //Green RGB LED
const int pwmb = 5;       //PWMB of lin act controller
const int incla = 6;      //BIN2 of lin act controller
const int decla = 7;      //BIN1 of lin act controller
const int DOUTL = 9;      //data from hx711-1
const int CLKL = 8;       //clock from hx711-1
const int DOUTR = 11;     //data from hx711-2
const int CLKR = 10;      //clock from hx711-2
const int linpot1 = A0;   //analog value of lin pot 1
const int linpot2 = A1;   //analog value of lin pot 2
const int linpot3 = A2;   //analog value of lin pot 3
const int linpot4 = A3;   //analog value of lin pot 4
const int trig1 = 12;     //BNC Trigger 1
const int trig2 = 13;     //BNC Trigger 2

HX711 LCL(DOUTL,CLKL);      //load cell left
HX711 LCR(DOUTR,CLKR);      //load cell right

float maxf = 10.00;  //maximum threshold value to stop lin act (in KG) DO NOT EXCEED 15!!
float minf = 0.7;   //defining minimum threshold value to initiate lin act
int maxp = 900;     //maximum value to lin act for retraction
int minp = 100;     //minimum value to lin act for extension
int speedla = 0;    //speed of lin act
int pos1 = 0;       //current value of lin pot 1
int pos2 = 0;       //current value of lin pot 2
int pos3 = 0;       //current value of lin pot 3
int pos4 = 0;       //current value of lin pot 4
int posla = 0;      //current position of lin act
int flagO = 0;      //flag open for BNC
int flagC = 0;      //flag close for BNC
int flagReady = 0;     //flag for MatLab Interface
float forceavg = 0.0;   //current value of force reading
int cal_fact = -13000;  //calibration value for load cells   (do not exceed -25000)

int commandState  = 0;    //0,1
word sentPos      = 0;    //0-4095
word sentForce    = 0;    //0-4095
byte enable;      //0,1
byte target;      //0-15
byte admit;       //0,1


void setup() {
  Wire.begin(); // join i2c bus (address optional for master)
  Serial.begin(9600);  // start serial for output
  enable = 0;
  target = 0;
  admit = 0;
  pinMode(ledR, OUTPUT);      //define LED
  pinMode(ledG, OUTPUT);      //define LED
  pinMode(ledB, OUTPUT);      //define LED
  pinMode(trig1, OUTPUT);     //define BNC trigger
  pinMode(trig2, OUTPUT);     //define BNC trigger
  digitalWrite(incla,LOW);    //lock position of lin act
  digitalWrite(decla,LOW);    //lock position of lin act
  analogWrite(pwmb,0);        //lock position of lin act
  digitalWrite(trig1,LOW);    //BNC signal low
  digitalWrite(trig2,LOW);    //BNC signal low
  LCL.set_scale(cal_fact);    //set and tare load cell 1
  LCL.tare();                 //set and tare load cell 1
  LCR.set_scale(cal_fact);    //set and tare load cell 2
  LCR.tare();}                //set and tare load cell 2

void loop() {
  forceavg = constrain((LCL.get_units()-LCR.get_units())/20,-maxf,maxf);   //avg force (-)comp,(+)ext
  pos1 = analogRead(linpot1);                             //position of lin pot 1
  pos2 = 2*analogRead(linpot2)-analogRead(linpot1);       //position of lin pot 2
  pos3 = 2*analogRead(linpot3)-analogRead(linpot4);       //position of lin pot 3
  pos4 = analogRead(linpot4);                             //position of lin pot 4
  posla = (pos4+pos2+pos3)/3;                             //position of LA
  sentPos = map(posla,minp,maxp,2048,4095);               //sent position
  sentForce = map(forceavg,-maxf,maxf,0,4095);            //sent force

  Serial.println();
  Serial.print("Pos: ");
  Serial.print(map(posla,minp,maxp,0,100));
  Serial.print("\tForce: ");
  Serial.print(forceavg);
  Serial.print("\tEnable: ");
  Serial.print(enable);
  Serial.print("\tAdmit: ");
  Serial.print(admit);
  Serial.print("\tTarget: ");
  Serial.print(target);
  Serial.print("\tFlagO: ");
  Serial.print(flagO);
  Serial.print("\tFlagC: ");
  Serial.print(flagC);

// ================================================================================================
// Send Planar Positions
  word pos   = sentPos;
  word force = sentForce;
  pos = pos << 4;

  byte byte1;
  byte byte2;
  byte byte3;
  byte byte4;

  byte1   = commandState;
  byte2   = highByte(pos);
  byte3   = highByte(force) | lowByte(pos);
  byte4   = lowByte(force);

  Wire.beginTransmission(1);  // BBS is on I2C0 as device 1
  Wire.write(byte1);   
  Wire.write(byte2);   
  Wire.write(byte3);   
  Wire.write(byte4);   
  Wire.endTransmission();     // stop transmitting

// ================================================================================================
// Get Velocity Update
  Wire.requestFrom(1, 4);     // BBS is on I2C0 as device 1
  if (Wire.available() == 4){
    byte1 = Wire.read(); // receive a byte as character
    byte2 = Wire.read(); // receive a byte as character
    byte3 = Wire.read(); // receive a byte as character
    byte4 = Wire.read(); // receive a byte as character
    commandState  = byte1;
    enable = bitRead(commandState,5);       //enable=0 stop motor, enable=1 run motor
    admit = bitRead(commandState,4);        //1=admittance, 0= BMI control
    target = commandState & 15;}            //value between 0-15

//=================================== Disabled Motor =============================

    if (enable == 0 && admit == 0){
      analogWrite(pwmb,0);
      digitalWrite(decla,LOW);
      digitalWrite(incla,LOW);
      digitalWrite(trig1,LOW);
      digitalWrite(trig2,LOW);
      
      if (target == 0){
        digitalWrite(ledR,HIGH);
        digitalWrite(ledG,LOW);
        digitalWrite(ledB,LOW);
        flagReady = 0;                      //not ready for command
        if (flagC == 1){
          digitalWrite(trig1,LOW);
          digitalWrite(trig2,HIGH);
          Serial.print("\tPulse Close");
          delay(10);
          digitalWrite(trig1,LOW);
          digitalWrite(trig2,LOW);
          flagO = 1;
          flagC = 0;}
        delay(1);}
      else if (target == 1){
        digitalWrite(ledR,LOW);
        digitalWrite(ledG,HIGH);
        digitalWrite(ledB,LOW);
        flagReady = 1;                //ready for command
        flagO=1;
        flagC=1;
        delay(1);}
      else if (target == 2){
        digitalWrite(ledR,LOW);
        digitalWrite(ledG,LOW);
        digitalWrite(ledB,HIGH);
        if (flagO == 1){
          digitalWrite(trig1,HIGH);
          digitalWrite(trig2,LOW);
          Serial.print("\tPulse Open");
          delay(10);
          digitalWrite(trig1,LOW);
          digitalWrite(trig2,LOW);
          flagO = 0;
          flagC = 1;}
        delay(1);}
      else{
        digitalWrite(ledR,HIGH);
        digitalWrite(ledG,HIGH);
        digitalWrite(ledB,HIGH);
        Serial.print("\tTarget: Unknown");
        flagReady = 1;                //ready for command
        flagO=1;
        flagC=1;
        delay(1);}}

//==================================== BMI Mode ============================================

    else if (enable == 1 && admit == 0){
      speedla = constrain(15*abs(forceavg),80,250);           //speed of LA
      if (target == 0){                     //flex,close hand
        flagReady = 0;                      //not ready for command
        if (flagC == 1){
          digitalWrite(trig1,LOW);
          digitalWrite(trig2,HIGH);
          Serial.print("\tPulse Close");
          delay(10);
          digitalWrite(trig1,LOW);
          digitalWrite(trig2,LOW);
          flagO = 1;
          flagC = 0;}
        if(forceavg > -maxf && posla>minp){          //Safety limits
          analogWrite(pwmb,speedla);      //speed of LA
          digitalWrite(incla,LOW);        //direction of LA
          digitalWrite(decla,HIGH);       //direction of LA
          digitalWrite(ledR,HIGH);        //Red on
          digitalWrite(ledG,LOW);         //Green off
          digitalWrite(ledB,LOW);}        //Blue off
        else{  
          analogWrite(pwmb,0);            //stop motor
          digitalWrite(incla,LOW);        //stop motor
          digitalWrite(decla,LOW);        //stop motor
          digitalWrite(ledR,LOW);         //Red off
          digitalWrite(ledG,HIGH);        //Green on
          digitalWrite(ledB,LOW);}}       //Blue off
  
      else if (target == 1) {         //stop motor
        analogWrite(pwmb,0);          //stop motor
        digitalWrite(decla,LOW);      //stop motor
        digitalWrite(incla,LOW);      //stop motor
        digitalWrite(ledR,LOW);       //red off
        digitalWrite(ledG,HIGH);      //green on
        digitalWrite(ledB,LOW);       //blue off
        flagReady = 1;                //ready for command
        flagO=1;
        flagC=1;}
  
      else if (target == 2){            //open,extend hand
        flagReady = 0;                  //not ready for command
        if (flagO == 1){
          digitalWrite(trig1,HIGH);
          digitalWrite(trig2,LOW);
          Serial.print("\tPulse Open");
          delay(10);
          digitalWrite(trig1,LOW);
          digitalWrite(trig2,LOW);
          flagO = 0;
          flagC = 1;}
        if (forceavg < maxf && posla<maxp){                    //open,extend hand
          analogWrite(pwmb,speedla);      //speed of LA
          digitalWrite(decla,LOW);        //direction of LA
          digitalWrite(incla,HIGH);       //direction of LA
          digitalWrite(ledR,LOW);         //red off
          digitalWrite(ledG,LOW);         //green off
          digitalWrite(ledB,HIGH);}       //blue on
        else{
          analogWrite(pwmb,0);            //stop motor
          digitalWrite(incla,LOW);        //stop motor
          digitalWrite(decla,LOW);        //stop motor
          digitalWrite(ledR,LOW);         //red off
          digitalWrite(ledG,HIGH);        //green on
          digitalWrite(ledB,LOW);}}       //blue off

      else{                         //unknown target
        Serial.print("\tTarget: Unknown");
        analogWrite(pwmb,0);        //stop motor
        digitalWrite(decla,LOW);    //stop motor
        digitalWrite(incla,LOW);    //stop motor
        digitalWrite(ledR,HIGH);    //red on
        digitalWrite(ledG,HIGH);    //blue on
        digitalWrite(ledB,HIGH);    //green on
        flagReady = 1;                //ready for command
        flagO=1;
        flagC=1;
        delay(1);}}

//=========================================== Admittance Mode =================================

    else if(enable == 1 && admit == 1){
      digitalWrite(trig1,LOW);
      digitalWrite(trig2,LOW);
      flagReady = 1;                //ready for command
      flagO=1;
      flagC=1;
        if(admit == 1){
          forceavg = constrain((LCL.get_units()-LCR.get_units())/20,-maxf,maxf);   //avg force (-)comp,(+)ext
          pos1 = analogRead(linpot1);                             //position of lin pot 1
          pos2 = 2*analogRead(linpot2)-analogRead(linpot1);       //position of lin pot 2
          pos3 = 2*analogRead(linpot3)-analogRead(linpot4);       //position of lin pot 3
          pos4 = analogRead(linpot4);                             //position of lin pot 4
          posla = (pos4+pos2+pos3)/3;                             //position of LA
          speedla = constrain(10*abs(forceavg)+55,60,250);        //speed of LA
          sentPos = map(posla,minp,maxp,2048,4095);               //sent position
          sentForce = map(forceavg,-maxf,maxf,0,4095);            //sent force
      
          if (forceavg > minf && posla>minp){   //close hand under admittance
            analogWrite(pwmb,speedla);
            digitalWrite(incla,LOW);
            digitalWrite(decla,HIGH);
            digitalWrite(ledR,HIGH);
            digitalWrite(ledG,LOW);
            digitalWrite(ledB,LOW);
            Serial.print("\tClosing");}
          else if (forceavg < -minf && posla<maxp){   //open hand under admittance
            analogWrite(pwmb,speedla);
            digitalWrite(decla,LOW);
            digitalWrite(incla,HIGH);
            digitalWrite(ledR,LOW);
            digitalWrite(ledG,LOW);
            digitalWrite(ledB,HIGH);
            Serial.print("\tOpening");}
          else{                                      //stop motor if force below minimum threshold [minf]
            analogWrite(pwmb,0);
            digitalWrite(decla,LOW);
            digitalWrite(incla,LOW);
            digitalWrite(ledR,LOW);
            digitalWrite(ledG,HIGH);
            digitalWrite(ledB,LOW);}}
      delay(1);}

//=========================================== Unknown Command =================================

    else{
      flagReady = 1;                //ready for command
      flagO=1;
      flagC=1;
      analogWrite(pwmb,0);
      digitalWrite(decla,LOW);
      digitalWrite(incla,LOW);
      digitalWrite(ledR,HIGH);
      digitalWrite(ledG,HIGH);
      digitalWrite(ledB,HIGH);
      Serial.print("\tUnkown Command");
      delay(1);}
}
