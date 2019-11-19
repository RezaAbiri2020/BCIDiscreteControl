// Libraries
#include "HX711.h"              // Force Sensor Library
#include <BasicLinearAlgebra.h> // LA
#include <Servo.h>
#include <math.h>
#include <Wire.h>
#include <Adafruit_ADS1015.h>
using namespace BLA;

// Pin declarations

// Limit switches
int   pinLimitRT  = 2;
int   pinLimitRB  = 3;
int   pinLimitLT  = 4;
int   pinLimitLB  = 5;
int   pinLimitRM  = 6;
int   pinLimitLM  = 7;

// Force transducers
int   pinTensometerClk  = 8;
int   pinTensometerDatX = 9;
int   pinTensometerDatY = 10;

// Motors
int   pinM1Pwm    = 11;
int   pinM2Pwm    = 12;

// LEDs
int pinLED1r = 22;
int pinLED1g = 24;
int pinLED1b = 26;
int pinLED2r = 23;
int pinLED2g = 25;
int pinLED2b = 27;

// BNC
int   pinTriggerIn    = 28;
int   pinTriggerOut   = 29;
int   pinPlanarPulse  = 30;
int   pinBeep         = 31;
int   pinSafetyButton = 33;  

//Motors
int   pinM2Dir    = 52;
int   pinM1Dir    = 53;

// Analog Pins
int   pinCountMotorRight        = A7;
int   pinEncoderMotorRight      = A8;
int   pinEncoderMotorLeft       = A9;
int   pinCountMotorLeft         = A10;

int   mapDir = 0;
float mapCtrlV = 0.0;
bool  safetyButton = 0;

// Define BCI Variables
float brainTargetX    = 0.0;
float brainTargetY    = 0.0;
float brainTargetDist = 0.0;
int   brainRadius     = 100;
int   brainOriginY    = 0;
float brainTargetListX[] = {0, brainRadius, brainRadius*sqrt(2)/2, 0, -brainRadius*sqrt(2)/2, -brainRadius, -brainRadius*sqrt(2)/2, 0, brainRadius*sqrt(2)/2};
float brainTargetListY[] = {brainOriginY, brainOriginY, brainOriginY + brainRadius*sqrt(2)/2, brainOriginY + brainRadius, brainOriginY + brainRadius*sqrt(2)/2, brainOriginY, brainOriginY - brainRadius*sqrt(2)/2, 0, brainOriginY - brainRadius*sqrt(2)/2};
bool  brainTargetMoving = 0;
bool  planarBrainEnable = 0;
int   commandStatePlanar = 0;
bool  BNCval = LOW;

bool  graspInd;
bool  bbsEnable = 0;
bool  velEnable = 0;
int   brainTarget = 0;
int   commandState = 0;
word  sentXPos = 0;
word  sentYPos = 0;
word  sentXForce = 0;
word  sentYForce = 0;
word  commandXVel;
word  commandYVel;

word xPos   = sentXPos;
word yPos   = sentYPos;
word xForce   = sentXForce;
word yForce   = sentYForce;

byte byte1in;
byte byte2in;
byte byte3in;
byte byte4in;
byte byte5in;
byte byte1out;
byte byte2out;
byte byte3out;
byte byte4out;
byte byte5out;
byte byte6out;
byte byte7out;

int triggerIn = 0;
//bool triggerOut = 0;

float brainXBound   = 5.0; // \pm mm/s
float brainXV       = 0;
float brainXVel     = 0.0;

float brainYBound   = 5.0; // \pm mm/s
float brainYV       = 0;
float brainYVel     = 0.0;

byte h1 = 0;
byte u1 = 0;
byte h2 = 0;
byte u2 = 0;

// Admittance Circle
float circVx = 0.0;
float circVy = 0.0;
float maxFEex = -600.0;
float maxFEfy = 600.0;
float circRadius;
float circTheta;
int   circDir = 0;
float totForce = 0;

// Minimum Jerk
bool  mjGoalMet = 0;
float mj_p = 0.0;
float mj_predX = 0;
float mj_predY = 0;
float mj_errX = 0;
float mj_errY = 0;
float mjTarX  = 0.0;
float mjTarY = 0.0;
float mjDur = 0.0;
float mjInitX  = 0.0;
float mjInitY  = 0.0;
float mjInitT  = 0.0;
float mjT  = 0.0;

int rightHand = 1;

//int graspInd;
int gloveState  = 0;

// Safety
int safety_lowerX = -300;
int safety_upperX =  300;
int safety_lowerY = 0;
int safety_upperY =  260;
int safety_bound  = 20;

bool  stateLimitLT  = LOW;
bool  stateLimitLM  = LOW;
bool  stateLimitLB  = LOW;
bool  stateLimitRT  = LOW;
bool  stateLimitRM  = LOW;
bool  stateLimitRB  = LOW;

// ATARI Pins
int   pinAtariUp      = 43;
int   pinAtariLeft    = 45;
int   pinAtariDown    = 47;
int   pinAtariRight   = 49;
int   pinAtariButton  = 51;
int   atariDir        = 0;
bool  atariButton     = LOW;

// Motor Left (M1)
float encoderMotorLeftAngle   = 0.0;
float MA3VoltageNewLeft       = 0.0;
float MA3VoltageOldLeft = 0.0;
int   revLeft = 0;
float MA3DegLeft = 0.0;
float MA3OffsetLeft = 0.0;
int   M1Pwm                     = 0;
bool  M1Dir                    = LOW;

float CountMotorLeftAngle     = 0.0;

// Motor Right (M2)
float encoderMotorRightAngle  = 0.0;
float MA3VoltageNewRight = 0.0;
float MA3VoltageOldRight = 0.0;
int   revRight = 0;
float MA3DegRight = 0.0;
float MA3OffsetRight = 0.0;
int   M2Pwm                     = 0;
bool  M2Dir                    = LOW;
float CountMotorRightAngle     = 0.0;

// Tensometer
HX711 scaleX(pinTensometerDatX, pinTensometerClk); // parameter "gain" is ommited; the default value 128 is used by the librarycs
HX711 scaleY(pinTensometerDatY, pinTensometerClk);
BLA::Matrix<2, 1> obsForce;
BLA::Matrix<2, 1> obsForce_old = (0, 0);
BLA::Matrix<2, 1> estForce;
BLA::Matrix<2, 1> innoForce;
BLA::Matrix<2, 1> estForcePrior;
BLA::Matrix<2, 2> estForceP;
BLA::Matrix<2, 2> estForcePPrior;
BLA::Matrix<2, 2> QForce;
BLA::Matrix<2, 2> SForce;
BLA::Matrix<2, 2> RForce;
BLA::Matrix<2, 2> KForce;
BLA::Matrix<2, 2> eye2;
float senForce = 0.0;
float senAngle = 0.0;

// Variables for Hand
int   pinEncoderWrist   = A6;
int   pinEncoderHand    = A7;
int   pinServoHand      = 4;
float encoderHandAngle  = 0.0;
Servo hand;
float angSEA  = 0.0;
float encoderWristAngle = 0.0;
float servoHandAngle    = 90.0;
bool  stateHandPosControl = LOW;
bool stateHandConstraint  = LOW;
float encoderHandOpen     = 0.0;
float encoderHandClosed   = 0.0;
float encoderHandGrasp    = 0.0;

