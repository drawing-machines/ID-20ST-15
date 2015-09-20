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
