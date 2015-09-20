/**
 * BOT CONTROLLER APP
 *
 *
 *
 **/


/* CONSTANT VALUES
 ---------------------------------------------------*/

// CONSTANT VALUES
final float PPI = 72; // pixels per inch
final float PPM = 2.8346; // pixels per mm

// PHSYICAL PAPER OFFSETS
final float PAPER_WIDTH_MM    = 240;  //paper width
final float PAPER_HEIGHT_MM   = 150;  //paper height
final float PAPER_VERT_OFFSET = 10;   //bottom of paper to carriage center

// PHSYICAL ROBOT OFFSETS
final float BOT_OFFSET_BASE_MM  = 46.214;  // precise dec (diagram is rounded)
final float BOT_OFFSET_PEN_MM   = 35;      //precise dec (diagram is rounded)
final float BOT_ARM_TRAVEL_MM   = 197.203; //max travel dist of carriage on bot arm
final float BOT_ARM_TOP_TO_BASE = 291.747; //dist from tip of arm to base center

final float BOT_OFFSET_RADIUS_MM = BOT_OFFSET_BASE_MM + PAPER_VERT_OFFSET;

final float BOT_ARM_LENGTH_MM = 366.077; // mm length of robot arm
final float BOT_ARM_PIVOT_TO_BTM_MM = 74.083; //from pivot point to arm end

// ensure pixel density is non-retina (72 ppi)
final int PIXEL_DENSITY = 1;

// CONFIGURATION

int CANVAS_WIDTH_PX  = round( PAPER_WIDTH_MM * PPM );
int CANVAS_HEIGHT_PX = round( PAPER_HEIGHT_MM * PPM );

// stylus configuration
int   STYLUS_SIZE  = 2;
color STYLUS_COLOR = color(0, 200, 255); // rgb

PVector botOrigin;

/*
 [NOT CURRENTLY USED]
 PImage botArmImg;
 PImage botPenImg;
 int botArmImgW = 99;
 int botArmImgH = 1037;
 int botPenImgW = 152;
 int botPenImgH = 100;
 */

/* VIRTUAL PIXEL OFFSETS
 ---------------------------------------------------*/

// offsets in pixels
float distArmTop2BaseCent_px = BOT_ARM_TOP_TO_BASE * PPM;
float offsetBase_px = BOT_OFFSET_BASE_MM * PPM;
float offsetPen_px = BOT_OFFSET_PEN_MM * PPM;

float offsetAngleDeg = -degrees(atan2(BOT_OFFSET_PEN_MM, BOT_OFFSET_BASE_MM));
float offsetAngle    = -atan2(BOT_OFFSET_PEN_MM, BOT_OFFSET_BASE_MM);
float offsetCanvasVert_px = PAPER_VERT_OFFSET * PPM;

float currBaseDeg = offsetAngleDeg;
float currBaseAngle = offsetAngle;

float botArmLength_px = BOT_ARM_LENGTH_MM * PPM;
float botBasePivotToArmBtm_px = BOT_ARM_PIVOT_TO_BTM_MM * PPM;

//arm travel distance in pixels 
float maxArm_px = BOT_ARM_TRAVEL_MM * PPM;
float minArm_px = 0;

int armSpeed = 10;
int rotationSpeed = 5;

float botOfsettBasePx = BOT_OFFSET_BASE_MM * PPM;
float botOffsetRadius_px = BOT_OFFSET_RADIUS_MM * PPM; //new

float armPosition = 0;

PGraphics simGraphics;

// convenience coords
PVector 
    canvas_center
  , canvas_cent_btm
  , canvas_cent_top
  , canvas_top_left
  , canvas_btm_right
  ;

// COLORS
color canvasTan  = color(235, 227, 204);
color lightGreen = color(160, 170, 144);
color darkGreen  = color(70, 71, 60);
color darkGray   = color(51, 51, 51);
color lightGray  = color(153, 153, 153);
color black      = color(0);
color white      = color(255);
color orange     = color(240, 97, 30);
color cyan       = color(0, 255, 255);

// keeps track of the two most recent coords
PVector botCoord;
PVector canvasCoord;

float currentAngle = 0;
float currentAngleOffset = 0;
float currentRadius = 0;
float currentRadiusOffset = 0;

float currentAngleOffset2 = 0;
float currentRadiusOffset2 = 0;

// boolean logic flags
Boolean SIM_MODE    = true;
Boolean ROBOT_VIEW  = false; //view xy (default) or polar
Boolean BOT_RUNNING = false;
Boolean SIM_RUNNING = false;
Boolean CLEAR_SIM   = false;

