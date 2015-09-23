/**
 *
 * @class SimpleButton
 *
 * Creates an interactive toggle or momentary switch
 *
 */
 
// Declar UI Buttons
SimpleButton runBtn, botModeBtn, simModeBtn, botViewBtn, canViewBtn; 

class SimpleButton {
  PVector position;
  String  label;
  color   bgColor;
  color   txtColor;
  boolean isActive;
  boolean simpleToggle;
  int     w, h;

  SimpleButton(PVector p, int w, int h, String l) {
    this.position = p;
    this.w = w;
    this.h = h;
    this.label = l;
    this.simpleToggle = false;
    this.bgColor = color(100, 255, 200);
    this.txtColor = color(0);
  }

  SimpleButton(PVector p, int s) {
    this.position = p;
    this.w = s;
    this.h = s;
    this.simpleToggle = true;
    this.label = "";
    this.bgColor = color(100, 255, 200);
    this.txtColor = color(0);
  }

  public void render() {
    rectMode(CENTER);
    stroke(0);
    if (this.isActive) {
      strokeWeight(3);
      //fill(100,255,200);
      fill(this.bgColor);
    } else {
      strokeWeight(1);
      fill(white);
    }
    rect(this.position.x, this.position.y, this.w, this.h);
    fill(this.txtColor);
    textAlign(CENTER, CENTER);
    text(this.label, this.position.x, this.position.y);
  }

  public void toggle() {
    isActive = !isActive;
  }
  
  public Boolean isActive() {
    return this.isActive; 
  }
  
  public void setActive(Boolean bool) {
    isActive = bool;
  }
  
  public void setColor(color c) {
    this.bgColor = c;
  }
  
  public void setTextColor(color c) {
    this.txtColor = c; 
  }
  
  public void setLabel(String l) {
    this.label = l;
  }

  public boolean isClicked(int x, int y) {
    return dist(mouseX, mouseY, this.position.x, this.position.y) < this.w/2;
  }
}

/**
 *
 * @event keyPressed
 *
 * Called when a key on the user keyboard is pressed
 *
 */

void keyPressed() {

  switch(keyCode) {
  case 37: // left
    currBaseDeg-=rotationSpeed;
    //if(currBaseDeg < 270) currBaseDeg = 270;
    break;
  case 39: // right
    currBaseDeg+=rotationSpeed;
    //if(currBaseDeg > 0) currBaseDeg = 0;
    break;
  case 38: //up
    armPosition+=armSpeed;
    if (armPosition > maxArm_px) armPosition = maxArm_px;
    break;
  case 40: //down
    armPosition-=armSpeed;
    if (armPosition < 0) armPosition = 0;
    break;
  default:
    println(keyCode);
    break;
  }
}

void mouseReleased() {
  int x = mouseX;
  int y = mouseY;
  
  // handle button action
  if (runBtn.isClicked(x, y)) {
    
    //check if we're running for real, or in sim mode
    if(SIM_MODE)  {
      
      // check if the sim is already running
      if(SIM_RUNNING) { // if so, then stop it
        
        // turn off the simulation
        SIM_RUNNING = false;
        runBtn.setActive(false);
        
       } else { // if not already running sim, then start it
      
        // clear the last sim drawing (if there is one)
        eraseDrawing();
        // clear out any unexecuted commands
        clearBotCode();
        // read the bot code again (fresh list of commands)
        readBotCode();
        
        // set flag to indicate sim is running
        SIM_RUNNING = true;
        
        // change the button state
        runBtn.setColor(orange);
        runBtn.setLabel("stop");
        runBtn.setActive(true);
      }
             
    } else if(BOT_RUNNING) { // if we're not in sim mode
      
      // the robot is running, let's stop the bot
      BOT_RUNNING = false;
      runBtn.setLabel("run");
      runBtn.setActive(false);
      
    } else { // else, let's fire it up!
    
      // clear the last sim drawing (if there is one)
      eraseDrawing();
      // clear out any unexecuted commands
      clearBotCode();
      // read the bot code again (fresh list of commands)
      readBotCode();
      
      BOT_RUNNING = true;
      runBtn.setColor(orange);
      runBtn.setLabel("stop");
      runBtn.setActive(true);
    }

  // if the simulation mode button is clicked
  } else if (simModeBtn.isClicked(x, y)) {
    
    SIM_MODE = true; // activates simulation mode

    simModeBtn.setActive(true);  // enable sim mode btn
    botModeBtn.setActive(false); // disable bot mode btn

  // if the robot mode button is clicked
  } else if (botModeBtn.isClicked(x, y)) {
    
    SIM_MODE = false; //disable sim mode, indicate bot mode
    botModeBtn.setActive(true); //enable bot mode btn
    simModeBtn.setActive(false); //disable sim mode btn
  
  } else if (botViewBtn.isClicked(x, y)) {
    
    if(SIM_RUNNING) { 
      SIM_RUNNING = false;
      runBtn.setLabel("run");
      runBtn.setActive(false);
    }
    
    eraseDrawing(); //clears last drawing (if there is one)
    
    ROBOT_VIEW = true; // activates robot view
    
    botViewBtn.setActive(true);  //enable robot view btn
    canViewBtn.setActive(false); // disable canvas view btn
    
  } else if(canViewBtn.isClicked(x, y)) {
    
    if(SIM_RUNNING) { 
      SIM_RUNNING = false;
      runBtn.setLabel("run");
      runBtn.setActive(false);
    }
   
    eraseDrawing(); //clears last drawing (if there is one)
    
    ROBOT_VIEW = false; // activates canvas view
    
    canViewBtn.setActive(true); // enable canvas view btn
    botViewBtn.setActive(false); //disable robot view btn
   
   
  }
}