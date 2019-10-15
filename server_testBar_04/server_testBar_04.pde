//https://github.com/scanlime/fadecandy/blob/master/doc/processing_opc_client.md
ESPOPC opc;
//OPC opc2;
//OPC opc3;
//OPC opc4;

PImage dot;
import processing.video.*;


Movie movie;

import java.io.IOException;
import java.net.InetAddress;


// routeradmin violeta:notabigdeal
// opc en python
// https://www.issackelly.com/blog/2014/07/28/snow-white-2
// fadecandy https://groups.google.com/forum/#!forum/fadecandy
//https://www.noction.com/blog/network-latency-effect-on-application-performance
// usar threads para cada socket // https://stackoverflow.com/questions/544924/maximum-size-of-data-that-can-be-fetched-from-a-client-socket-using-socketchanne
//https://stackoverflow.com/questions/34379504/significance-of-message-size-on-rtt-simple-java-server-client-socket-program

void setup()
{
  size(320, 128);

  opc = new ESPOPC(this);  
  opc.addDevice("dsp_01.local").ledGrid(0, 0, 16, 32);
  opc.addDevice("dsp_02.local").ledGrid(1, 0, 16, 32);
  opc.addDevice("dsp_03.local").ledGrid(2, 0, 16, 32);
  opc.addDevice("dsp_04.local").ledGrid(3, 0, 16, 32);
  opc.addDevice("dsp_05.local").ledGrid(4, 0, 16, 32);
  opc.addDevice("dsp_06.local").ledGrid(5, 0, 16, 32);
  opc.addDevice("dsp_07.local").ledGrid(6, 0, 16, 32);
  opc.addDevice("dsp_08.local").ledGrid(7, 0, 16, 32);  
  opc.addDevice("dsp_09.local").ledGrid(8, 0, 16, 32);
  opc.addDevice("dsp_10.local").ledGrid(9, 0, 16, 32);
  
  opc.addDevice("dsp_11.local").ledGrid(3, 1, 16, 32);
  opc.addDevice("dsp_12.local").ledGrid(4, 1, 16, 32);
  opc.addDevice("dsp_13.local").ledGrid(5, 1, 16, 32);
  opc.addDevice("dsp_14.local").ledGrid(6, 1, 16, 32);
  

  movie = new Movie(this, "videoplayback.mp4");
  movie.loop();
  movie.volume(0.0);
  frameRate(25);
}




boolean DEBUG = true;
int ms = 0;
void draw()
{
  if (millis() - ms > 100) {
    ms = millis();
    counter ++;
  }

  background(0);

  if (movie.available()) {
    movie.read();
  }

  image(movie, 0,0, width, height);
  //colorTestPattern();

  fill(0, 127);
  rect(0, 0, width, height);  
  
}

void keyPressed() {
  
}
void exit() {
  background(0);
  redraw();
  super.exit();
}