// define some variables
ArrayList<PVector> BOT_CODE;
PVector nextCommand;
long    currTime;       // store the current time
Boolean isRobotMoving;  // indicates when robot is moving
Boolean isPenDown;      // indicates when pen is down
int     stepDelay = 1;  // lower the number, the faster we go

// variables used for moving robot
float currStep, currX, currY, distX, distY, numSteps, stepX, stepY;

float canvasX, canvasY;

float botViewScaleX = 0;
float botViewScaleY = 0;

/* SETTTINGS
 ---------------------------------------------------*/

void settings() {
  
  size(CANVAS_WIDTH_PX*2, CANVAS_HEIGHT_PX*2); 
  pixelDensity(PIXEL_DENSITY);
  smooth();
}

/* SETUP
 ---------------------------------------------------*/

void setup() {

  // set the frame rate
  // If processor is not fast enough to maintain the specified rate, 
  // the frame rate will not be achieved (skips frames)
  frameRate(300);

  // Images must be in the "data" directory to load correctly
  // [currently not used]
  // botArmImg = loadImage("bot_arm.png");
  // botPenImg = loadImage("bot_pen_carriage.png");

  println("Canvas width  = " + CANVAS_WIDTH_PX);
  println("Canvas height = " + CANVAS_HEIGHT_PX);
  print("Offset Angle = " + offsetAngleDeg);

  //convenience coords
  canvas_center    = new PVector(width/2, height/2);
  canvas_cent_btm  = new PVector(width/2, height/2 + CANVAS_HEIGHT_PX/2 - offsetCanvasVert_px);
  canvas_cent_top  = new PVector(width/2, height/2 - CANVAS_HEIGHT_PX/2 - offsetCanvasVert_px);
  canvas_top_left  = new PVector(width/2 - CANVAS_WIDTH_PX/2, height/2 - CANVAS_HEIGHT_PX/2 - offsetCanvasVert_px);
  canvas_btm_right = new PVector(width/2 + CANVAS_WIDTH_PX/2, height/2 + CANVAS_HEIGHT_PX/2 - offsetCanvasVert_px);

  botCoord     = new PVector(0, 0);
  canvasCoord  = new PVector(0, 0);

  // SIMULATION MODE SETTINGS
  // set the robot origin: bottom center of canvas
  botOrigin = new PVector(canvas_cent_btm.x, canvas_cent_btm.y + botOffsetRadius_px);

  // some flags to indicate if robot is moving or not
  isRobotMoving = false;
  isPenDown = false; 

  // initialize the bot code coordinates array
  // this is used to store the robot commands
  BOT_CODE = new ArrayList<PVector>();

  // Setup the UI elements
  simModeBtn = new SimpleButton(new PVector(width - 265, 15), 100, 20, "sim mode");
  botModeBtn = new SimpleButton(new PVector(width - 160, 15), 100, 20, "bot mode");
  runBtn     = new SimpleButton(new PVector(width - 55, 15), 100, 20, "run");
  
  // initialize each of the buttons
  canViewBtn = new SimpleButton(new PVector(65, 15), 120, 20, "canvas view");
  botViewBtn = new SimpleButton(new PVector(190, 15), 120, 20, "robot view");
 
  // we only use SIM_MODE bool for logic toggle between sim & bot modes
  simModeBtn.setActive(SIM_MODE);
  botModeBtn.setActive(!SIM_MODE);
  
  // we only use ROBOT_VIEW for logic toggle between robot and canvas views
  canViewBtn.setActive(!ROBOT_VIEW);
  botViewBtn.setActive(ROBOT_VIEW);
  
  // initialize the frame buffer object for the simulated graphics
  simGraphics = createGraphics(width, height);
  
  botViewScaleX = float(CANVAS_WIDTH_PX)/float(width);
  botViewScaleY = float(CANVAS_HEIGHT_PX)/float(height);
  
  canvasX = 0;
  canvasY = 0;
}

/* DRAW
 ---------------------------------------------------*/

void draw() {
  
  background(white);

  if (ROBOT_VIEW) {

    drawGuides();
    drawCanvas();

    //drawBotArm( currentRadius, currentAngle, lightGray );
    drawBotArm( currentRadiusOffset, currentAngle + currentAngleOffset, lightGreen );
   
  }
  
  if (SIM_RUNNING) {
    
    drawBotCode();
    
  } else if(ROBOT_VIEW) {
    
    if (mouseX > canvas_top_left.x &&
        mouseX < canvas_btm_right.x &&
        mouseY > canvas_top_left.y &&
        mouseY < canvas_btm_right.y) {
        
        drawConversionGuide();
        animateBot(mouseX, mouseY);
    } 
  }
  
  // Draw the buttons
  simModeBtn.render();
  botModeBtn.render();
  botViewBtn.render();
  canViewBtn.render();
  runBtn.render();
  
  // Draws simulated drawing
  image(simGraphics, 0, 0);
}

