import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.IOException; 
import java.net.InetAddress; 
import java.io.FileNotFoundException; 
import java.io.PrintStream; 
import java.util.Scanner; 
import java.util.Date; 
import java.text.SimpleDateFormat; 
import processing.video.*; 
import VLCJVideo.*; 
import java.net.*; 
import java.util.Arrays; 
import java.util.Map; 
import java.nio.*; 
import java.nio.channels.SocketChannel; 
import java.io.BufferedOutputStream; 

import javax.jmdns.*; 
import javax.jmdns.impl.*; 
import javax.jmdns.impl.constants.*; 
import javax.jmdns.impl.tasks.*; 
import javax.jmdns.impl.tasks.resolver.*; 
import javax.jmdns.impl.tasks.state.*; 
import javax.jmdns.test.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class violeta_pi_01 extends PApplet {











//https://github.com/scanlime/fadecandy/blob/master/doc/processing_opc_client.md
ESPOPC opc;



VLCJVideo video;


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
public void setup()
{
  

  date = new Date();

  PrintStream origOut = System.out;
  PrintStream interceptor = new Interceptor(origOut);
  System.setOut(interceptor);


  opc = new ESPOPC(this);


  opc.addDevice("dsp_01.local").ledGrid(0, 0, 32, 64);
  opc.addDevice("dsp_02.local").ledGrid(1, 0, 32, 64);
  
  opc.addDevice("dsp_03.local").ledGrid(2, 0, 32, 64);
  opc.addDevice("dsp_04.local").ledGrid(3, 0, 32, 64);
  opc.addDevice("dsp_05.local").ledGrid(4, 0, 32, 64);
  opc.addDevice("dsp_06.local").ledGrid(5, 0, 32, 64);
  opc.addDevice("dsp_07.local").ledGrid(6, 0, 32, 64);
  opc.addDevice("dsp_08.local").ledGrid(7, 0, 32, 64);
  
  opc.addDevice("dsp_09.local").ledGrid(8, 0, 32, 64);
  opc.addDevice("dsp_10.local").ledGrid(9, 0, 32, 64);

  opc.addDevice("dsp_11.local").ledGrid(3, 1, 32, 64);
  opc.addDevice("dsp_12.local").ledGrid(4, 1, 32, 64);
  opc.addDevice("dsp_13.local").ledGrid(5, 1, 32, 64);
  opc.addDevice("dsp_14.local").ledGrid(6, 1, 32, 64);
  opc.addDevice("dsp_15.local").ledGrid(6, 1, 32, 64);
  opc.addDevice("dsp_16.local").ledGrid(6, 1, 32, 64);
  
  opc.start();
  video = new VLCJVideo(this);
  video.openMedia("Frutas_V4_H264.mov");
  video.play();
  frameRate(10);
}


int lastFrame = 0;
int videoY = -96;
public void draw()
{

  if (debug) {
    //println("new frame: \t" + millis());
    //println((millis() - lastFrame));
  }

  background(0);

  switch(mode) {
 
  case MOVIE:
 if(video.isPlaying()){
   //println(video.time());
   opc.breath = false;
   lastFrame = millis();
   image(video, 0, videoY, width, height*2);  
 }else{
   background(0);
   opc.breath = true;
   if(millis() - lastFrame > 5000) {     
     video.play();     
   }
 }
    break;

  case COLOR_BARS:
    colorTestPattern();  
    break;
  }

  ndfilter(127);
  
}

public void ndfilter(int value) {
  fill(0, value);
  rect(0, 0, width, height);
}


public void keyPressed() {
  if (key == ' ') {
    mode = mode == MOVIE ? COLOR_BARS : MOVIE;
  }
  
  if(key == '+'){
    videoY--;
    println("video y : " + videoY);
  }
}

public void exit() {
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
/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */





public class ESPOPC 
{
  PApplet parent;   
  boolean breath = false;
  
  HashMap<String, OpcDevice> devices;

  ESPOPC(PApplet parent)
  {
    this.parent = parent;
    devices = new HashMap<String, OpcDevice>();
    parent.registerMethod("draw", this);
  }


  public OpcDevice addDevice(String host) {
    OpcDevice d = new OpcDevice(parent, host, 7890);
    devices.put(host, d);
    return d;
  }

  public void start(){
    for (Map.Entry<String, OpcDevice> device : devices.entrySet()) {
      device.getValue().thread.start();
    }
  }
  
  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  public void draw()
  {
    parent.loadPixels();
    if(breath) return;
    // primero proceso los pixeles.
    for (Map.Entry<String, OpcDevice> device : devices.entrySet()) {
      device.getValue().draw();
    }

    String rtts = "";
    for (Map.Entry<String, OpcDevice> device : devices.entrySet()) {      
      rtts += device.getValue().writePixels();
    }
    
  }

  
}


//////////////////////////////////////////////////////



//import java.net.SocketOutputStream;
class OpcDevice implements Runnable {

  Thread thread;
  private int[] pixelLocations;
  private String host;
  private String resolved;
  private int port;


  //OutputStream output, pending;
  BufferedOutputStream output, pending;
  //SocketOutputStream output, pending;
  byte[] packetData;


  PApplet parent;
  boolean canrun = true;

  OpcDevice(PApplet parent, String host, int port) {
    thread = new Thread(this);
    this.parent = parent;  
    this.host = host;
    this.port = port;


    //try{
    //  socket = SocketChannel.open();
    //}catch (IOException e){
    //  e.printStackTrace();
    //}
  }


  public void run()
  {
    while (true) {
      // Thread tests server connection periodically, attempts reconnection.
      // Important for OPC arrays; faster startup, client continues
      // to run smoothly when mobile servers go in and out of range.

      keepConnected();

      if (canrun) {          
        writePixelsThreaded();              
        canrun = false;
        pmillis = millis();
      } else {
      }

      try {
        Thread.sleep(50);
      }
      catch (Exception e) {
      }
    }
  }

  //SocketChannel socket;
  Socket socket;
  public boolean keepConnected() {

    if (this.output == null) { // No OPC connection?
      //if(socket != null && !socket.isConnected()){
      try {              // Make one!

        socket = new Socket();

        //println(socket);
        if (debug) println("trying to connect: " + host + ":"+ port);
        if (resolved == null) {
          resolved = InetAddress.getByName(host).getCanonicalHostName();
        }        

        socket.connect(new InetSocketAddress(resolved, port));

        //socket.connect(new InetSocketAddress(resolved, port), 100);        
        socket.setTcpNoDelay(true);

        pending =  new BufferedOutputStream(socket.getOutputStream()); // Avoid race condition...
        //pending =  socket.getOutputStream(); // Avoid race condition...
        if (debug)  println("Connected to OPC server");
        if (debug) System.out.println("socket: " +socket);
        output = pending;                   // rest of code given access.
        // pending not set null, more config packets are OK!
      } 
      catch (ConnectException e) {
        if (debug)  println(e.getMessage());
        dispose();
        return false;
      } 
      catch (IOException e) {
        if (debug)   println(e.getMessage());
        dispose();
        return false;
      }
      return true;
    }
    return true;
  }

  public void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    // (Thread continues to run)
    if (output != null) {
      println("Disconnected from OPC server");
    }
    //socket = null;
    try {
      if (socket != null) socket.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }

    output = pending = null;
  }

  int panelw = 16;
  int panelh = 32;

  public void ledGrid(float x, float y, float w, float h) {

    // 0, 0, 32, 64

    float hgap = w/panelw;  
    float vgap = h/panelh;

    ledGrid(0, panelh, panelw, 
      (w/2) + x * w, 
      (h/2) + y * h, 
      hgap, vgap, 
      radians(-90), true, false);
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  public void ledGrid(int index, int stripLength, int numStrips, float x, float y, 
    float ledSpacing, float stripSpacing, float angle, boolean zigzag, 
    boolean flip)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength, 
        x + (i - (numStrips-1)/2.0f) * stripSpacing * c, 
        y + (i - (numStrips-1)/2.0f) * stripSpacing * s, ledSpacing, 
        angle, zigzag && ((i % 2) == 1) != flip);
    }

    setPixelCount(pixelLocations.length);
  }

  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  public void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i), 
        (int)(x + (i - (count-1)/2.0f) * spacing * c + 0.5f), 
        (int)(y + (i - (count-1)/2.0f) * spacing * s + 0.5f));
    }
  }


  // Set the location of a single LED
  public void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + parent.width * y;
  }


  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  public void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    int packetLen = 4 + numBytes;
    if (packetData == null || packetData.length != packetLen) {
      // Set up our packet buffer
      packetData = new byte[packetLen];
      packetData[0] = (byte)0x00;              // Channel
      packetData[1] = (byte)0x00;              // Command (Set pixel colors)
      packetData[2] = (byte)(numBytes >> 8);   // Length high byte
      packetData[3] = (byte)(numBytes & 0xFF); // Length low byte
    }
  }

  int pmillis = 0;

  public void draw() {
    if (pixelLocations == null) {
      return;
    }

    if (output == null) {      
      return;
    }
    int ledAddress = 4;
    for (int i = 0; i < pixelLocations.length; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = parent.pixels[pixelLocation];
      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;
    }

    //canrun = true;
  }

  public void writePixelsThreaded()
  {
    try {
      //ByteBuffer buf = ByteBuffer.allocate(packetData.length);
      //buf.clear();
      //buf.put(packetData);
      //buf.flip();
      //while (buf.hasRemaining()) {
      //  socket.write(buf);
      //}

      //println(buf.hasRemaining());

      output.write(packetData);
      output.flush();
    } 
    catch (Exception e) {
      dispose();
    }
  }

  public String writePixels() {
    canrun = true;
    return "" + (millis() - pmillis) + '\t';
  }
}

