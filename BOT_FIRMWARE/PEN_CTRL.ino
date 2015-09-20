void penDown() {
  penSrv.attach(PEN_SERVO_PIN);
  penSrvReady = false;
  while(abs(penSrvVal - penDownPos) > 0.01) {
    penSrvVal += (penSrvVal < penDownPos) ? penSrvSpd : -penSrvSpd;
    penSrv.write(penSrvVal);
  }
  penSrvVal = penDownPos;
  penSrvReady = true;
  penSrv.detach();
}

void penUp() {
  penSrv.attach(PEN_SERVO_PIN);
  penSrvReady = false;
  while(abs(penSrvVal - penUpPos) > 0.01) {
    penSrvVal += (penSrvVal < penUpPos) ? penSrvSpd : -penSrvSpd;
    penSrv.write(penSrvVal);
  }
  penSrvVal = penUpPos;
  penSrvReady = true;
  penSrv.detach();
}