void drawConversionGuide() {
 
  pushMatrix();
    translate(canvas_top_left.x, canvas_top_left.y);
    noStroke();
    fill(0, 0, 200);
    ellipse( canvasX, canvasY, 10, 10 );
    noFill();
    strokeWeight(1);
    stroke(0, 0, 200);
    line(0, 0, canvasX, canvasY);
  popMatrix();
 
}

void animateBot(float x, float y) {
  
  pushMatrix();

  //translate to top left of drawing canvas
  translate(canvas_top_left.x, canvas_top_left.y);

  // translate mouseX, mouseY to top left of canvas
  canvasX = x - canvas_top_left.x;
  canvasY = y - canvas_top_left.y;

  //println( "converting point " + canvasX + ", " + canvasY ); 

  float cartesianX;
  float cartesianY;

  cartesianX = canvasX - (botOrigin.x - canvas_top_left.x);
  cartesianY = (botOrigin.y - canvas_top_left.y) - (canvasY);

  PVector polar = getPolar(cartesianX, cartesianY);

  currentAngle = polar.y;
  currentRadius = polar.x;

  float hyp = currentRadius;
  float opp = offsetPen_px;
  float adj = sqrt(sq(hyp) - sq(opp));

  currentAngleOffset = asin( sin(opp/hyp) );
  currentRadiusOffset = adj;

  float hyp2 = currentRadius + botOffsetRadius_px;
  float opp2 = offsetPen_px;
  float adj2 = sqrt(sq(hyp2) - sq(opp2));

  currentAngleOffset2 = asin( sin(opp2/hyp2) );
  currentRadiusOffset2 = adj2;
    
  //println( "    polar coords: ang: " + currentAngle + ", rad: " + currentRadius );
  popMatrix();
}

void updateCoords() {

  if (mouseX > canvas_top_left.x &&
    mouseX < canvas_btm_right.x &&
    mouseY > canvas_top_left.y &&
    mouseY < canvas_btm_right.y) {

    pushMatrix();

    //translate to top left of drawing canvas
    translate(canvas_top_left.x, canvas_top_left.y);

    //float canvasX = float(mouseX);
    //float canvasY = float(mouseY);

    // translate mouseX, mouseY to top left of canvas
    float canvasX = float(mouseX) - canvas_top_left.x;
    float canvasY = float(mouseY) - canvas_top_left.y;

    //println( "converting point " + canvasX + ", " + canvasY ); 

    noStroke();
    fill(0, 0, 200);
    ellipse( canvasX, canvasY, 10, 10 );
    noFill();
    stroke(0, 0, 200);
    line(0, 0, canvasX, canvasY);

    float cartesianX;
    float cartesianY;

    cartesianX = canvasX - (botOrigin.x - canvas_top_left.x);
    cartesianY = (botOrigin.y - canvas_top_left.y) - (canvasY);

    //println(cartesianX);
    //println(cartesianY);

    //println( "  in bot reference: " + cartesianX + ", " + cartesianY );

    PVector polar = getPolar(cartesianX, cartesianY);

    currentAngle = polar.y;
    currentRadius = polar.x;

    float hyp = currentRadius;
    float opp = offsetPen_px;
    float adj = sqrt(sq(hyp) - sq(opp));

    currentAngleOffset = asin( sin(opp/hyp) );
    currentRadiusOffset = adj;

    float hyp2 = currentRadius + botOffsetRadius_px;
    float opp2 = offsetPen_px;
    float adj2 = sqrt(sq(hyp2) - sq(opp2));

    currentAngleOffset2 = asin( sin(opp2/hyp2) );
    currentRadiusOffset2 = adj2;

    //println( "    polar coords: ang: " + currentAngle + ", rad: " + currentRadius );
    popMatrix();
  }
}

void drawBotArm(float r, float a, color c) {

  pushMatrix();

  // translate to bot origin
  translate(botOrigin.x, botOrigin.y);

  // rotate matrix to current angle
  rotate( -a ); // ccw

  // draw the arm
  noStroke();
  fill(c);
  ellipse( r, 0, 10, 10 );

  noFill();
  strokeWeight(3);
  stroke(c);
  line(-botBasePivotToArmBtm_px, 0, botArmLength_px, 0);
  
  // draw pivot point
  ellipse(0, 0, 100, 100);

  noFill();
  stroke(c);
  line( r, 0, r, offsetPen_px );

  noStroke();
  fill(c);
  ellipse( r, offsetPen_px, 10, 10 );

  popMatrix();
}