//// Admittance
//BLA::Matrix<1, 1> k_dt;
//BLA::Matrix<1, 1> k_mass;
//BLA::Matrix<1, 1> k_visco;
//BLA::Matrix<1, 1> k_stable;
//BLA::Matrix<1, 1> k_attract;

float k_dt = 22.22 / 1000;
float k_mass = 1;
float k_visco = 1;
//BLA::Matrix<1, 1> k_stable;
//BLA::Matrix<1, 1> k_attract;




#define DIAMETER 44.75  // pulley diameter

//Communication
// Vars for Communication
int         ndxRead;
const byte  numChars = 38;
char        receivedChars[numChars]; // an array to store the received data
String      inString = "";
boolean     newData = false;

// Control Modes
int controlMode    = 0;

// Control Parameters
float oldTime       = 0.0;
float dt            = 0.0;
float thresholdDegError = -4;
float goalM1Deg     = 0.0;
float goalM2Deg     = 0.0;
long  M1cumDegError = 0.0;
float M1controlP    = 0.7;
float M1controlI    = 0.2;
long  M2cumDegError = 0.0;
float M2controlP    = 0.7;
float M2controlI    = 0.2;
int goal = 0;
double degm1 = 0;
double degm2 = 0;
double errorM1Deg = 0;
double errorM2Deg = 0;
float forceLim = 0;

BLA::Matrix<2, 1> force_current;
BLA::Matrix<2, 1> pos_start;
BLA::Matrix<2, 1> pos_goal;
BLA::Matrix<2, 1> pos_current;
BLA::Matrix<2, 1> pos_goalU;
BLA::Matrix<2, 1> pos_goaldU;
BLA::Matrix<2, 1> vel_current;
BLA::Matrix<2, 1> vel_update;

// Coordinate System
// For Coordinates
BLA::Matrix<2, 1> coordOrigin;
BLA::Matrix<2, 1> coordFarPoint;
BLA::Matrix<2, 1> coordInitHome;
BLA::Matrix<2, 1> coordHome;
BLA::Matrix<2, 1> coordEast;
BLA::Matrix<2, 1> coordNorthEast;
BLA::Matrix<2, 1> coordNorth;
BLA::Matrix<2, 1> coordNorthWest;
BLA::Matrix<2, 1> coordWest;
BLA::Matrix<2, 2> rotMatrix;
BLA::Matrix<2, 1> coordNNW;
BLA::Matrix<2, 1> coordWNW;
BLA::Matrix<2, 1> coordNNE;
BLA::Matrix<2, 1> coordENE;

int coordRadius[9] = {350, 360, 360, 270, 250, 270, 360, 360, 350};

int minPointX   = 0;
int minPointY   = 15;
int maxPointX   = 720;
int maxPointY   = 250;

bool goalMet = 0;
float initDistHeading = 0.0;

//New position control
float setCtrlV = 70.0;
float posCtrlV = 0.0;
float ramp = 5.0;
float errXYratio = 1.0;
float errX = 0.0;
float errY = 0.0;
float errTotal = 0.0;
float rVel = 50.0;
float goalHeading = 0.0;
int   i = 0;
int   countSteady = 0;
float fAxialSum = 0.0;
float fAxialMean = 0.0;
float fAxial  = 0.0;
float fNorm = 0.0;

float forceMapThreshold = -4;
int forceMapCnt = 0;
//bool goalMet = 0;

int pinMassPot = A1;
int pinViscoPot = A2;

float delayTime = 0.0;

float x = 0.0;
float y = 0.0;

float circX = 0.0;
float circY = 0.0;


int16_t adc0, adc1;

Adafruit_ADS1015 ads;     /* Use thi for the 12-bit version */

int a = 1;
int b = 1;

int FF_status = 0;
float f_a = 0;
float f_b = 0;
float f_c = 0;
float f_d = 0;
float f_e = 0;
float f_f = 0;

float e_theta = 0;
float e_r_obs;
float e_r_pred;
float e_x;
float e_y;
float rad_err;
float e_k;

float norm_velx;
float norm_vely;


float ellipseRadius;
float normvx;
float normvy;
float tanvx;
float tanvy;

float k_spring = 1;
float fh_tan;
float fh_norm;
float norm_err;
float vel_current_norm;
float vel_current_tan;
float vel_tan;
float vel_norm;
//-------------------------------------------------------------------------------------------------------
  
void setup() {
  ads.begin();
  ads.setGain(GAIN_TWOTHIRDS); 

//  ads.setSPS(ADS1015_DR_32SPS);
//  ads.overRideConversionDelay(65);
  Wire.begin();
  Serial.begin(115200);

  // Pin define
  pinMode(pinLimitLT, INPUT);
  pinMode(pinLimitLM, INPUT);
  pinMode(pinLimitLB, INPUT);
  pinMode(pinLimitRT, INPUT);
  pinMode(pinLimitRM, INPUT);
  pinMode(pinLimitRB, INPUT);
  pinMode(pinM1Dir, OUTPUT);
  pinMode(pinM2Dir, OUTPUT);

  pinMode(pinAtariUp, INPUT);
  pinMode(pinAtariLeft, INPUT);
  pinMode(pinAtariDown, INPUT);
  pinMode(pinAtariRight, INPUT);
  pinMode(pinAtariButton, INPUT);
  pinMode(pinTriggerIn, INPUT);
  pinMode(pinTriggerOut, OUTPUT);

  pinMode(pinLED1r, OUTPUT);
  pinMode(pinLED1g, OUTPUT);
  pinMode(pinLED1b, OUTPUT);
  pinMode(pinLED2r, OUTPUT);
  pinMode(pinLED2g, OUTPUT);
  pinMode(pinLED2b, OUTPUT);

  pinMode(pinSafetyButton, INPUT);
  pinMode(pinBeep, OUTPUT);

  writeLEDs(255,255,255,255,255,255);
  
  digitalWrite(pinPlanarPulse, LOW );

  coordOrigin     << minPointX, minPointY;
  coordFarPoint   << maxPointX, maxPointY;
  coordInitHome   << (maxPointX - minPointX) / 2, minPointY;
  coordHome       << 0.0, 0.0;

  setCoords();

  // Admittance Params
  pos_goal.Fill(0);
  pos_current.Fill(0);
  pos_goalU.Fill(0);
  pos_goaldU.Fill(0);

//  k_dt      << 22.22 / 1000;  // s (45 Hz)
//  k_mass    << 1 / 0.005;      // 1 / kg
//  k_visco   << 1 - 0.1;       // N s / mm
//  //  k_stable  << 0.3;             // N / mm
//  //  k_attract << 3;             // mm / s
//
//  k_stable  << 0.0;             // N / mm
//  k_attract << 0.0;             // mm / s

  vel_current.Fill(0);
  force_current.Fill(0);

  // Prepare Tensometer
  scaleX.power_up();
  scaleY.power_up();
  scaleX.set_scale();   // this value is obtained by calibrating the scale with known weights; see the README for details
  scaleX.tare();              // reset the scale to 0
  scaleY.set_scale();   // this value is obtained by calibrating the scale with known weights; see the README for details
  scaleY.tare();

  obsForce.Fill(0);
  estForcePrior.Fill(0);
  estForcePPrior.Fill(0);
  innoForce.Fill(0);
  SForce.Fill(0);
  KForce.Fill(0);
  QForce  = {.1 * .1, 0 * 0, 0 * 0, .1 * .1};
  RForce  = {1 * 1, 0, 0, 1 * 1};
  eye2    = {1, 0, 0, 1};
  estForceP = {1, 0, 0, 1};
  estForce  = {0, 0};

//  analogWriteResolution(10);
}

