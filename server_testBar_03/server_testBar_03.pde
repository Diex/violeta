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
  

  movie = new Movie(this, "china.mp4");
  movie.loop();
  movie.volume(0.0);
  frameRate(20);
}




int mx = 200;
int my = 55;

int ms = 0;
float sc = 1;

color c_0 = color(255, 255, 255);
color c_1 = color(255, 255, 0);
color c_2 = color(0, 255, 255);
color c_3 = color(0, 255, 0);
color c_4 = color(255, 0, 255);
color c_5 = color(255, 0, 0);
color c_6 = color(0, 0, 255);
color c_7 = color(0, 0, 0);

color[] colors = {c_0, c_1, c_2, c_3, c_4, c_5, c_6, c_7};

int counter = 0;
boolean DEBUG = true;
void draw()
{
  if (millis() - ms > 50) {
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
  //updatePixels();
}

void keyPressed() {
  if (keyCode == LEFT) mx -= 5;
  if (keyCode == RIGHT) mx += 5;
  if (keyCode == UP) my -= 5;
  if (keyCode == DOWN) my += 5;
  if (key == '=') sc += .1;
  if (key == '-') sc -= .1;
  //println(mx, my);
}
void exit() {
  background(0);
  redraw();
  super.exit();
}
