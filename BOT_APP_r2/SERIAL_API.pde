import processing.serial.*;
void serialEvent(Serial serial) {
 
  header = serial.readStringUntil('\n');
  
  if( header != null){
    
    header = trim(header);
    
    if(header.equals("ready") && !firstContact) {
      
      serial.clear();
      firstContact = true;
      serial.write(1); // send digital to initiate bot
      
    } else if(header.equals("next")) {
      
      SEND_NEXT_COORD = true;
      
    } else {
      
      println(header);
    }
  }
}