//-------------------------------------------------------------------------------------------------------

void loop() {

  writeLEDs(255,255,255,255,255,255);
  readBrainVel();
  writePos2Brain();
  triggerIn  = digitalRead(pinTriggerIn);
  digitalWrite(pinTriggerOut, triggerIn);

  readEncoderMotorLeft();
  readEncoderMotorRight();
  
  readForce();
  readLimitSwitches();
//  readEncoderMotorLeft();
//  readEncoderMotorRight();
  recvWithEndMarker();
  showNewData();
  serialPrint();
  
  pos_current(0) = SToX(encoderMotorLeftAngle, encoderMotorRightAngle);
  pos_current(1) = SToY(encoderMotorLeftAngle, +encoderMotorRightAngle);

  // Set BNC Signal Low
  BNCval = LOW;
  digitalWrite(pinPlanarPulse, BNCval);

  switch (controlMode) {

    case 1:   // Target
      controlMotorAngles_3(setCtrlV);
      break;
      
    case 2:   // Admittance
      updateAdmittance();
      break;
  
    case 3:   // Joystick
      readAtari();
      dt            = millis() / 1000.0 - oldTime;
      oldTime       = millis() / 1000.0;
      vel_update(0)   =  vel_current(0) * 0.1;
      vel_update(1)   =  vel_current(1) * 0.1;
      senForce = 5.0;
      switch (atariDir) {
        case 0:
          senAngle   = 0;
          senForce   = 0;
          break;
        case 1:
          senAngle   = 0;
          break;
        case 2:
          senAngle   = 45;
          break;
        case 3:
          senAngle   = 90;
          break;
        case 4:
          senAngle   = 135;
          break;
        case 5:
          senAngle   = 180;
          break;
        case 6:
          senAngle   = -135;
          break;
        case 7:
          senAngle   = -90;
          break;
        case 8:
          senAngle   = -45;
          break;
      }
      vel_update(0)       = (senForce * 10) * sin(-senAngle / 180 * PI) + vel_update(0);
      vel_update(1)       = (senForce * 10) * cos(senAngle / 180 * PI) + vel_update(1);
      break;

    case 5:     // Calibration
      calibrate();     
      break;

    case 6:     // Minimum Jerk
      updateMJ();
      break;

    case 7: // Circle with safety
      updateCircle();
      safetyButton = digitalRead(pinSafetyButton);
      if (safetyButton){
        vel_update(0) = 0;
        vel_update(1) = 0;
      }
      break;

    case 8:     // Circle Admittance
      circAdm();
      break;

    case 9:   // Set Coordinates
      setCoords();
      break;

    case 4:    // Brain Velocity Control
        planarBrainEnable = 1;
        if (bbsEnable & velEnable){
              vel_update(0) = map((int) commandXVel, 0, 4095,-100,100);
              vel_update(1) = map((int) commandYVel, 0, 4095,-100,100);
           }
        else {
          vel_update(0) = 0;
          vel_update(1) = 0;
        }
      break;

    case 15:    // Brain Position Correction
      if(mjGoalMet == 0){
      planarBrainEnable = 0;
      updateMJ();
      }
      else{
        brainTargetMoving = 0;
        controlMode = 4; 
      }
      break;

    case 27:    // Force map - linear
      switch (mapDir) {
        case 0:
          senAngle   = 0;
          break;
        case 1:
          senAngle   = 0;
          break;
        case 2:
          senAngle   = 45;
          break;
        case 3:
          senAngle   = 90;
          break;
        case 4:
          senAngle   = 135;
          break;
        case 5:
          senAngle   = 180;
          break;
        case 6:
          senAngle   = -135;
          break;
        case 7:
          senAngle   = -90;
          break;
        case 8:
          senAngle   = -45;
          break;
      }
      vel_update(0)       = (mapCtrlV) * sin(-senAngle / 180 * PI);
      vel_update(1)       = (mapCtrlV) * cos(senAngle / 180 * PI);

      safetyButton = digitalRead(pinSafetyButton);

      if (safetyButton){
        vel_update(0)       = 0;
        vel_update(1)       = 0;
      }
      else {
        M1Pwm = 0;
        M2Pwm = 0;
      }

      break;
  }

  safetyLimits();
  speedToPWM(XYToS0(vel_update(0), vel_update(1)), XYToS1(vel_update(0), vel_update(1)));
  writeMotors();
  vel_current = vel_update;   // Update Velocities
}
// ==========================================================
// FUNCTIONS

void readBrainVel(){
  Wire.requestFrom(1, 5);     // BBS is on I2C0 as device 1
  if (Wire.available() == 5)
  {
    byte1in = Wire.read(); // receive a byte as character
    byte2in = Wire.read(); // receive a byte as character
    byte3in = Wire.read(); // receiveA a byte as character
    byte4in = Wire.read(); // receive a byte as character
    byte5in = Wire.read(); // receive a byte as character

    byte xVelHigh;
    byte xVelLow;
    byte yVelHigh;
    byte yVelLow;

    // Unpack comm byte
    commandState  = byte1in;
    bbsEnable = bitRead(commandState,5);
    velEnable = bitRead(commandState,4);
    brainTarget = 8*bitRead(commandState,3) + 4*bitRead(commandState,2)+ 2*bitRead(commandState,1) + 1*bitRead(commandState,0);

    xVelHigh  = byte2in;
    xVelLow   = byte3in & 240;
    yVelHigh  = byte3in & 15;
    yVelLow   = byte4in;
    commandXVel = word(xVelHigh, xVelLow);
    commandXVel = commandXVel >> 4;
    commandYVel = word(yVelHigh, yVelLow);  

    gloveState  = byte5in;
    graspInd    = gloveState & 15;

    brainTargetX = brainTargetListX[brainTarget];
    brainTargetY = brainTargetListY[brainTarget];
    brainTargetDist = sqrt((brainTargetX - pos_current(0))*(brainTargetX - pos_current(0)) + (brainTargetY - pos_current(1))*(brainTargetY - pos_current(1)));

    // Set LEDs
    if (controlMode==4){
      if (brainTarget == 0){
        if (brainTargetDist > 50.0) { 
          writeLEDs(255, 0, 255, 255, 0, 255);
        }
        else {            
          writeLEDs(255, 255, 0, 255, 255,0);
        }
      }
      else if (brainTarget < 5){
        if (graspInd){
            writeLEDs(0, 0, 255, 255, 255, 255);
        }
        else{
          if (brainTargetDist > 50.0) { 
            writeLEDs(255, 0, 255, 255, 255, 255);
          }
          else {
            writeLEDs(255, 255, 0, 255, 255, 255);      
          }
        }
      }
      else{
        if (graspInd){
          writeLEDs(255, 255, 255, 0, 0, 255);
        }
        else{   
          if (brainTargetDist > 50.0) {
            writeLEDs(255, 255, 255, 255, 0, 255);
          }
          else {
            writeLEDs(255, 255, 255, 255, 255, 0);
          }
        }
      }
    }
    
    else if (controlMode==15){
      if (brainTarget == 0){
        writeLEDs(0, 255, 255, 0, 255, 255);
      }
      else if (brainTarget < 5){
        writeLEDs(255, 0, 255, 255, 255, 255);
      }
      else{
        writeLEDs(255, 255, 255, 0, 255, 255);
      }
    }
    else {
      writeLEDs(255, 255, 255, 255, 255, 255);
    }
    
    // Move Planar to Position
    if (!velEnable & planarBrainEnable & bbsEnable){     
    if ((brainTargetDist > 20) & !brainTargetMoving )
    {
      brainTargetMoving = 1;
      controlMode = 15;
      mj_p        = 0;
      mjTarX      = brainTargetX;
      mjTarY      = brainTargetY;
      mjDur       = brainTargetDist/20.0;  
      mjGoalMet   = 0;
      mjInitX     = pos_current(0);
      mjInitY     = pos_current(1);
      mjInitT     = millis();
    }
  }
  }
}