void drawCanvas() {

  pushMatrix();
  rectMode(CENTER);
  fill(canvasTan);
  stroke(orange);
  rect(width/2, height/2 - offsetCanvasVert_px, CANVAS_WIDTH_PX, CANVAS_HEIGHT_PX);
  popMatrix();
}

void drawOffsets() {

  pushMatrix();
  strokeWeight(3);
  noFill();
  stroke(240, 97, 30);
  line(canvas_cent_btm.x, canvas_cent_btm.y, canvas_cent_btm.x, canvas_cent_btm.y + offsetBase_px);
  popMatrix();
}

void drawGuides() {

  pushMatrix();

  strokeWeight(1);
  stroke(lightGreen);
  noFill();

  float radius = sqrt( sq(CANVAS_WIDTH_PX/2) + sq(CANVAS_HEIGHT_PX) );
  ellipse(width/2, canvas_cent_btm.y, radius * 2, radius * 2);
  line(0, canvas_cent_btm.y, width, canvas_cent_btm.y);

  popMatrix();
}

// run the robot drawing code
void drawBotCode() {
  
  // check to see if robot is moving, if not we'll 
  if (isRobotMoving == false) {

    // check to see if we executed all bot commands
    if (!BOT_CODE.isEmpty()) { 

      // capture the next coordinate
      nextCommand = BOT_CODE.get(0);

      // remove the command of the chain
      BOT_CODE.remove(0);

      if ( nextCommand.x == -1) { // check if pen down

        isPenDown = true;
        
      } else if (nextCommand.y == -1) { // check pen up

        isPenDown = false;
        
      } else if ( isPenDown ) {
        
        if(ROBOT_VIEW) { //handle transform when in robot view
          nextCommand.x = nextCommand.x * botViewScaleX + canvas_top_left.x;
          nextCommand.y = nextCommand.y * botViewScaleY + canvas_top_left.y;
        }

        // find out the distance to travel     
        distX = abs(currX - nextCommand.x);
        distY = abs(currY - nextCommand.y);

        // determine the greatest number of steps
        numSteps = (abs(distX) > abs(distY)) ? abs(distX) : abs(distY);

        // determine number of steps to take on each axis 
        // we might have fractions of steps here, so we'll use float
        stepX = distX / numSteps;
        stepY = distY / numSteps;

        // set the direction of movement
        if (nextCommand.x < currX ) stepX *= -1;
        if (nextCommand.y < currY ) stepY *= -1; 

        //reset the current step counter
        currStep = 0;

        // indicate that the robot will now be moving
        isRobotMoving = true;
        
      } else {
        
        if(ROBOT_VIEW) { //handle transform when in robot view
          nextCommand.x = nextCommand.x * botViewScaleX + canvas_top_left.x;
          nextCommand.y = nextCommand.y * botViewScaleY + canvas_top_left.y;
        }

        currX = nextCommand.x;
        currY = nextCommand.y;
        
      }
    }

    //if robot is moving, continue until move complete
  } else if (currStep < numSteps) {
    
    // draw!
    
    if(ROBOT_VIEW) {
      animateBot(currX + stepX, currY + stepY); 
    }
    
    // start drawing to the simulator graphics pixel buffer
    simGraphics.beginDraw();
    
    // set the size of the stroke (stylus)
    simGraphics.strokeWeight(STYLUS_SIZE);

    // stroke the line to make it visible (provide the stylus color)
    simGraphics.stroke(STYLUS_COLOR);

    // continue drawing our line from the current position
    simGraphics.line(currX, currY, currX + stepX, currY + stepY);
    
    // end drawing to the pixel buffer
    simGraphics.endDraw();

    // update current positions by adding their step values
    currX += stepX;
    currY += stepY;

    currStep++;

    // this creates a slight delay between steps
    while (millis() - currTime <= stepDelay) {  /* pause */ ; }
    
  } else {

    // indicate that we are done moving the robot
    isRobotMoving = false;
  }

  if(SIM_RUNNING && BOT_CODE.isEmpty()) {
    SIM_RUNNING = false; //turn off sim
    runBtn.setLabel("run sim"); //reset button
    runBtn.setActive(SIM_RUNNING); //deactivate button
  }

  // update the stored time
  currTime = millis(); 
}

void eraseDrawing() {
  
  simGraphics.beginDraw();
  simGraphics.noStroke();
  simGraphics.fill(white);
  simGraphics.background(255, 0);  // transparent white
  simGraphics.endDraw();
  image(simGraphics, 0, 0);
}