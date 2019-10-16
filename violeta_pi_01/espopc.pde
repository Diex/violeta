/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
 * This file is released into the public domain.
 */

import java.net.*;
import java.util.Arrays;
import java.util.Map;

public class ESPOPC 
{
  PApplet parent;   

  
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
  void draw()
  {
    parent.loadPixels();
    // primero proceso los pixeles.
    for (Map.Entry<String, OpcDevice> device : devices.entrySet()) {
      device.getValue().draw();
    }

    String rtts = "";
    for (Map.Entry<String, OpcDevice> device : devices.entrySet()) {      
      rtts += device.getValue().writePixels();
    }
    //println(rtts);
  }

  
}


//////////////////////////////////////////////////////
