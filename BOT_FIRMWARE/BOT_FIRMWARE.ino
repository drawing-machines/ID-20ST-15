/**************************************
BOT FIRMWARE V0.4.0

@authors    : Mikhail Mansion, Kuan-Ju Wu
@updated    : September, 2015
@descrition : Firmware for controlling the drawing bot.       

**************************************/

// NOTE: Uses AccelStepper lib with AF_motor support
// https://github.com/adafruit/AccelStepper
#include <AccelStepper.h> 
#include <EEPROM.h>
#include <Servo.h>
#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_PWMServoDriver.h"

/* PIN MAPPING
   -------------------------------------- */
#define ARM_END_STOP_PIN    4 // arm end limit  
#define ARM_HOME_STOP_PIN   3 // arm home limit (0 mm)

#define BASE_HOME_STOP_PIN  5 // base home limit (0 deg)
#define BASE_END_STOP_PIN   A5 // base end limit (180 deg)

#define PEN_SERVO_PIN 10

/* DEBUG
   -------------------------------------- */
bool debug      = true;
bool enableArm  = false;
bool enableBase = false;
bool enablePen  = false;

/* DIMESNSIONS
   -------------------------------------- */
 // in millimeters
//const float ARM_LENGTH  = 177.8; // ( 7" )
//const float ARM_LENGTH = 212.725; // demo bot
const float ARM_LENGTH = 203.2;

//canvas size based on 8x5" index card
const float  CANVAS_W = 203.2; // ( 8" )
const float  CANVAS_H = 127.0; // ( 5" )

const float  CANVAS_CENT_X = CANVAS_W/2;
const float  CANVAS_CENT_Y = CANVAS_H/2;

//only supports top-left registration right now
const String CANVAS_REG = "tl";

// max radius based on canvas dimensions
const float MAX_RAD = sqrt( sq(CANVAS_W / 2 ) + sq( CANVAS_H ) ); //162.64
//const float MAX_ANG; //not used

// this is currently set for a stepper that has 48 steps,
// and uses EasyDriver that is operating in the default 1/8th step mode
const int STEPS_PER_REV = 200;
float STEPS_PER_MM; //calculated at run (steps per physical millimeter)
float STEPS_PER_RADIAN;
float STEPS_PER_DEG;

/* ARM STEPPER CONFIG
   -------------------------------------- */
int ARM_STEP_DIR = -1; // 1 or -1 (effectively flips the stepper directions)


/* MOTOR SPEEDS
   -------------------------------------- */

const float MAX_STP_SPEED     = 1000; //deprecated
const float MAX_STP_ACCEL     = 4500; //deprecated
const float MANUAL_STP_SPEED  = 0.8;

// arm stepper motor speeds
const float ARM_CAL_SPEED = 500;  // speed during calibration
const float ARM_MAX_SPEED = 300; // max speed during normal opperation
const float ARM_ACL_SPEED = 100; // motor acceleration speed
const float ARM_MAN_SPEED = 300;  // manual opperation speed

// base stepper motor speeds
const float BASE_CAL_SPEED = 500;  // speed during calibration
const float BASE_MAX_SPEED = 50; // max speed during normal opperation
const float BASE_ACL_SPEED = 50; // motor acceleration speed
const float BASE_MAN_SPEED = 25; // manual opperation speed

// serial communication speed
#define SER_BAUD 115200 // bits per second

int MAX_ARM_STEPS; //maximum travel distance.
int MAX_BASE_STEPS;

long newArmStpVal = 0;
int convertedArmStpVal    =  0;
int lastConvertedArmStpVal = 0;

// track rounding errors in each move
float angleError  = 0;
float radiusError = 0;

/* PEN SERVO SETUP
   -------------------------------------- */
   
// Pen servo variables
float penSrvSpd     = 0.01; // speed of movement for the pen servo
float penSrvVal     = 90;   // current position of pen servo
int   penUpPos      = 80;   // up position of pen (not drawing)
int   penDownPos    = 40;   // down position of pen (is drawing)
int   lastPenSrvVal = 50;

// Control flags for moving motors
// note: all start as false
bool baseSrvReady = false;
bool penSrvReady  = false;

