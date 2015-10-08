PVector getPolar(float x, float y) {
  
  float radius = sqrt( sq(x) + sq(y) );
  float angle  = (atan2(y, x));// * 180/PI); 
  
  return new PVector(radius, angle);
}