import processing.serial.*;
Serial serial;
String val;
String header;
boolean firstContact = false;

void serialEvent(Serial serial) {
  
  header = serial.readStringUntil('\n');
  if( header != null){
    header = trim(header);
    
    if(header.equals("ready") && firstContact == false){
      serial.clear();
      firstContact = true;
      serial.write("bot is ready");
      println("contacted");
    } else{
      println(header);
    }
  }
}