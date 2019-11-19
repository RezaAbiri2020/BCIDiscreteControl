function [Arduino] = UpdateArduino(Arduino)

%% Covert Actual Values into Bytes 
bytePlanarMode  = bitshift(Arduino.planar.enable,5)...
                    + bitshift(Arduino.planar.velocityMode,4)...
                    + bitshift(Arduino.planar.target,0);
bitsPlanarVelX  = round(Arduino.planar.velParams.f_speed2bits(Arduino.planar.vel(1)));
bitsPlanarVelY  = round(Arduino.planar.velParams.f_speed2bits(Arduino.planar.vel(2)));

bytePlanarVelX  = typecast(bitshift(uint16(bitsPlanarVelX),4), 'uint8');
bytePlanarVelY  = typecast(uint16(bitsPlanarVelY), 'uint8');


byteGloveMode  = bitshift(Arduino.glove.enable,5)...
                    + bitshift(Arduino.glove.admittanceMode,4)...
                    + bitshift(Arduino.glove.target,0);
                

byte1   = bytePlanarMode;
byte2   = bytePlanarVelX(2);
byte3   = bytePlanarVelY(2)+bytePlanarVelX(1);
byte4   = bytePlanarVelY(1);

byte5   = byteGloveMode;

%% Write to BBS
write(Arduino.devBBS,[byte1,byte2,byte3,byte4,byte5])

%% Read from BBS
readBytes   = read(Arduino.devBBS,8);
bytePlanarStatus = readBytes(1);

bytePlanarPosXHigh  = readBytes(2);
bytePlanarPosXLow   = bitand(readBytes(3), 240);
bytePlanarPosYHigh  = bitand(readBytes(3), 15);
bytePlanarPosYLow   = readBytes(4);

Arduino.planar.ready     = bitget(bytePlanarStatus,6);

bitsPlanarPosX  = typecast(uint8([bytePlanarPosXLow,bytePlanarPosXHigh]), 'uint16');
bitsPlanarPosX  = bitshift(bitsPlanarPosX,-4);
bitsPlanarPosY  = typecast(uint8([bytePlanarPosYLow,bytePlanarPosYHigh]), 'uint16');


byteGloveStatus     = readBytes(5);

byteGlovePosHigh    = readBytes(6);
byteGlovePosLow     = bitand(readBytes(7), 240);
byteGloveForceHigh  = bitand(readBytes(7), 15);
byteGloveForceLow   = readBytes(8);

Arduino.glove.ready = bitget(byteGloveStatus,6);

bitsGlovePos    = typecast(uint8([byteGlovePosLow,byteGlovePosHigh]), 'uint16');
bitsGlovePos    = bitshift(bitsGlovePos,-4);
bitsGloveForce  = typecast(uint8([byteGloveForceLow,byteGloveForceHigh]), 'uint16');

%% Covert Bytes into Actual Values
Arduino.planar.pos = [Arduino.planar.posParams.f_bits2pos(bitsPlanarPosX);...
                        Arduino.planar.posParams.f_bits2pos(bitsPlanarPosY)];

Arduino.glove.pos   = bitsGlovePos;
Arduino.glove.force = bitsGloveForce;


end