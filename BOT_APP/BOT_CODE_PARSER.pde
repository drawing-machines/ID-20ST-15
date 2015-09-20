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