// Define baseSrv and penSrv motors (servos)
Servo penSrv;

Adafruit_MotorShield motorShield = Adafruit_MotorShield(); 

// Connect steppers to shield, providing steps-per-revolution and port
Adafruit_StepperMotor * af_armStp  = motorShield.getStepper(STEPS_PER_REV, 1);
Adafruit_StepperMotor * af_baseStp = motorShield.getStepper(STEPS_PER_REV, 2);

// Motor step function wrappers
// configurable to: DOUBLE, INTERLEAVE or MICROSTEP
void armStpFwd()  { af_armStp->onestep(  FORWARD,  DOUBLE); }
void armStpBck()  { af_armStp->onestep(  BACKWARD, DOUBLE); }
void baseStpFwd() { af_baseStp->onestep( FORWARD,  DOUBLE); }
void baseStpBck() { af_baseStp->onestep( BACKWARD, DOUBLE); }

// Wrap the steppers in an AccelStepper object
AccelStepper armStp(armStpFwd, armStpBck);
AccelStepper baseStp(baseStpFwd, baseStpBck);

// EEPROM : preserve positions after power off
int eeAddrBase = 0;

/* CONTROL FLAGS
   -------------------------------------- */
bool recalibrate = false;

// end-stop switches
bool armHomeStopState  = HIGH;
bool armEndStopState   = HIGH;
bool baseHomeStopState = HIGH;
bool baseEndStopState  = HIGH;

// eeprom data
bool baseValSaved = false;
bool armValSaved  = false;
bool isPenDown    = false;

// Manual movement flags
bool manualMoveRight    = false;
bool manualMoveLeft     = false;
bool manualMoveForward  = false; 
bool manualMoveBackward = false;

bool moveAuto   = false;
bool atArmStop  = false;
bool atBaseStop = false;

/* COORDINATES
   -------------------------------------- */
//set at run, after calibration
float ORIGIN_X = 0.0; 
float ORIGIN_Y = 0.01; //must not be 0

// global x, y (cartesian)
float currX = 0.0;
float currY = 0.01;

// used in conjunction with "moveAuto" bool
float nextX = 0;
float nextY = 0;

//global a, r (polar)
float currAngle,  lastAngle;
float currRadius, lastRadius;

float currArmPos  = 0;
float lastArmPos  = 0;
float currBasePos = 0;
float lastBasePos = 0;

/* APPLICATTION START
   -------------------------------------- */
void setup() {
  
  motorShield.begin(); //start the shield
  
  // initialize serial comm
  Serial.begin(SER_BAUD);
  while (!Serial) { ; /*wait for serial port to connect*/ }
  
  // initialize pen servo
  penSrv.attach(PEN_SERVO_PIN);
  penSrv.write(penUpPos);
  penSrv.detach(); //hack to prevent the jitters
  penSrvReady = true;
  
  // initialize base servo
//  EEPROM.get( eeAddrBase, baseSrvVal ); //get last pos from EEPROM
//  if(debug) {
//    Serial.print("EEPROM servo value = ");
//    Serial.println(baseSrvVal);
//  }

  //TODO: setup base, calibrate
  
  if(debug) {
    Serial.print("Steps per Radian = ");
    Serial.println(STEPS_PER_RADIAN);
    
    Serial.print("Steps per Degree = ");
    Serial.println(STEPS_PER_DEG);
  }
  
  // Set stepper motor speeds
  armStp.setMaxSpeed(ARM_MAX_SPEED);
  armStp.setAcceleration(ARM_ACL_SPEED);
 
  baseStp.setMaxSpeed(BASE_MAX_SPEED);
  baseStp.setAcceleration(BASE_ACL_SPEED);

  armStp.setCurrentPosition(0);
  baseStp.setCurrentPosition(0);
  
  // initialize arm stop switch pins
  pinMode(ARM_HOME_STOP_PIN, INPUT_PULLUP);
  pinMode(ARM_END_STOP_PIN , INPUT_PULLUP);
  pinMode(BASE_HOME_STOP_PIN, INPUT_PULLUP);
  pinMode(BASE_END_STOP_PIN, INPUT_PULLUP);
  
  //the calibration function sets the MAX_ARM_STEPS
  //calibrateArm();
  
  //TMP dummy value (TODO: this should be calculated in base calibration)
  // MAX_BASE_STEPS = 
  
  // set the steps per mm
  STEPS_PER_MM = abs(MAX_ARM_STEPS) / ARM_LENGTH;
  
  Serial.println("bot is ready...listening for commands");
  
  // wait here for system handshake
  establishContact();
 
}

