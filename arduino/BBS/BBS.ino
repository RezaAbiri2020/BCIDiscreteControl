/* Use a Teensy 3.5 as a message handler between the Brain Box Master and the Planar Master
 * Messages are sent as 4 bytes, with the first byte corresponding to a command, and the 
 * remaining 3 bytes as a message of commanded velocity or planar position based on the 
 * direction of the message.
 * 
 * 20190422 RPMatthew
 */

#include <Wire.h>

// Planar inputs
volatile int planarMode     = 0;    // Contains:
  volatile bool planarEnable  = 0;    // bit 5
  volatile bool planarVelMode = 0;    // bit 4
  volatile int planarTarget   = 0;    // 0 to 15
volatile word planarVelX    = 2047; // 0 to 4095
volatile word planarVelY    = 2047; // 0 to 4095

// Planar Outputs 
volatile int planarStatus   = 0;    // Contains:
  volatile int planarReady  = 0;    // bit 5
volatile word planarPosX    = 0;    // 0 to 4095
volatile word planarPosY    = 0;    // 0 to 4095
volatile word planarForceX  = 0;    // 0 to 4095
volatile word planarForceY  = 0;    // 0 to 4095


// Glove Inputs
volatile int gloveMode     = 0;    // Contains:
  volatile bool gloveEnable  = 0;    // bit 5
  volatile bool gloveAdmMode = 0;    // bit 4
  volatile int gloveTarget   = 0;    // 0 to 15
  
// Glove Outputs 
volatile int gloveStatus    = 0;    // Contains:
  volatile int gloveReady     = 0;    // bit 5
volatile word glovePos      = 0;    // 0 to 4095
volatile word gloveForce    = 0;    // 0 to 4095



void setup() {
  Wire.begin(1);                // Planar is on I2C0 as device 8
  Wire.onReceive(rxPlanar);
  Wire.onRequest(txPlanar);

  Wire1.begin(1);               // BrainBox is on I2C1 as device 1
  Wire1.onReceive(rxBrain);
  Wire1.onRequest(txBrain);

  Wire2.begin(1);               // Glove is on I2C2 as device 1
  Wire2.onReceive(rxGlove);
  Wire2.onRequest(txGlove);

  Serial.begin(115200);         // start serial for output
}

void loop() {
  // Barf current BBS states  
  Serial.print("Planar: Enbl: ");
  Serial.print(planarEnable);
  Serial.print(" Vel: ");
  Serial.print(planarVelMode);
  Serial.print(" Trgt: ");
  Serial.print(planarTarget);
  Serial.print(" Vel: (");
  Serial.print(planarVelX);
  Serial.print(",");
  Serial.print(planarVelY);
  Serial.print(") | Rdy: ");
  Serial.print(planarReady);
  Serial.print(" Pos: (");
  Serial.print(planarPosX);
  Serial.print(",");
  Serial.print(planarPosY);
  Serial.print(") Force: (");
  Serial.print(planarForceX);
  Serial.print(",");
  Serial.print(planarForceY);
  Serial.print(") || Glove: Enbl: ");
  Serial.print(gloveEnable);
  Serial.print(" Adm: ");
  Serial.print(gloveAdmMode);
  Serial.print(" Trgt: ");
  Serial.print(gloveTarget);
  Serial.print(" | Rdy: ");
  Serial.print(gloveStatus);
  Serial.print(" Pos: ");
  Serial.print(glovePos);
  Serial.print(" Force: ");
  Serial.print(gloveForce);
  Serial.println("");
}

// ========================================================================================================
// Code for Planar Comms
void rxPlanar(int howMany) {
  int numBytes = Wire.available();
  // Serial.println(numBytes);
  if (numBytes == 4)
  {
    byte byte1;   // planarStatus
    byte byte2;   // planarPos
    byte byte3;   // planarPos
    byte byte4;   // planarPos

    // READ COMMAND PACKET & CURRENT POSITIONS FROM PLANAR
    byte1   = Wire.read();
    byte2   = Wire.read();
    byte3   = Wire.read();
    byte4   = Wire.read();

    planarStatus  = byte1;
    planarReady   = bitRead(planarStatus,5);
    
    byte xHigh;
    byte xLow;
    byte yHigh;
    byte yLow;
    xHigh   = byte2;
    xLow    = byte3 & 240;
    yHigh   = byte3 & 15;
    yLow    = byte4;
    planarPosX    = word(xHigh, xLow);
    planarPosX    = planarPosX >> 4;
    planarPosY    = word(yHigh, yLow);
  }
}

