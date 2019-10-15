/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */

import java.net.*;
import java.util.Arrays;

public class ESPOPC implements Runnable
{
  PApplet parent;   
  Thread thread;
  ArrayList<OpcDevice> devices;

  ESPOPC(PApplet parent)
  {
    this.parent = parent;
    devices = new ArrayList<OpcDevice>();
    thread = new Thread(this);
    thread.start();
    parent.registerMethod("draw", this);
  }

  public OpcDevice addDevice(String host) {
    OpcDevice d = new OpcDevice(parent, host, 7890);
    devices.add(d);
    return d;
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  void draw()
  {
    parent.loadPixels();
    // primero proceso los pixeles.
    for (OpcDevice d : devices) {
      d.draw();     
    }

    String latency = "";
    // y luego transmito para mejorar la performance
    for (OpcDevice d : devices) {
      latency += d.writePixelsThreaded();
      
      //for(OpcDevice d : devices){
      //    d.writePixelsThreaded();
      //  }
        
      
      
    }
    println(latency);
  }

  public void run(){
  
    for (;;) {
      try {
        for(OpcDevice d : devices){
          d.keepConnected();
        }        
      }
      
      
      catch (Exception e) {
        if (debug) println(e);
      }

      // Pause thread to avoid massive CPU load
      try {
        Thread.sleep(500);
      }
      catch(InterruptedException e) {
      }
    }
     
  }
  
}


//////////////////////////////////////////////////////
