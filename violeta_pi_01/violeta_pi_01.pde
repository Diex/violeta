import java.io.IOException;
import java.net.InetAddress;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.Scanner;
import java.util.Date;
import java.text.SimpleDateFormat;
import processing.video.*;


//https://github.com/scanlime/fadecandy/blob/master/doc/processing_opc_client.md
ESPOPC opc;


import gohai.glvideo.*;
GLMovie video;

Movie movie;

boolean debug = true;
int ms = 0;
Date date;


final int MOVIE = 1;
final int COLOR_BARS = 2;

int mode = MOVIE;



// routeradmin violeta:notabigdeal
// wifi violeta:18694888

// opc en python
// https://www.issackelly.com/blog/2014/07/28/snow-white-2
// fadecandy https://groups.google.com/forum/#!forum/fadecandy
//https://www.noction.com/blog/network-latency-effect-on-application-performance
// usar threads para cada socket // https://stackoverflow.com/questions/544924/maximum-size-of-data-that-can-be-fetched-from-a-client-socket-using-socketchanne
//https://stackoverflow.com/questions/34379504/significance-of-message-size-on-rtt-simple-java-server-client-socket-program


// 1536*12*14/1024 = 252
void setup()
{
  size(320, 128,P2D);

  date = new Date();

  PrintStream origOut = System.out;
  PrintStream interceptor = new Interceptor(origOut);
  System.setOut(interceptor);


  opc = new ESPOPC(this);


//  opc.addDevice("dsp_01.local").ledGrid(0, 0, 16, 32);
//  opc.addDevice("dsp_02.local").ledGrid(1, 0, 16, 32);
  //opc.addDevice("dsp_03.local").ledGrid(2, 0, 16, 32);
  //opc.addDevice("dsp_04.local").ledGrid(3, 0, 16, 32);
  //opc.addDevice("dsp_05.local").ledGrid(4, 0, 16, 32);
//  opc.addDevice("dsp_06.local").ledGrid(5, 0, 16, 32);
//  opc.addDevice("dsp_07.local").ledGrid(6, 0, 16, 32);
//  opc.addDevice("dsp_08.local").ledGrid(7, 0, 16, 32);
//  opc.addDevice("dsp_09.local").ledGrid(8, 0, 16, 32);
//  opc.addDevice("dsp_10.local").ledGrid(9, 0, 16, 32);

//  opc.addDevice("dsp_11.local").ledGrid(3, 1, 16, 32);
//  opc.addDevice("dsp_12.local").ledGrid(4, 1, 16, 32);
//  opc.addDevice("dsp_13.local").ledGrid(5, 1, 16, 32);
//  opc.addDevice("dsp_14.local").ledGrid(6, 1, 16, 32);

  opc.addDevice("dsp_16.local").ledGrid(6, 1, 16, 32);
  opc.start();

//  movie = new Movie(this, "china.mp4");
//  movie.loop();
//  movie.volume(0.0);
  video = new GLMovie(this, "china.mp4");
  video.loop();  
  frameRate(30);
}


int lastFrame = 0;

void draw()
{

  if (debug) {
    //println("new frame: \t" + millis());
    //println((millis() - lastFrame));
  }

  background(0);

  switch(mode) {

  case MOVIE:
    //if (movie.available()) {
    //  movie.read();
    //}
    //image(movie, 0, 0, width, height);
    
    if (video.available()) {
    video.read();
  }
  image(video, 0, 0, width, height);
    break;

  case COLOR_BARS:
    colorTestPattern();  
    break;
  }

  ndfilter(127);
  lastFrame = millis();
}

void ndfilter(int value) {
  fill(0, value);
  rect(0, 0, width, height);
}


void keyPressed() {
  if (key == ' ') {
    mode = mode == MOVIE ? COLOR_BARS : MOVIE;
  }
}

void exit() {
  ((Interceptor) System.out).close();
  background(0);
  redraw();
  super.exit();
}

private class Interceptor extends PrintStream
{
  PrintWriter errors;

  public Interceptor(OutputStream out)
  {
    super(out, true);
    errors = createWriter("./logs/log_"+date.getTime()+".txt");
    //errors = createWriter("log_"+date.getTime()+".txt");
  }

  @Override
    public void print(String s)
  {
    //do what ever you like        
    errors.println(s);
    errors.flush(); // Writes the remaining data to the file
    super.print(s);
  }

  public void close() {

    errors.close(); // Finishes the file
  }
}