void writeLEDs(int r1, int g1, int b1, int r2, int g2, int b2){
  analogWrite(pinLED1r, r1);
  analogWrite(pinLED1g, g1);
  analogWrite(pinLED1b, b1);  

  analogWrite(pinLED2r, r2);
  analogWrite(pinLED2g, g2);
  analogWrite(pinLED2b, b2);  
}

void writePos2Brain(){
  sentXPos = map(pos_current(0), -300, 300, 0, 4095);
  sentYPos = map(pos_current(1), -300, 300, 0, 4095);

  sentXForce = map(estForce(0, 0), -40, 40, 0, 4095);
  sentYForce = map(estForce(0, 1), -40, 40, 0, 4095);

  word xPos   = sentXPos;
  word yPos   = sentYPos;
  xPos        = xPos << 4;

  word xForce   = sentXForce;
  word yForce   = sentYForce;
  xForce        = xForce << 4;

  commandStatePlanar   = 0;
  bitWrite(commandStatePlanar, 5, planarBrainEnable);
  byte1out   = commandStatePlanar; 
  byte2out   = highByte(xPos);
  byte3out   = highByte(yPos) | lowByte(xPos);
  byte4out   = lowByte(yPos);
  byte5out   = highByte(xForce);
  byte6out   = highByte(yForce) | lowByte(xForce);
  byte7out   = lowByte(yForce);

  Wire.beginTransmission(1);  // BBS is on I2C0 as device 8
  Wire.write(byte1out);   
  Wire.write(byte2out);   
  Wire.write(byte3out);   
  Wire.write(byte4out);  
  //Wire.write(byte5out);   
  //Wire.write(byte6out);   
  //Wire.write(byte7out);  
  Wire.endTransmission();     // stop transmitting
}

void readForce()
{
  obsForce(0, 0) = scaleX.get_units() * 9.81;
  obsForce(0, 1) = -scaleY.get_units() * 9.81;
  if ((abs(obsForce(0, 0)) < 30) && (abs(obsForce(1, 0)) < 30) && (abs(obsForce(0, 0) - obsForce_old(0, 0)) < 2) && (abs(obsForce(1, 0) - obsForce_old(1, 0)) < 2)) {
    //Predict
    estForcePrior   = estForce;
    estForcePPrior  = estForceP + QForce;

    //Update
    innoForce   = obsForce - estForcePrior;
    SForce      = RForce + estForcePPrior;
    KForce      = estForcePPrior * SForce.Inverse();
    estForce    = estForcePrior + KForce * innoForce;
    estForceP   = (eye2 - KForce) * estForcePPrior * ~(eye2 - KForce) + KForce * RForce * ~KForce;

    senAngle    = atan2(-estForce(0, 0), estForce(0, 1)) / PI * 180;
    senForce    = sqrt(estForce(0, 0) * estForce(0, 0) + estForce(1, 0) * estForce(1, 0));
  }
  obsForce_old = obsForce;

  if (FF_status){
    estForce(0,0) = estForce(0,0) + f_a*vel_current(1) +f_b*pos_current(0) +  f_c;
    estForce(0,1) = estForce(0,1) + f_d*vel_current(0) +f_e*pos_current(0) +  f_f;
  }

//  totForce = sqrt(obsForce(0,0)*obsForce(0,0) + obsForce(0,1)*obsForce(0,1));
  if (senForce > 30){
  digitalWrite(pinBeep, HIGH);
  }
  else{
    digitalWrite(pinBeep, LOW);
  }
}


void readEncoderMotorLeft() {
  
  MA3VoltageNewLeft = ads.readADC_SingleEnded(1);

  if (MA3VoltageNewLeft - MA3VoltageOldLeft  < -830) {
    revLeft++;
  } else if (MA3VoltageNewLeft  - MA3VoltageOldLeft > 830) {
    revLeft--;
  }
  MA3VoltageOldLeft = MA3VoltageNewLeft;
  MA3DegLeft = MA3VoltageNewLeft / 1660.0 * 360.0 + revLeft * 360.0;

  encoderMotorLeftAngle = MA3DegLeft + MA3OffsetLeft;
}

void readEncoderMotorRight() {
  MA3VoltageNewRight = ads.readADC_SingleEnded(0);

  if (MA3VoltageNewRight - MA3VoltageOldRight  < -830) {
    revRight++;
  } else if (MA3VoltageNewRight  - MA3VoltageOldRight > 830) {
    revRight--;
  }
  MA3VoltageOldRight = MA3VoltageNewRight;
  MA3DegRight = MA3VoltageNewRight / 1660.0 * 360.0 + revRight * 360.0;

  encoderMotorRightAngle = MA3DegRight + MA3OffsetRight;
}

//
//// Read MA3 Encoders
//void readEncoderMotorLeft() {
//  MA3VoltageNewLeft = analogRead(pinEncoderMotorLeft);
//  MA3VoltageNewLeft = analogRead(pinEncoderMotorLeft);
//  if (MA3VoltageNewLeft - MA3VoltageOldLeft  < -512) {
//    revLeft++;
//  } else if (MA3VoltageNewLeft  - MA3VoltageOldLeft > 512) {
//    revLeft--;
//  }
//  MA3VoltageOldLeft = MA3VoltageNewLeft;
//  MA3DegLeft = MA3VoltageNewLeft / 1023.0 * 360.0 + revLeft * 360.0;
//
//  encoderMotorLeftAngle = MA3DegLeft + MA3OffsetLeft;
//}
//void readEncoderMotorRight()
//{
//  MA3VoltageNewRight = analogRead(pinEncoderMotorRight);
//  MA3VoltageNewRight = analogRead(pinEncoderMotorRight);
//  if (MA3VoltageNewRight - MA3VoltageOldRight  < -512) {
//    revRight++;
//  } else if (MA3VoltageNewRight  - MA3VoltageOldRight > 512) {
//    revRight--;
//  }
//  MA3VoltageOldRight = MA3VoltageNewRight;
//  MA3DegRight = MA3VoltageNewRight / 1023.0 * 360.0 + revRight * 360.0;
//
//  encoderMotorRightAngle = MA3DegRight + MA3OffsetRight;
//}