int c_0 = color(255, 255, 255);
int c_1 = color(255, 255, 0);
int c_2 = color(0, 255, 255);
int c_3 = color(0, 255, 0);
int c_4 = color(255, 0, 255);
int c_5 = color(255, 0, 0);
int c_6 = color(0, 0, 255);
int c_7 = color(0, 0, 0);

int[] colors = {c_0, c_1, c_2, c_3, c_4, c_5, c_6, c_7};

int counter = 0;


public void colorTestPattern(){
  
  if (millis() - ms > 100) {
      ms = millis();
     // counter ++;
    }

  int barHeight = height/8;
  int barWidth = width/8;
  noStroke();
  
  for(int y = 0; y < 8; y++){
    fill(colors[(y + counter ) % 8]);
    rect(0, barHeight * y, width, barHeight * (y+1));  
    //rect(y * barWidth, 0, (y+1) * barWidth, height);
  }
}

//ColorBar a = new ColorBar(100);

//void colorful(){
//  a.render();
    

//}


//class ColorBar{


//  int cols[] = new int[width];
//  int height = 100;
//  int newCol = 0;
  
//  ColorBar (int height){
//    this.height = height;
//    for(int col: cols) col = 0;    
//  }
  
//  void render(){
//    for(int col = 0; col < cols.length - 1 ; col++){
//      cols[col] = cols[col+1];
//    }
    
//    cols[cols.length - 1] = newCol;
    
//    for(int col: cols) {
//      stroke(col);
//      line(0,0,0, height);
//    }
//  }
  
  
  
//}
  public void settings() {  size(320, 128,P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "violeta_pi_01" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
