
// PUT YOUR ROBOT CODE HERE !!!

void myRobotCode () {
  
  /* EXAMPLE 1: DRAW A BOX
   *******************************************/
  
  /*
  moveTo( 300, 150 ); // move to center
  
  penDown(); // note: pen always starts in up position
  
  moveTo( 500, 150 );
  
  moveTo( 500, 350 );
  
  moveTo( 300, 350 );
  
  moveTo( 300, 150 );
  
  penUp();
  
  */
  
  /* EXAMPLE 2: DRAW A CIRCLE
   *******************************************/
 
  /*
  
  int   angles = 12; // try changing the angles to 12, 8, 6 and 4
  float radius = 50;
  
  float h = width/2;
  float k = height/2;
    
  moveTo(width/2 + radius, height/2);
  penDown();
  
  for(int i = 0; i < angles; i++) {
    
    float a = 360/angles * i;
    
    //draw an ellipse based on the squash factor
    float x = h + radius * cos(radians(a));
    float y = k + radius * sin(radians(a));

    moveTo( x, y );
  }
  
  moveTo(width/2 + radius, height/2);
  penUp();
  
  */
  
  
  /* EXAMPLE 3: DRAW AN OVAL
   *******************************************/
  
  /*
  
  int   angles = 360;
  float radius = 300;
  int   offset = 0;
  
  float h = width/2;
  float k = height/2;
    
  float squashFactor = 0.5;
  
  moveTo(width/2 + radius, height/2);
  penDown();
  
  for(int i = 0; i < angles; i++) {
    
    float a = 360/angles * i;
    
    //draw an ellipse based on the squash factor
    float x = h + radius * cos(radians(a));
    float y = k - squashFactor * radius * sin(radians(a));

    moveTo( x, y );
  }
  
  moveTo(width/2 + radius, height/2);
  penUp();
  
  */
  
  /* EXAMPLE 4: DRAW A STAR
   *******************************************/
  
  /*
  
  moveTo(400, 250);
  
  penDown();

  float   alpha  = (float) (2 * Math.PI) / 10; 
  float   radius = 250;
  PVector starCoords = new PVector(400, 250);
  
  for(int i = 11; i != 0; i--) {
    
    float r = radius*(i % 2 + 1)/2;
    float omega = alpha * i;
    
    if(i == 11) {
      penUp();
    } else {
      penDown();
    }
    
    moveTo( r * sin(omega) + starCoords.x, r * cos(omega) + starCoords.y);
  }
  
  penUp();
  
 */
 
 /* EXAMPLE 5: SPIDER WEB
   *******************************************/
   
  int   angles = 30; // try changing the angles to 12, 8, 6 and 4
  float radius = 100;
  
  float h = width/2;
  float k = height/2;
      
  for(int l = 0; l < angles; l++) {
    
    moveTo(width/2 + .1 * l * radius, height/2);
    
    penDown();
    
    for(int i = 0; i < angles; i++) {
      
      float a = 360/angles * i;
     
      float x = h + .1 * l * radius * cos(radians(a));
      float y = k + .1 * l * radius * sin(radians(a));
  
      moveTo(x, y);
    }
    
    moveTo(width/2 + .1 * l * radius, height/2);
    
    penUp();
    
  }
  
  penUp();
 
  
  /* EXAMPLE 6: INCREASING CURVES
   *******************************************/ 
  /*
  float x = 0;
  float y = 0;
  float scale = 0;
    
  for(int i = 0; i < 10; i++) {
    
    scale += 0.01;
    
    x = 0;
    y = 0;
    
    penUp();
    
    while(x < width) {
      
      x++;
      
      y = pow(x * scale, 2) * -1 + height;
      
      println(y);
      
      
      moveTo( x, y );
      
      if(x == 1) penDown();
    }
  }
  
  penUp();
  */
  
   
}