void readLimitSwitches() {
  stateLimitLT  = digitalRead(pinLimitLT);
  stateLimitLM  = digitalRead(pinLimitLM);
  stateLimitLB  = digitalRead(pinLimitLB);
  stateLimitRT  = digitalRead(pinLimitRT);
  stateLimitRM  = digitalRead(pinLimitRM);
  stateLimitRB  = digitalRead(pinLimitRB);
}

void readAtari() {
  atariDir     = 0;
  atariButton = digitalRead(pinAtariButton);

  if (digitalRead(pinAtariLeft)) {
    atariDir = 3; // WEST
  }
  if (digitalRead(pinAtariRight)) {
    atariDir = 7; // EAST
  }

  if (digitalRead(pinAtariUp)) {
    atariDir = 1; // NORTH
    if (digitalRead(pinAtariLeft)) {
      atariDir = 2; // NORTH WEST
    }
    if (digitalRead(pinAtariRight)) {
      atariDir = 8; // NORTH EAST
    }
  }

  if (digitalRead(pinAtariDown)) {
    atariDir = 5; // SOUTH
    if (digitalRead(pinAtariLeft)) {
      atariDir = 4; // SOUTH WEST
    }
    if (digitalRead(pinAtariRight)) {
      atariDir = 6; // SOUTH EAST
    }
  }
  if (digitalRead(pinAtariUp) && digitalRead(pinAtariLeft) && digitalRead(pinAtariDown) && digitalRead(pinAtariRight)) {
    atariDir = 9; // HULK SMASH
  }
}

// Write to motor teensy
void writeMotors() {
  digitalWrite(pinM1Dir, M1Dir);
  digitalWrite(pinM2Dir, !M2Dir);
  
  h1 = highByte(M1Pwm);
  u1 = lowByte(M1Pwm);
  h2 = highByte(M2Pwm);
  u2 = lowByte(M2Pwm);
  
  Wire.beginTransmission(7); // transmit to device #8
  Wire.write(h1);              // sends one byte
  Wire.write(u1);              // sends one byte
  Wire.write(h2);              // sends one byte
  Wire.write(u2);              // sends one byte
  Wire.endTransmission();    // stop transmitting
}

double XYToS0(double x, double y) {
  return (x - y) / (DIAMETER * PI) * 360.0;
}

double XYToS1(double x, double y) {
  return (x + y) / (DIAMETER * PI) * 360.0;
}

double SToX(double s0, double s1) {
  return -(s0 + s1) * (DIAMETER * PI) / 360.0 / 2.0;
}

double SToY(double s0 , double s1) {
  return -(s1 - s0) * (DIAMETER * PI) / 360.0 / 2.0;
}

void speedToPWM(long omega1, long omega2) {
  float omegaAbs1 = abs(omega1);
  float omegaAbs2 = abs(omega2);
  if (omegaAbs1 >= 430) {
    M1Pwm = 65535.0;
    M2Pwm = omegaAbs2 / omegaAbs1 * 65535.0;
  }
  else if (omegaAbs2 >= 430) {
    M2Pwm = 65535.0;
    M1Pwm = omegaAbs1 / omegaAbs2 * 65535.0;
  }
  else {
    M1Pwm = 65535.0 / 430.0 * omegaAbs1;
    M2Pwm = 65535.0 / 430.0 * omegaAbs2;
  }

  if (omega1 >= 0) {
    M1Dir  = HIGH;
  } else {
    M1Dir  = LOW;
  }
  if (omega2 >= 0) {
    M2Dir  = LOW;
  } else {
    M2Dir  = HIGH;
  }
}

// Functions for IO
void recvWithEndMarker() {
  static byte ndx = 0;
  char endMarker = '\n';
  char rc;

  while (Serial.available() > 0 && newData == false) {
    rc = Serial.read();
    if (rc != endMarker) {
      receivedChars[ndx] = rc;
      ndx++;
      if (ndx >= numChars) {
        ndx = numChars - 1;
      }
    }
    else
    {
      receivedChars[ndx] = '\0'; // terminate the string
      ndx = 0;
      newData = true;
    }
  }
  Serial.flush();
}

void setH() {
  pos_goal(0) = coordHome(0);
  pos_goal(1) = coordHome(1);
  goal = 0;
}
void setI() {
  pos_goal(0) = coordInitHome(0);
  pos_goal(1) = coordInitHome(1);
  goal = 0;
}
void set1() {
  goal = 1;
  pos_goal(0) = coordEast(0);
  pos_goal(1) = coordEast(1);
}
void set2() {
  goal = 2;
  pos_goal(0) = coordENE(0);
  pos_goal(1) = coordENE(1);
}
void set3() {
  goal = 3;
  pos_goal(0) = coordNorthEast(0);
  pos_goal(1) = coordNorthEast(1);
}
void set4() {
  goal = 4;
  pos_goal(0) = coordNNE(0);
  pos_goal(1) = coordNNE(1);
}
void set5() {
  goal = 5;
  pos_goal(0) = coordNorth(0);
  pos_goal(1) = coordNorth(1);
}
void set6() {
  goal = 6;
  pos_goal(0) = coordNNW(0);
  pos_goal(1) = coordNNW(1);
}
void set7() {
  goal = 7;
  pos_goal(0) = coordNorthWest(0);
  pos_goal(1) = coordNorthWest(1);
}
void set8() {
  goal = 8;
  pos_goal(0) = coordWNW(0);
  pos_goal(1) = coordWNW(1);
}
void set9() {
  goal = 9;
  pos_goal(0) = coordWest(0);
  pos_goal(1) = coordWest(1);
}

void zeroGoalState() {
  goalM1Deg = XYToS0(pos_goal(0), pos_goal(1));
  goalM2Deg = XYToS1(pos_goal(0), pos_goal(1));
  goalMet = 0;
  goalHeading = (atan2( pos_current(0) - pos_goal(0), pos_goal(1) - pos_current(1)) * 4068) / 71 ;
  initDistHeading = sqrt((pos_current(0) - pos_goal(0)) * (pos_current(0) - pos_goal(0)) + (pos_goal(1) - pos_current(1)) * (pos_goal(1) - pos_current(1)));
  errX       = pos_goal(0) - pos_current(0);
  errY       = pos_goal(1) - pos_current(1);
  errXYratio = errX / errY;
}