void txPlanar() {
  byte byte1;   // planarMode
  byte byte2;   // planarVel
  byte byte3;   // planarVel
  byte byte4;   // planarVel
  byte byte5;   // gloveMode

  word sendXVel;
  word sendYVel;
  sendXVel = planarVelX;
  sendYVel = planarVelY;
  sendXVel = sendXVel << 4;

  // SEND DESIRED VELOCITIES TO PLANAR
  byte1   = planarMode;
  byte2   = highByte(sendXVel);
  byte3   = highByte(sendYVel) | lowByte(sendXVel);
  byte4   = lowByte(sendYVel);
  byte5   = gloveMode;
  
  Wire.write(byte1);
  Wire.write(byte2);
  Wire.write(byte3);
  Wire.write(byte4);
  Wire.write(byte5);
}

// ========================================================================================================
// Code for BrainBox Comms
void rxBrain(int howMany) { 
  if (Wire1.available() == 5)
  {
    // READ DESIRED VELOCITIES FROM BRAIN BOX
    byte byte1;   // planarMode
    byte byte2;   // planarVel
    byte byte3;   // planarVel
    byte byte4;   // planarVel
    byte byte5;   // gloveMode
    byte1   = Wire1.read();
    byte2   = Wire1.read();
    byte3   = Wire1.read();
    byte4   = Wire1.read();
    byte5   = Wire1.read();

    byte xHigh;
    byte xLow;
    byte yHigh;
    byte yLow;
    planarMode    = byte1;
    planarEnable  = bitRead(planarMode,5);    // bit 5
    planarVelMode = bitRead(planarMode,4);    // bit 4
    planarTarget  = byte1 & 15 ;             // 0 to 15
    xHigh         = byte2;
    xLow          = byte3 & 240;
    yHigh         = byte3 & 15;
    yLow          = byte4;
    gloveMode     = byte5;
    gloveEnable   = bitRead(gloveMode,5);    // bit 5
    gloveAdmMode  = bitRead(gloveMode,4);    // bit 4
    gloveTarget   = byte5 & 15 ;             // 0 to 15
    
    planarVelX    = word(xHigh, xLow);
    planarVelX    = planarVelX >> 4;
    planarVelY    = word(yHigh, yLow);
  }
}

void txBrain() {
  byte byte1;   // planarStatus
  byte byte2;   // planarPos
  byte byte3;   // planarPos
  byte byte4;   // planarPos
  
  byte byte5;   // gloveStatus
  byte byte6;   // glovePos
  byte byte7;   // glovePos/Force
  byte byte8;   // gloveForce
  

  
  planarStatus   = 0b00000000;
  bitWrite(planarStatus, 5, planarReady);
  byte1   = planarStatus;
  
  word sendXPos;
  word sendYPos;
  sendXPos  = planarPosX;
  sendYPos  = planarPosY;
  sendXPos  = planarPosX << 4;
  byte2   = highByte(sendXPos);
  byte3   = highByte(sendYPos) | lowByte(sendXPos);
  byte4   = lowByte(sendYPos);



  gloveStatus   = 0b00000000;
  bitWrite(planarStatus, 5, gloveReady);
  byte5     = gloveStatus;
  sendXPos  = glovePos;
  sendYPos  = gloveForce;
  sendXPos  = glovePos << 4;
  byte6     = highByte(sendXPos);
  byte7     = highByte(sendYPos) | lowByte(sendXPos);
  byte8     = lowByte(sendYPos);

  Wire1.write(byte1);
  Wire1.write(byte2);
  Wire1.write(byte3);
  Wire1.write(byte4);
  Wire1.write(byte5);
  Wire1.write(byte6);
  Wire1.write(byte7);
  Wire1.write(byte8);
}

// ========================================================================================================
// Code for Glove Comms
void rxGlove(int howMany) { 
  if (Wire2.available() == 4)
  {
    // READ CURRENT GLOVE STATUS    
    byte byte1;   // gloveStatus
    byte byte2;   // glovePos
    byte byte3;   // glovePos/Force
    byte byte4;   // gloveForce
    byte1   = Wire2.read();
    byte2   = Wire2.read();
    byte3   = Wire2.read();
    byte4   = Wire2.read();
    
    gloveStatus  = byte1;
    gloveReady   = bitRead(gloveStatus,5);    // bit 5

    byte xHigh;
    byte xLow;
    byte yHigh;
    byte yLow;
    xHigh       = byte2;
    xLow        = byte3 & 240;
    yHigh       = byte3 & 15;
    yLow        = byte4;
    glovePos    = word(xHigh, xLow);
    glovePos    = glovePos >> 4;
    gloveForce  = word(yHigh, yLow);
  }
}


void txGlove() {
  byte byte1;   // gloveMode

  // SEND DESIRED COMMANDS TO GLOVE
  byte1   = gloveMode;
  Wire2.write(byte1);
}
