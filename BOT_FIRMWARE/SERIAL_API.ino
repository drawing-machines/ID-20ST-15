void listenSerial() {
  
  /*
  
  *******************
  
  SERIAL CONTROL API: 
  
  *******************
  
  Control BASE:
  
    1. [ position ]
  
      Send : char "b" (for base), then send : int [0-255]
    
    2. [ manual ]
    
      Send : char "r" -> OR <- Send: char "l"
      
      - moves the baseSrv motor left or right
      
      Send : chars "sr" -> OR <- Send: chars "sl"
      
      - stops baseSrv from continuing left or right
    
  Control ARM:
  
    1. [ position ]
  
      Send : char "a" (for arm) then send : int [0-255]
    
    2. [ manual ]
    
      Send : char "f" -> OR <- Send: char "k"
      
      - moves armStp forward or backward
      
      Send : chars "sf" -> OR <- Send: chars "sk"
      
      - stops armStp from continuing forward or backward
    
  Control PEN: 
    
    1. [ toggle ]
    
      Send : char "u" -> OR <- Send: char "d"
      
      - puts penSrv up or down
  
  */
 
  if(Serial.available() > 0) {
    
    char readByte = Serial.read();
    
    if (readByte == 'l') { // move base left
    
      manualMoveRight = false;
      manualMoveLeft = true;
      
      if(atBaseStop) atBaseStop = false;
      
      if(debug) {
        Serial.println("left"); 
      }
      
    } else if(readByte == 'r') { // move base right
     
      manualMoveLeft = false;
      manualMoveRight = true;
      
      if(atBaseStop) atBaseStop = false;
      
      if(debug) {
        Serial.println("right"); 
      }
    
    } else if(readByte == 'f') { // move arm forward

      manualMoveBackward = false;
      manualMoveForward  = true;
      
      if(atArmStop) atArmStop = false;
      
      if(debug) {
        Serial.println("forward");  
      }
      
    } else if(readByte == 'k') { // move arm backward
      
      manualMoveForward  = false;
      manualMoveBackward = true;
      
      if(atArmStop) atArmStop = false;

      if(debug) {
        Serial.println("backward"); 
      }
      
    } else if(readByte == 'u') { // move pen up
    
      if(penSrvReady) {
        penUp();
        if(debug) {
          Serial.println("pen up"); 
        }
      } else {
        if(debug) {
          Serial.println("pen already moving...");
        }
      }
      
    } else if(readByte == 'd') { // move pen down
      
      if(penSrvReady) {
        penDown();
        if(debug) {
          Serial.println("pen down"); 
        }
      } else {
        if(debug) {
          Serial.println("pen already moving...");
        }
      }
      
    } else if(readByte == 'a') { // set arm coordinate
      
      while( !Serial.available() ); // wait for int value
      
      newArmStpVal = int( map(Serial.parseInt(), 0, 255, 0, MAX_ARM_STEPS) );
      Serial.print("a : ");
      Serial.println(newArmStpVal);
      
    } else if(readByte == 'b') { // set base coordinate
      
      while(!Serial.available()); //wait for int val
      
      //TODO:
      //newBaseSrvVal = int( map(Serial.parseInt(), 0, 255, 0, maxBaseSrvVal) );
      
      if(debug) {
        Serial.print("b : ");
        //Serial.println(newBaseSrvVal);
      }
      
    } else if(readByte == 's') { // stop moving manually
            
      while(!Serial.available()); //wait for int val

      char stopByte = Serial.read();
      
      if(debug) {
        Serial.print("stop ");
        Serial.println(stopByte);
      }
      
      if(stopByte == 'r' || stopByte == 'l') {
        
        manualMoveRight = false;
        manualMoveLeft  = false;
        //TODO:
        //baseValSaved = false;
        //newBaseSrvVal = baseSrvVal;
        //Serial.println(newBaseSrvVal);
      }
      
      if(stopByte == 'f' || stopByte == 'k') {
        manualMoveForward  = false;
        manualMoveBackward = false;
        newArmStpVal = armStp.currentPosition();
      }
    }  
  }
}

void establishContact(){
  while (Serial.available() <=0){
    Serial.println("!!");
    delay(1000);
  }  
}

void reportPosition() {
  
  //TODO:
//  convertedArmStpVal = int(map(armStp.currentPosition(), 0, MAX_ARM_STEPS, 0, 255));
//  if(convertedArmStpVal != lastConvertedArmStpVal){
//    Serial.println('t');
//    Serial.println(convertedArmStpVal);
//    lastConvertedArmStpVal = convertedArmStpVal;
//  }
//  
//  if(baseSrvVal != lastBaseSrvVal){
//    Serial.println('b');
//    Serial.println(int(map(baseSrvVal, 0, maxBaseSrvVal, 0, 255)));
//    lastBaseSrvVal = baseSrvVal;
//  }
//  
//  if(penSrvVal != lastPenSrvVal){
//    Serial.println('s');
//    Serial.println(int(map(penSrvVal, 50, 90, 0, 255)));
//    lastPenSrvVal = penSrvVal;
//  }
}