void showNewData() {
  if (newData == true) {
    planarBrainEnable = 0;
    switch (receivedChars[0]) {
      case 'H':
        setH();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '1':
        set1();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '2':
        set2();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '3':
        set3();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '4':
        set4();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '5':
        set5();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '6':
        set6();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '7':
        set7();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '8':
        set8();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;
      case '9':
        set9();
        zeroGoalState();
        pos_start = pos_current;
        vel_current.Fill(0);
        break;

      case 'X':
        controlMode         = 4;
        planarBrainEnable   = 1;
        break;

      case 'J':
        controlMode         = 3;
        break;

      case 'A':
        scaleX.set_scale(450000.f);   // this value is obtained by calibrating the scale with known weights; see the README for details
        scaleX.tare();              // reset the scale to 0
        scaleY.set_scale(450000.f);  // this value is obtained by calibrating the scale with known weights; see the README for details
        scaleY.tare();
        controlMode         = 2;
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        k_mass  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        k_visco  = inString.toFloat();
        break;

      case 'E':
        maxFEex = -600.0;
        maxFEfy = 600.0;
        scaleX.set_scale(450000.f);   // this value is obtained by calibrating the scale with known weights; see the README for details
        scaleX.tare();              // reset the scale to 0
        scaleY.set_scale(450000.f);  // this value is obtained by calibrating the scale with known weights; see the README for details
        scaleY.tare();

        controlMode         = 8;

        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        k_mass  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        k_visco  = inString.toFloat();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        circX   = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        circY  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        a   = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        b  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        circDir  = inString.toInt();
        x = pos_current(0);
        y = pos_current(1);
        
        circRadius  = sqrt((x - circX) * (x - circX) + (y  - circY)* (y - circY));
        break;

      case 'T':
        controlMode = 1;
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        setCtrlV  = inString.toInt();
        break;

      case 'Z':
        zeroEncoders();
      break;
      
      case 'S':
        controlMode = 7;
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        setCtrlV    = inString.toInt();
        inString = "";

        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        k_spring   = inString.toFloat();

        x = pos_current(0);
        y = pos_current(1);
        circRadius  = sqrt(x * x + y * y);
        
        break;

case 'O':
        maxFEex = 1000;
        maxFEfy = -1000;
        controlMode = 7;
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        setCtrlV    = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        circX   = inString.toInt();

        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        circY  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        a   = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        b  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        circDir  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        e_k  = inString.toInt();


        x = pos_current(0);
        y = pos_current(1);
        circRadius  = sqrt((x - circX) * (x - circX) + (y  - circY)* (y - circY));

        break;

      case 'U':
        controlMode = 6;
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        mjTarX    = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        mjTarY  = inString.toInt();

        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        mjDur  = inString.toInt();
        inString = "";
        ndxRead ++;
          while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        mj_p = inString.toInt();
        mjInitX = pos_current(0);
        mjInitY = pos_current(1);
        mjInitT = millis();
        break;

      case 'C':
        controlMode = 5;
        break;

      case 'K':
        scaleX.set_scale(450000.f);   // this value is obtained by calibrating the scale with known weights; see the README for details
        scaleX.tare();              // reset the scale to 0
        scaleY.set_scale(441240.f);  // this value is obtained by calibrating the scale with known weights; see the README for details
        scaleY.tare();
        break;

      // Linear Map
      case 'M':
        controlMode = 27;
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        mapCtrlV    = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        mapDir  = inString.toInt();
        break;

      case 'L':
        controlMode         = 9;
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[0]   = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[1]  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[2]  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[3]  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[4]  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[5]  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[6]  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[7]  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[8]  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        coordRadius[9]  = inString.toInt();
        break;

      case 'G':
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        rightHand   = inString.toInt();
        break;
  
      case 'I':   //Set Forcefield
        ndxRead = 2;
        inString = "";
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        FF_status  = inString.toInt();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        f_a  = inString.toFloat();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        f_b  = inString.toFloat();
        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        f_c  = inString.toFloat();

        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        f_d  = inString.toFloat();

        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        f_e  = inString.toFloat();

        inString = "";
        ndxRead ++;
        while (receivedChars[ndxRead] != ',') {
          inString += (char)receivedChars[ndxRead];
          ndxRead ++;
        }
        f_f  = inString.toFloat();
        
  
      case 'W':
        coordRadius[0] = 330;
        coordRadius[1] = 350;
        coordRadius[2] = 300;
        coordRadius[3] = 260;
        coordRadius[4] = 240;
        coordRadius[5] = 260;
        coordRadius[6] = 300;
        coordRadius[7] = 350;
        coordRadius[8] = 330;
        setCoords();
        break;
    }

    BNCval = HIGH;
    digitalWrite(pinPlanarPulse, BNCval);
    newData = false;
  }
}

void updateRotMatrix(float Angle){
  rotMatrix << cos(Angle), -sin(Angle), sin(Angle), cos(Angle);
}


void controlMotorAngles_3(int ctrlV) {
  errX       = pos_goal(0) - pos_current(0);
  errY       = pos_goal(1) - pos_current(1);
  errXYratio = errX / errY;
  errTotal   = abs(errX) + abs(errY);

  if (goalMet == 0) {
    if (errTotal >  30) {
      rVel = rVel + ramp;
      posCtrlV = min(rVel, ctrlV);
      posCtrlV = ctrlV;
      if (abs(errY ) < 0.5) {
        vel_update(0) = sign(errX) * posCtrlV;
        vel_update(1) = 0;
      }
      else {
        vel_update(1) = sign(errY) * abs(posCtrlV / (sqrt(1 + errXYratio * errXYratio)));
        vel_update(0) = sign(errX) * abs(errXYratio * vel_update(1));
      }
      // Compute steady-state force
      if (ctrlV < rVel) {
        fAxialSum = fAxialSum + fAxial;
        countSteady++;
      }
    }
    else if (errTotal > 5) {
      if (posCtrlV > 30) {
        posCtrlV  = 0.9 * posCtrlV;
      }
      if (abs(errY ) < 0.5) {
        vel_update(0) = sign(errX) * posCtrlV;
        vel_update(1) = 0;
      }
      else {
        vel_update(1) = sign(errY) * abs(posCtrlV / (sqrt(1 + errXYratio * errXYratio)));
        vel_update(0) = sign(errX) * abs(errXYratio * vel_update(1));
      }
    }
    else {
      vel_update(0)   = 0;
      vel_update(1)   = 0;
      rVel            = 50.0;
      goalMet         = 1;
      delayTime = millis();
      forceLim = 0;
    }
  }
  speedToPWM(XYToS0(vel_update(0), vel_update(1)), XYToS1(vel_update(0), vel_update(1)));
      writeMotors();

  pos_current(0) = SToX(encoderMotorLeftAngle, encoderMotorRightAngle);
  pos_current(1) = SToY(encoderMotorLeftAngle, encoderMotorRightAngle);

  vel_current = vel_update;
}

void zeroEncoders() {
  readEncoderMotorLeft();
  readEncoderMotorRight();
  MA3OffsetLeft = -MA3DegLeft;
  MA3OffsetRight = -MA3DegRight;
}

int sign(float value) {
  return (value > 0) - (value < 0);
}

float norm(BLA::Matrix<2, 1> v) {
  return sqrt(v(0) * v(0) + v(1) * v(1));
}

void circAdm() {
  force_current(0)   = estForce(0, 0);
  force_current(1)   = estForce(1, 0);

  //  totForce = sqrt(force_current(0)* force_current(0)  + force_current(1)*force_current(1)) ;
  
  x = pos_current(0) - circX;
  y = pos_current(1) - circY;
  
  ellipseRadius = sqrt(x*x*b*b*b*b + y*y*a*a*a*a);

  tanvx = -y*a*a/ellipseRadius;
  tanvy = x*b*b/ellipseRadius;

  normvx = x*b*b/ellipseRadius;
  normvy = y*a*a/ellipseRadius;

  fh_tan = force_current(0) * tanvx + force_current(1) * tanvy;      
  fh_norm = force_current(0) * normvx + force_current(1) * normvy;  

  e_x = sign(x)*a*b*abs(x)/(sqrt(a*a*y*y + b*b*x*x));
  e_y = sign(y)*a*b*abs(y)/(sqrt(a*a*y*y + b*b*x*x));
  e_r_pred = sqrt(e_x*e_x + e_y*e_y);
  e_r_obs = sqrt(x*x + y*y);
  norm_err =  e_r_pred - e_r_obs;
  
  vel_current_tan = vel_current(0)*tanvx + vel_current(1)*tanvy;
  vel_current_norm = vel_current(0)*normvx + vel_current(1)*normvy;

  
  if ((abs(force_current(0)) > 0.25) || (abs(force_current(1)) > 0.25)) {
//    vel_update =  vel_update + vel_current * (k_visco)  // Viscosity update
//                  + force_current * (k_dt * k_mass);     // Force update
      vel_tan = fh_tan * (k_dt * k_mass) +  vel_current_tan * k_visco;
      vel_norm = fh_norm * (k_dt * k_mass) +  vel_current_norm * k_visco + k_spring * k_dt * k_mass * norm_err;  


      vel_update(0) = vel_tan*tanvx + vel_norm*normvx;
      vel_update(1) = vel_tan*tanvy + vel_norm*normvy;
       
  }
  else {
    vel_update = {0, 0};
  }
}

