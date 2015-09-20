import processing.serial.*;

int PORT_NUM = 2; // change to match your port number
                  // use Serial.list() to find port

Serial serial;
String val;
String header;
boolean firstContact = false;
PFont font;

ToggleButton penDown; 
ArrowButton 
  penForwardBtn,
  penBackwardBtn,
  penRightBtn,
  penLeftBtn;

void setup() {
  
  size(400,400);
  smooth();
  rectMode(CENTER);
  font = loadFont("Consolas-12.vlw");
  textFont(font, 12);

  boolean isPenDown = false;
  
  // instantiate arrow buttons
  penForwardBtn  = new ArrowButton("up",    new PVector(width/2, 75), 75);
  penBackwardBtn = new ArrowButton("down",  new PVector(width/2, 325), 75);
  penRightBtn    = new ArrowButton("right", new PVector(325, height/2), 75);
  penLeftBtn     = new ArrowButton("left",  new PVector(75, height/2), 75);
  
  penDown = new ToggleButton(new PVector(width/2, height/2), 50);
  println("[ PORT_NUM ] : /dev/PORT_NAME \n"); 
  for(int i = 0; i < Serial.list().length; i++) {
    println(" [ " + i + " ] : " + Serial.list()[i]); 
  }

  String port = Serial.list()[PORT_NUM];
  serial = new Serial(this, port, 115200);
  
  //trigger the serialEvent when a return '\n' is read
  serial.bufferUntil('\n');
}

void draw() {
  
  background(150);
  
  fill(0);
  text("Bot Control", 10, 20);
  fill(75);
  text("forward", width/2 - 25, 60);
  text("backward", width/2 - 28, 350);
  text("left", 35, height/2);
  text("right", 338, height/2);
  
  if(mousePressed) {
    
   if(penForwardBtn.isClicked(mouseX, mouseY)) {
     
     penForwardBtn.setHitState(true);
     
   } else if(penBackwardBtn.isClicked(mouseX, mouseY)) {
     
     penBackwardBtn.setHitState(true);
     
   } else if(penRightBtn.isClicked(mouseX, mouseY)) {
     
     penRightBtn.setHitState(true);
   
   } else if(penLeftBtn.isClicked(mouseX, mouseY)) {
     
      penLeftBtn.setHitState(true);
   }
  }
  
  // render arrow buttons
  penForwardBtn.render();
  penBackwardBtn.render();
  penRightBtn.render();
  penLeftBtn.render();
  penDown.render();
  
  
//  while (serial.available() > 0) {
//    
//    char inByte = serial.readChar();
//    print(inByte);
//  }

}

void serialEvent(Serial serial){
  header = serial.readStringUntil('\n');
  if( header != null){
    header = trim(header);
//    println("received: "+header);
    if(header.equals("!!") && firstContact == false){
      serial.clear();
      firstContact = true;
      serial.write("!!");
      println("contacted");
    }else{
      println(header);
    }
  }
}

void keyPressed() {
  
  switch(keyCode) {
    case 38: // up key (forward)
      serial.write("f");
      break;
    case 40: // down key (backward)
      serial.write("k");
      break;
    case 37: // left key (left)
      serial.write("l");
      break;
    case 39: // right
      serial.write("r");
      break;
    case 32: //space
      penDown.toggle();
      break;
    default:
      break;
  }
}

void keyReleased() {
  switch(keyCode) {
    case 38: // up key (forward)
      serial.write("sf");
      break;
    case 40: // down key (backward)
      serial.write("sk");
      break;
    case 37: // left key (left)
      serial.write("sl");
      break;
    case 39: // right
      serial.write("sr");
      break;
    default:
      break;
  }
}

void mousePressed() {
  
   if(penForwardBtn.isClicked(mouseX, mouseY)) {
     
     serial.write("f");
     
   } else if(penBackwardBtn.isClicked(mouseX, mouseY)) {
     
     serial.write("k");
     
   } else if(penRightBtn.isClicked(mouseX, mouseY)) {
     
     serial.write("r");
   
   } else if(penLeftBtn.isClicked(mouseX, mouseY)) {
     
      serial.write("l");
   }
}
void mouseReleased() {
  
  if(penDown.isClicked(mouseX, mouseY)) {
     
    penDown.toggle();
     
  } else if(penForwardBtn.isClicked(mouseX, mouseY)) {
     
     serial.write("sf");
     
   } else if(penBackwardBtn.isClicked(mouseX, mouseY)) {
     
     serial.write("sk");
     
   } else if(penRightBtn.isClicked(mouseX, mouseY)) {
     
     serial.write("sr");
   
   } else if(penLeftBtn.isClicked(mouseX, mouseY)) {
     
      serial.write("sl");
   }
}

