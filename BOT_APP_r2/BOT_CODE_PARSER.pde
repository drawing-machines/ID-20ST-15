/**
 * BOT_CODE_PARSER
 *
 * The BOT_CODE_PARSER receives the commands you enter in the BOT_CODE tab, 
 * and compiles them into a BOT_CODE array. The array is basically just a 
 * list of coordinates. Some coordinates have special meaning: i.e. penUp().
 * Once your BOT_CODE is parsed, and all the coordinates have been added to 
 * the array, the BOT_CONTROLLER reads each value, from first to last. The
 * coords are then sent through the COORD_CONVERTER. Conversions are necessary
 * for translating between the virtual and physical canvases. Finally, the 
 * converted coordinates are sent over a serial connection (USB), where the 
 * drawing machine will then procede to draw them out.
 */

void moveTo(float x, float y) {
 saveBotCode(x, y);
}

void penUp() {
  saveBotCode(0, -1);
}

void penDown() {
 saveBotCode(-1, 0);
}

void saveBotCode(float x, float y) {
  
  // this function saves robot commands as special coordinates
  
  /**************************************
  Since we never draw to the (0,-1) coord, 
  it will represent "pen up". Likewise, "pen down"
  is represented by using a negative x coordinate.
  All other BOT_CODE, i.e. ( [0 - width] , [0 - height] ) 
  can be used for drawing.
  
  pen down = (-1, 0);
  pen up   = (0,-1); 
  coord    = (x, y);
  
  ***************************************/
  
  BOT_CODE.add( new PVector(x, y) ); // record the next coordinate command
   
}

void clearBotCode() {
  
  for (int i = BOT_CODE.size() - 1; i >= 0; i--) {
    BOT_CODE.remove(i);
  }
  
  // some flags to indicate if robot is moving or not
  isRobotMoving = false;
  isPenDown = false; 
}

void readBotCode() {
  myRobotCode();
}

/**
 *
 * @class makeSVG
 *
 * Generate shapes from bot code coordinates
 *
 */

void makeSVG() {
  
  // clear the last sim drawing (if there is one)
  eraseDrawing();
  // clear out any unexecuted commands
  clearBotCode();
  // read the bot code again (fresh list of commands)
  readBotCode();
  
  // local variables for iterating through bot code and generating shapes
  PVector nextCommand;
  boolean penDown = false;
  
  // variables used for moving robot
  float currStep = 0;
  float currX    = 0;
  float currY    = 0;
  float distX    = 0;
  float distY    = 0;
  float numSteps = 0;
  float stepX    = 0; 
  float stepY    = 0;
  int currShape  = 0;
  
  // each time the pen goes down let's start a new shape
  SVG_SHAPES.add( createShape() );

  // iterate through all the bot code commands
  while( !BOT_CODE.isEmpty() ) {
    
    // 1. READ THE BOT COMMAND
    
    // capture the next coordinate
    nextCommand = BOT_CODE.get(0);

    // remove the command of the chain
    BOT_CODE.remove(0);
    
    // 2. EXECUTE COMMAND
    
         if ( nextCommand.x == -1) { // PUT PEN DOWN
    
      // Custom, unique shapes can be made by using createShape() without a parameter
      // https://processing.org/reference/createShape_.html
      
      penDown = true;
      
    } else if (nextCommand.y == -1) { // OR BRING PEN UP

      penDown = false;
      
    } else if(penDown) { // OR DRAW TO NEXT POSITION
      
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
      
      //start drawing a new vector shape
      SVG_SHAPES.get(currShape).beginShape();
      
      while(currStep < numSteps) {
        
        // set the size of the stroke (stylus)
        SVG_SHAPES.get(currShape).strokeWeight(STYLUS_SIZE);
    
        // stroke the line to make it visible (provide the stylus color)
        SVG_SHAPES.get(currShape).stroke(STYLUS_COLOR);
        
        // continue drawing our line from the current position
        SVG_SHAPES.get(currShape).vertex(currX + stepX, currY + stepY);
        
    
        // update current positions by adding their step values
        currX += stepX;
        currY += stepY;
    
        currStep++;
      }
      
      //each time the pen goes up, let's end the current shape
      SVG_SHAPES.get(currShape).endShape();
      
      //increment the current shape
      currShape++;
      
      //create another shape before drawing again
      SVG_SHAPES.add( createShape() );
      
    } else { // OR MOVE TO NEXT POSITION
    
      currX = nextCommand.x;
      currY = nextCommand.y;
      
    }
    
  } // end while
  
  SHOW_SVG = true;
  
}