void updateCircle() {

    x = pos_current(0) - circX;
    y = pos_current(1) - circY;

    e_r_obs = sqrt(x*x + y*y);
    e_x = sign(x)*a*b*abs(x)/(sqrt(a*a*y*y + b*b*x*x));
    e_y = sign(y)*a*b*abs(y)/(sqrt(a*a*y*y + b*b*x*x));
    e_r_pred = sqrt(e_x*e_x + e_y*e_y);

    rad_err =  e_r_pred - e_r_obs;

    circRadius = sqrt(x*x*b*b*b*b + y*y*a*a*a*a);
    
    norm_velx = x * b*b/circRadius * rad_err*e_k;
    norm_vely = y*a*a /circRadius * rad_err*e_k;    


if (circDir == 1) {
    vel_update(0) = y * a*a / circRadius * setCtrlV + norm_velx;
    vel_update(1) = -x * b*b / circRadius * setCtrlV + norm_vely;

//    fAxial = (estForce(0, 0) * y + estForce(1, 0) * -x) / (abs(x) + abs(y));
//
//    if (pos_current(0) > maxFEex){
//      vel_update(0) = 0;
//      vel_update(1) = 0;
//    }
  }
  else
  {
    vel_update(0) = -y*a*a /  circRadius * setCtrlV + norm_velx;
    vel_update(1) = x*b*b /  circRadius * setCtrlV + norm_vely;
    
//    fAxial = (estForce(0, 0) * -y + estForce(1, 0) * x) / (abs(x) + abs(y));
//    if (pos_current(1) < maxFEfy) {
//      vel_update(0) = 0;
//      vel_update(1) = 0;
//    }
  }
}

void updateMJ() {
  mjT = (millis() - mjInitT) / 1000;
  mj_predX = mjInitX + (mjTarX - mjInitX)*(10 * (mjT / mjDur)*(mjT / mjDur)*  (mjT / mjDur) - 15*(mjT / mjDur)* (mjT / mjDur)* (mjT / mjDur)* (mjT / mjDur) + 6*  (mjT / mjDur)* (mjT / mjDur)* (mjT / mjDur)* (mjT / mjDur)* (mjT / mjDur));

  if (mjT < mjDur) {
   mj_errX = mj_predX - pos_current(0);
   mj_errY = mj_predY - pos_current(1);
    
    vel_update(0) = (mjTarX - mjInitX) * (30 * (mjT / mjDur) * (mjT / mjDur) * (1 / mjDur) - 60 * (mjT / mjDur) * (mjT / mjDur) * (mjT / mjDur) * (1 / mjDur) + 30 * (mjT / mjDur) * (mjT / mjDur) * (mjT / mjDur) * (mjT / mjDur) * (1 / mjDur));
    vel_update(1) = (mjTarY - mjInitY) * (30 * (mjT / mjDur) * (mjT / mjDur) * (1 / mjDur) - 60 * (mjT / mjDur) * (mjT / mjDur) * (mjT / mjDur) * (1 / mjDur) + 30 * (mjT / mjDur) * (mjT / mjDur) * (mjT / mjDur) * (mjT / mjDur) * (1 / mjDur));
    vel_update(0) = mj_p*mj_errX + vel_update(0);
    vel_update(1) = mj_p*mj_errY + vel_update(1);    
  }
  else {
    vel_update(0) = 0;
    vel_update(1) = 0;
    mjGoalMet = 1;
  }
}

void updateAdmittance() {
  force_current(0)   = estForce(0, 0);
  force_current(1)   = estForce(1, 0);

  pos_goalU   = (pos_goal - pos_start) / norm(pos_goal - pos_start);
  pos_goaldU  = (pos_goal - pos_current) / norm(pos_goal - pos_current);

  vel_update.Fill(0);
  //  vel_update  = (pos_goalU * (~(pos_current - pos_start) * (pos_goalU))       // Stabaliser
  //                 - (pos_current - pos_start)) * (k_dt * k_stable * k_mass);
  //
  //  if (norm(pos_goal - pos_current) > 25)
  //  {
  //    vel_update = vel_update + pos_goaldU * (k_dt * k_attract * k_mass);      // Attractor
  //  } else {
  //  }

  if ((abs(force_current(0)) > 0.25) || (abs(force_current(1)) > 0.25)) {
    vel_update =  vel_update + vel_current * (k_visco)  // Viscosity update
                  + force_current * (k_dt * k_mass);     // Force update
  }
  else {
    vel_update = {0, 0};
  }
}

void safetyLimits() {
  if (stateLimitLM) {
    if (vel_update(0) < 0) {
      vel_update(0) = 0;
    }
  }
  if (stateLimitRM) {
    if (vel_update(0) > 0) {
      vel_update(0) = 0;
    }
  }
  if (stateLimitLB && stateLimitRB) {
    if (vel_update(1) < 0) {
      vel_update(1) = 0;
    }
  }
  if (stateLimitLT && stateLimitRT) {
    if (vel_update(1) > 0) {
      vel_update(1) = 0;
    }
  }

  if ((pos_current(0) - safety_lowerX) < safety_bound && vel_update(0) < 0) {
    vel_update(0) = 30 * ((safety_lowerX - pos_current(0) ) / safety_bound);
  }
  else if ((safety_upperX - pos_current(0)) < safety_bound && vel_update(0) > 0) {
    vel_update(0) = 30 * ((safety_upperX - pos_current(0)) / safety_bound);
  }
  if ((pos_current(1) - safety_lowerY) < safety_bound && vel_update(1) < 0) {
    vel_update(1) = 30 * ((safety_lowerY - pos_current(1)) / safety_bound);
  }
  else if ((safety_upperY - pos_current(1)) < safety_bound && vel_update(1) > 0) {
    vel_update(1) = 30 * ((safety_upperY - pos_current(1)) / safety_bound);
  }
}

