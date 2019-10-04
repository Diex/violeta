//https://github.com/scanlime/fadecandy/blob/master/doc/processing_opc_client.md
OPC opc;
PImage dot;
import processing.video.*;

Movie movie;


void setup()
{
  size(640, 360);
  // Load and play the video in a loop
  movie = new Movie(this, "test_01-MPEG-4.mp4");
    //movie = new Movie(this, "sp.mp4");
  //movie = new Movie(this, "Blood - 21617.mp4");
  movie.loop();


  // Load a sample image
  dot = loadImage("dot.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "192.168.0.6", 7890);

  // Map an 8x8 grid of LEDs to the center of the window
  //opc.ledGrid(index, stripLength, numStrips, x, y, ledSpacing, stripSpacing, angle, zigzag, flip)
  //opc.ledGrid(0, 8, 8, width/2, height/2, height / 12.0, height / 12.0, 0, false, false); // 8x8
    opc.ledGrid(0, 32, 16, width/2, height/2, 8, 8, radians(90), true, false);
  //opc.ledGrid8x8(0, width/2, height/2, height / 12.0, 0, false, false);
}

void movieEvent(Movie m) {
  m.read();
}

int mx = 200;
int my = 55;

int ms = 0;
float sc = 1;
void draw()
{
  println(millis() - ms);
  ms = millis();
  
  background(0);
  
  pushMatrix();
  scale(sc);
  image(movie, mx, my, movie.width, movie.height);
  popMatrix();
  fill(0, 127);
  rect(0,0,width, height);
  //fill(random(255),random(255), random(255));
  //rect(0,0,width, height);
  //rect(mouseX, mouseY, 200, 300);
  
  // Draw the image, centered at the mouse location
  float dotSize = height * 0.5;
  //image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
  
  //rect(mouseX, mouseY, 160, 90);
  
  
  
}

void keyPressed(){
  if(keyCode == LEFT) mx -= 5;
  if(keyCode == RIGHT) mx += 5;
  if(keyCode == UP) my -= 5;
  if(keyCode == DOWN) my += 5;
  if(key == '=') sc += .1;
  if(key == '-') sc -= .1;
  println(mx, my);
}
void exit(){
  background(0);
  redraw();
  super.exit();
}
