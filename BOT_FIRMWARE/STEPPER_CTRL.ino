void calibrateArm() {

  if (debug) Serial.println("setting arm home position...");

  //rotate stepper backward until hitting the home stop

  while (armHomeStopState != LOW) {
    armHomeStopState = digitalRead(ARM_HOME_STOP_PIN);
    armStp.moveTo(currArmPos++);
    armStp.setSpeed(ARM_CAL_SPEED);
    armStp.run();
  }

  //offset slightly so we don't smash up against the home stop
  armStp.setCurrentPosition(0);
  currArmPos = 0;

  if (debug) Serial.println("setting end position...");

  //rotate stepper forward until hitting the end switch
   while (armEndStopState != LOW) {
    armEndStopState = digitalRead(ARM_END_STOP_PIN);
    armStp.moveTo(currArmPos--);
    armStp.setSpeed(-ARM_CAL_SPEED);
    armStp.run();
  }


  //offset slightly so we don't smash up against the home stop
  MAX_ARM_STEPS = armStp.currentPosition();

  // set the steps per mm   
  STEPS_PER_MM = abs(MAX_ARM_STEPS) / ARM_LENGTH;


  if (debug) {
    Serial.print("max arm steps = ");
    Serial.println(MAX_ARM_STEPS);
  }

  if (debug) {
    Serial.print("steps per mm = ");
    Serial.println( STEPS_PER_MM );
  }
  
  delay(100);
  armStp.runToNewPosition(-10);

  atArmStop = true;
}

// TODO: this needs testing
void calibrateBase() {

  if (debug) Serial.println("setting base home position...");

  //rotate stepper backward until hitting the home stop
  while (baseHomeStopState != LOW) {
    baseHomeStopState = digitalRead(BASE_HOME_STOP_PIN);
    baseStp.moveTo(currBasePos++);
    baseStp.setSpeed(BASE_CAL_SPEED);
    baseStp.run();
  }

  //TODO: offset slightly so we don't smash up against the home stop
  baseStp.setCurrentPosition(0);
  currBasePos = 0;

  if (debug) Serial.println("setting end position...");

  //rotate stepper forward until hitting the end switch
//   while (baseEndStopState != LOW) {
   while (baseEndStopState > 500 ) {
    baseEndStopState = analogRead(BASE_END_STOP_PIN);
    baseStp.moveTo(currBasePos--);
    baseStp.setSpeed(-BASE_CAL_SPEED);
    baseStp.run();
    Serial.println(baseEndStopState);
  }
  

  //offset slightly so we don't smash up against the home stop
  MAX_BASE_STEPS = baseStp.currentPosition();
//  STEPS_PER_DEG = abs(MAX_BASE_STEPS)/175;

  if (debug) {
    Serial.print("max base steps = ");
    Serial.println(MAX_BASE_STEPS);
  }

//  if (debug) {
//    Serial.print("steps per degree = ");
//    Serial.println( STEPS_PER_DEG );
//  }
  
  delay(100);
  baseStp.runToNewPosition(-10);

  atBaseStop = true;
}