void setCoords() {
  if (coordRadius[0] > 330) {
    coordRadius[0] = 330;
  }
  if (coordRadius[1] > 340) {
    coordRadius[1] = 340;
  }
  if (coordRadius[2] > 340) {
    coordRadius[2] = 340;
  }
  if (coordRadius[3] > 250) {
    coordRadius[3] = 250;
  }
  if (coordRadius[4] > 230) {
    coordRadius[4] = 230;
  }
  if (coordRadius[5] > 250) {
    coordRadius[5] = 250;
  }
  if (coordRadius[6] > 340) {
    coordRadius[6] = 340;
  }
  if (coordRadius[7] > 340) {
    coordRadius[7] = 340;
  }
  if (coordRadius[8] > 330) {
    coordRadius[8] = 330;
  }

  coordEast << 0, coordRadius[0];
  updateRotMatrix(-PI / 2);
  coordEast = rotMatrix * coordEast + coordHome;

  coordNorthEast << 0, coordRadius[2];
  updateRotMatrix(-PI / 4);
  coordNorthEast = rotMatrix * coordNorthEast + coordHome;

  coordNNE << 0, coordRadius[3];
  updateRotMatrix(-PI / 8);
  coordNNE = rotMatrix * coordNNE + coordHome;

  coordENE << 0, coordRadius[1];
  updateRotMatrix(-3 * PI / 8);
  coordENE = rotMatrix * coordENE + coordHome;

  coordNorth << 0, coordRadius[4];
  updateRotMatrix(0);
  coordNorth = rotMatrix * coordNorth + coordHome;

  coordNorthWest << 0, coordRadius[6];
  updateRotMatrix(PI / 4);
  coordNorthWest = rotMatrix * coordNorthWest + coordHome;

  coordWest << 0, coordRadius[8];
  updateRotMatrix(PI / 2);
  coordWest = rotMatrix * coordWest + coordHome;

  coordNNW << 0, coordRadius[5];
  updateRotMatrix(PI / 8);
  coordNNW = rotMatrix * coordNNW + coordHome;

  coordWNW << 0, coordRadius[7];
  updateRotMatrix(3 * PI / 8);
  coordWNW = rotMatrix * coordWNW + coordHome;
}

void calibrate() {
  // Moves planar stage to left edge, then to bottom edge
  // Zeros the encoders

  int calibVel = 50;

  vel_update(0) = -calibVel;
  vel_update(1) = 0;

  //  Move left;

  speedToPWM(XYToS0(vel_update(0), vel_update(1)), XYToS1(vel_update(0), vel_update(1)));
      writeMotors();

  while (digitalRead(pinLimitLM) != HIGH) {
    delay(10);
    serialPrint();
  }

  disengageMotors();
  delay(100);

  //  Back off from wall
  vel_update(0) = calibVel;
  vel_update(1) = 0;
  speedToPWM(XYToS0(vel_update(0), vel_update(1)), XYToS1(vel_update(0), vel_update(1)));
      writeMotors();
  delay(500);
  disengageMotors();
  delay(500);
  //Move down until limit
  vel_update(0) = 0;
  vel_update(1) = -calibVel;
  speedToPWM(XYToS0(vel_update(0), vel_update(1)), XYToS1(vel_update(0), vel_update(1)));
      writeMotors();
  while (digitalRead(pinLimitLB) != HIGH) {
    serialPrint();
    delay(10);
  }

  disengageMotors();
  delay(100);

  //  Back off from wall
  vel_update(0) = 0;
  vel_update(1) = calibVel;
  speedToPWM(XYToS0(vel_update(0), vel_update(1)), XYToS1(vel_update(0), vel_update(1)));
      writeMotors();
  delay(100);

  disengageMotors();
  delay(500);
  zeroEncoders();

  setI();
  zeroGoalState();

  while (goalMet == 0) {
    serialPrint();

    controlMotorAngles_3(calibVel);
    readEncoderMotorLeft();
    readEncoderMotorRight();
    pos_current(0) = SToX(encoderMotorLeftAngle, encoderMotorRightAngle);
    pos_current(1) = SToY(encoderMotorLeftAngle, encoderMotorRightAngle);
  }

  vel_update(0) = 0;
  vel_update(1) = -30;
  speedToPWM(XYToS0(vel_update(0), vel_update(1)), XYToS1(vel_update(0), vel_update(1)));
      writeMotors();
      
  while (digitalRead(pinLimitRB) != HIGH) {
    serialPrint();
    delay(10);
  }

  disengageMotors();
  delay(50);
  zeroEncoders();

  pos_goal(0) = 0;
  pos_goal(1) = 15.0;
  zeroGoalState();
  while (goalMet == 0) {
    serialPrint();
    controlMotorAngles_3(30);
    readEncoderMotorLeft();
    readEncoderMotorRight();
    pos_current(0) = SToX(encoderMotorLeftAngle, encoderMotorRightAngle);
    pos_current(1) = SToY(encoderMotorLeftAngle, encoderMotorRightAngle);
  }

  disengageMotors();
  delay(50);
  zeroEncoders();
  controlMode = 'N';
}

void disengageMotors() {
  vel_update(0) = 0;
  vel_update(1) = 0;

  //  Move left;
  speedToPWM(XYToS0(vel_update(0), vel_update(1)), XYToS1(vel_update(0), vel_update(1)));
      writeMotors();
}

void serialPrint()
{
  Serial.print(millis());
  Serial.print(',');
  Serial.print(controlMode);
  Serial.print(',');
//  Serial.print(MA3VoltageNewLeft);
//  Serial.print(',');
//  Serial.print(MA3VoltageNewRight);
//  Serial.print(',');
//  Serial.print(encoderMotorLeftAngle);
//    Serial.print(',');
//  Serial.print(encoderMotorRightAngle); 
//    Serial.print(','); 
  Serial.print(pos_current(0), 2);
  Serial.print(',');
  Serial.print(pos_current(1), 2);
  Serial.print(',');
  Serial.print(estForce(0, 0), 2);
  Serial.print(',');
  Serial.print(estForce(0, 1), 2);
  Serial.print(',');
  Serial.print(sentXPos);
  Serial.print(',');
  Serial.print(sentYPos);
  Serial.print(',');
//  Serial.print(sentXForce);
//  Serial.print(',');
//  Serial.print(sentYForce);
//  Serial.print(',');
  Serial.print(vel_update(0), 2);
  Serial.print(',');
  Serial.print(vel_update(1), 2);
  Serial.print(',');

//  Serial.print(commandXVel);
//  Serial.print(',');
//  Serial.print(commandYVel);
//  Serial.print(','); 
  Serial.print(BNCval);
//  Serial.print(',');   
//  Serial.print(e_theta);
//  Serial.print(',');
//  Serial.print(e_r_obs);
//  Serial.print(',');  
//  Serial.print(e_r_pred);
//  Serial.print(',');
//  Serial.print(e_x);
//  Serial.print(',');  
//  Serial.print(e_y);
//  Serial.print(',');    
//  Serial.print(rad_err);
//  Serial.print(',');
//  Serial.print(norm_velx);
//  Serial.print(',');
//  Serial.print(norm_vely);
//  Serial.print(triggerIn);
//  Serial.print(',');
//  Serial.print(commandState, BIN);
//  Serial.print(',');
//  Serial.print(bbsEnable);
//  Serial.print(',');
//  Serial.print(velEnable);
//  Serial.print(',');
//  Serial.print(planarBrainEnable);
//  Serial.print(',');
//  Serial.print(brainTarget);
//  Serial.print(',');
//  Serial.print(brainTargetX);
//  Serial.print(',');
//  Serial.print(brainTargetY);
//    Serial.print(',');
//  Serial.print(brainTargetDist);
//  Serial.print(',');
//    Serial.print(brainTargetMoving);
  Serial.println();
}

