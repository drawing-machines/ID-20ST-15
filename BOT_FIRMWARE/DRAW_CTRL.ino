
// moves pen to origin
void goHome() {
  
  moveTo(ORIGIN_X, ORIGIN_Y);
}

// draws a line from current position to x, y
void lineTo(float x, float y) {
  
  penDown();
  motorsTo(x, y);
}

// moves to a position without drawing
void moveTo(float x, float y) {
  penUp();
  motorsTo(x, y);
}


//TODO: this all needs refactoring

bool _isReadyNextStep = false;
bool _isReadyNextMove = false;
int  stepsToMove = 0;
int  currStep = 0;


double _stepX;
double _stepY;
int _thisStep;
float _distX;
float _distY;
float _stepsToMove;
float _newX;
float _newY;
float _newAngle;
float _newRadius;
float _angleDiff;
float _radiusDiff;
float _radiusSteps;

void continueTo(float x, float y) {
  
  // prepare for next move by calculating number of steps
  
  if(!_isReadyNextMove) {
  
    float coords[2] = { x , y };
 
    // this converts from drawing xy to robot xy space
    translateMatrix(coords);
     
    // distance from current coords
    _distX = coords[0] - currX;
    _distY = coords[1] - currY;
    
    // check which direction is largest
    _stepsToMove = (abs(_distY) < abs(_distX)) ? abs(_distX) : abs(_distY);
    
     // check num of steps to move
    _stepX = (float) _distX / (float) _stepsToMove;
    _stepY = (float) _distY / (float) _stepsToMove; 
    
    _thisStep = 0;
    
    _isReadyNextMove = true;
  }
  
  if(!_isReadyNextStep) {
    
    // calculate size of the next step for each motor
    
     // get current polar coords   
    currAngle  = (atan2(currY, currX) * 180 / PI); 
    currRadius = sqrt( sq(currX) + sq(currY));
       
    // check coords after step
    _newX = (float) currX + _stepX;
    _newY = (float) currY + _stepY;
       
    // check new angle and radius by converting new xy to polar
    _newAngle  = (atan2(_newY, _newX) * 180 / PI); 
    _newRadius = sqrt( sq(_newX) + sq(_newY) ); 
        
    // get diffs from the current angle and radius
    _angleDiff  = _newAngle - currAngle;
    _radiusDiff = _newRadius - currRadius;
       
    // convert diffs to actual motor positions
    //float angleSteps  = (float) STEPS_PER_DEG * angleDiff;   
    _radiusSteps = (float) STEPS_PER_MM  * _radiusDiff;
    
    _isReadyNextStep = true;
    
    Serial.print("READY FOR NEXT STEP");
    
    delay(2000000);
    
  } else {
    
//    numSteps *= ARM_STEP_DIR; //"flip" directions if set in config
//  
//    float newArmPos = currArmPos + numSteps;
//  
//    bool forward = (newArmPos - lastArmPos >= 0) ? true : false;
//  
//    // move the motor
//    armStp.moveTo(newArmPos);
//    
//    //inverts the speed val based on heading
//    int stepSpeed = (forward) ? MAX_STP_SPEED : MAX_STP_SPEED * -1;
//  
//    while (armStp.distanceToGo() != 0) { 
//     armStp.setSpeed(stepSpeed);
//     armStp.run();
//    }
//  
//    // update arm position
//    lastArmPos = currArmPos;
//    currArmPos = newArmPos;




    
//    stepArm(radiusSteps);
//    stepBase(angleDiff);
//   
//    //moveTogether(radiusSteps, angleDiff);
//   
//    // update position
//    currX = newX;
//    currY = newY;
//   
//    currAngle  = newAngle;
//    currRadius = newRadius;
//     
//    
//    currStep++;
//    readyNextStep = false;
  }
}


void motorsTo(float x, float y) {
  
 float coords[2] = { x , y };
 
 // this converts from drawing xy to robot xy space
 translateMatrix(coords);
 
 // distance from current coords
 float dx = coords[0] - currX;
 float dy = coords[1] - currY;

 // check which direction is largest
 int noSteps = (abs(dy) < abs(dx)) ? abs(dx) : abs(dy);
 
 // check num of steps to move
 double stepX = (float) dx / (float) noSteps;
 double stepY = (float) dy / (float) noSteps;

 for (int thisStep = 0; thisStep < noSteps; thisStep++) {
   
   // get current polar coords   
   currAngle  = (atan2(currY, currX) * 180 / PI); 
   currRadius = sqrt( sq(currX) + sq(currY));
   
   // check coords after step
   float newX = (float) currX + stepX;
   float newY = (float) currY + stepY;
   
   // check new angle and radius by converting new xy to polar
   float newAngle  = (atan2(newY, newX) * 180 / PI); 
   float newRadius = sqrt( newX * newX + newY * newY ); 
    
   // get diffs from the current angle and radius
   float angleDiff  = newAngle - currAngle;
   float radiusDiff = newRadius - currRadius;
   
   // convert diffs to actual motor positions
   float angleSteps  = (float) STEPS_PER_DEG * angleDiff;   
   float radiusSteps = (float) STEPS_PER_MM  * radiusDiff;
   
   //stepArm(radiusSteps);
   //stepBase(angleDiff);
   
   //moveTogether(radiusSteps, angleDiff);
   
   // update position
   currX = newX;
   currY = newY;
   
   currAngle  = newAngle;
   currRadius = newRadius;
 }
}

// here we translate from the drawing program's cartesian
// space into the robot's cartesian space, which puts the 
// xy origin at roughly the machine's center-bottom pos

void translateMatrix(float coords[]) {
 
  addOffsets(coords);
  
  // we are converting from a top-left registration system
  // with a reversed y-axis (common in computer graphics)
  // into a standard center-registered cartesian grid
  coords[1] *= -1; //simply reverse the y-axis
}

void addOffsets(float coords[]) {
  
  //offsets for top-left only
  coords[0] = coords[0] + ( -CANVAS_W/2 );
  coords[1] = coords[1] + ( -CANVAS_H );
}