// MAIN LOOP
// ----------------------------------------------------------

void loop() {

  movePenToNewPosition();
  
  // checks to see if base values need saving
  // this does not write to eeprom each loop,
  // but when baseValSaved bool is unset (false)
  //saveBaseValues();

  //reports values back to processing
  //TODO: report feedback to processing
  //reportPosition();
  
  // listen for new commands
  listenSerial();
  
  //check the stops so we don't run over
  checkStops();
}

// ----------------------------------------------------------

void movePenToNewPosition() {
  
  if(manualMoveForward) {
    
    // MANUALLY MOVE FORWARD 
   
    armStp.moveTo(--currArmPos);
    // set speed each time prevents acceleration while moving manually
    armStp.setSpeed(-ARM_MAN_SPEED);
    armStp.run();
     
  } else if(manualMoveBackward) {
    
    // MANUALLY MOVE BACKWARD

    armStp.moveTo(++currArmPos);
    // set speed each time prevents acceleration while moving manually
    armStp.setSpeed(ARM_MAN_SPEED);
    armStp.run();
    
  } else {
    
     //TODO: runto
     af_armStp->release();
  }
  
  if(manualMoveRight) {
    
    // MANUALLY MOVE RIGHT 
    currBasePos+= 1;
    baseStp.moveTo(currBasePos);
    // set speed each time prevents acceleration while moving manually
    baseStp.setSpeed(BASE_MAN_SPEED);
    baseStp.run();
   
    
  } else if(manualMoveLeft) {
    
    // MANUALLY MOVE LEFT 
    currBasePos -= 1;
    baseStp.moveTo(currBasePos);
    // set speed each time prevents acceleration while moving manually
    baseStp.setSpeed(-BASE_MAN_SPEED);
    baseStp.run();
    
  } else {
    Serial.println('release');
    af_baseStp->release();
    //TODO: runto
  }
}

void checkStops() {
  
  //Checking if the carrier is hitting the end stops.
  armHomeStopState  = digitalRead(ARM_HOME_STOP_PIN);
  armEndStopState   = digitalRead(ARM_END_STOP_PIN);
  baseHomeStopState = digitalRead(BASE_HOME_STOP_PIN);
  baseEndStopState  = digitalRead(BASE_END_STOP_PIN);
  
  if(armHomeStopState == LOW){

    armStp.setCurrentPosition(0);
    currArmPos = 0;
    if(!atArmStop) {
      manualMoveBackward = false;
      atArmStop = true;
    }
  }
  
  if(armEndStopState == LOW){

    armStp.setCurrentPosition(MAX_ARM_STEPS);
    currArmPos = MAX_ARM_STEPS;
    if(!atArmStop) {
      manualMoveForward = false;
      atArmStop = true;
    }
  }
  
  if(baseHomeStopState == LOW){

    baseStp.setCurrentPosition(0);
    currBasePos = 0;
    if(!atBaseStop) {
      manualMoveRight = false;
      atBaseStop = true;
    }
  }
  
  if(baseEndStopState == LOW){

    baseStp.setCurrentPosition(MAX_BASE_STEPS);
    currBasePos = MAX_BASE_STEPS;
    if(!atBaseStop) {
      manualMoveLeft = false;
      atBaseStop = true;
    }
  }
}

float angleToRadian(float deg) {
  //values from theory of continued fractions
  //https://en.wikipedia.org/wiki/Continued_fraction
  return (deg * 71) / 4068;
}

float radianToAngle(float radian) {
 //values from theory of continued fractions
 //https://en.wikipedia.org/wiki/Continued_fraction
 return (radian * 4068) / 71;
}