void serialListener(){
}

/**
 *
 * @class ToggleButton
 *
 * Creates an interactive toggle switch
 *
 */

class ToggleButton {
  
  PVector position;
  int     size;
  boolean isActive;
  
  ToggleButton(PVector position, int size) {
    this.position = position;
    this.size = size;
  }
  
  public void render() {
    rectMode(CENTER);
    noFill();
    stroke(0);
    rect(this.position.x, this.position.y, size, size);  
    if(isActive) {
      noStroke();
      fill(0);
      rect(this.position.x, this.position.y, size * .75, size * .75);  
    } else {
      noStroke();
      rect(this.position.x, this.position.y, size * .75, size * .75);  
    }
  }
  
  public void toggle() {
    isActive = !isActive;
    if(isActive) {
      serial.write("d");
    } else {
      serial.write("u"); 
    }
  }
  
  public boolean isClicked(int x, int y) {
    return dist(mouseX, mouseY, this.position.x, this.position.y) < this.size/2;  
  }
}

/**
 *
 * @class ArrowButton
 *
 * Creates an interactive arrow-shaped button
 *
 */
 
class ArrowButton {
  
 PVector tip;
 int size;
 String dir;
 boolean isHit = false;
 long lastHit;
 
 ArrowButton(String dir, int size) {
   
   this.dir = dir;
   this.tip = new PVector(width/2,height/2);
   this.size = size;
 }
 
 ArrowButton(String dir, PVector tip, int size) {
   
   this.dir = dir;  
   this.tip = tip;
   this.size = size; 
 }
 
 void moveTo(int mouseX, int mouseY) {
   
    this.tip.x = mouseX;
    this.tip.y = mouseY;
 }
 
 public boolean isClicked(int mouseX, int mouseY) {
   
   return dist(mouseX, mouseY, this.tip.x, this.tip.y) < this.size;
 }
 
 public void setHitState(boolean state) {
   
   isHit = state;
   lastHit = millis();
 }
 
 public void render() { 
   
   rectMode(CENTER);
   noStroke();
   
   if(isHit) {
     fill(75); 
   } else {
     fill(0);
   }
   if(millis() - lastHit > 110) {
     isHit = false; 
   }
   
   if(dir == "up") {
     triangle(
       this.tip.x - this.size/2, 
       this.tip.y + this.size/2, 
       this.tip.x, //  tip.x
       this.tip.y, //  tip.y
       this.tip.x + this.size/2,
       this.tip.y + this.size/2
     );
     rect(
       this.tip.x, 
       this.tip.y + this.size/2,
       this.size/2, this.size/2
     );
   }
 
   if(dir == "down") {
     triangle(
       this.tip.x - this.size/2, 
       this.tip.y - this.size/2, 
       this.tip.x, //  tip.x
       this.tip.y, //  tip.y
       this.tip.x + this.size/2,
       this.tip.y - this.size/2
       );
     rect(
       this.tip.x, 
       this.tip.y - this.size/2,
       this.size/2, this.size/2
     );
   }
   
   if(dir == "left") {
     triangle(
       this.tip.x + this.size/2, 
       this.tip.y - this.size/2, 
       this.tip.x, //  tip.x
       this.tip.y, //  tip.y
       this.tip.x + this.size/2,
       this.tip.y + this.size/2
     );
     rect(
       this.tip.x + this.size/2, 
       this.tip.y,
       this.size/2, this.size/2
     );
   }
   
   if(dir == "right") {
     triangle(
       this.tip.x - this.size/2, 
       this.tip.y - this.size/2, 
       this.tip.x, //  tip.x
       this.tip.y, //  tip.y
       this.tip.x - this.size/2,
       this.tip.y + this.size/2
     );
     rect(
       this.tip.x - this.size/2, 
       this.tip.y,
       this.size/2, this.size/2
     );
   }
 }
}