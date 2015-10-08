void animateBot(float x, float y) {
  
  pushMatrix();

  //translate to top left of drawing canvas
  translate(canvas_top_left.x, canvas_top_left.y);

  // translate mouseX, mouseY to top left of canvas
  canvasX = x - canvas_top_left.x;
  canvasY = y - canvas_top_left.y;

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
    
  popMatrix();
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