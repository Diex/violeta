class OpcDevice implements Runnable {

  Thread thread;
  private int[] pixelLocations;
  private String host;
  private int port;

  Socket socket;
  OutputStream output, pending;

  byte[] packetData;
  boolean enableShowLocations;

  HashMap addresses;

  PApplet parent;

  OpcDevice(PApplet parent, String host, int port) {
    thread = new Thread(this);
    //thread.start();
    this.parent = parent;
    this.enableShowLocations = true;
    this.host = host;
    this.port = port;
    addresses = new HashMap<String, String>();
  }

  boolean canrun = false;
  public void run()
  {
    // Thread tests server connection periodically, attempts reconnection.
    // Important for OPC arrays; faster startup, client continues
    // to run smoothly when mobile servers go in and out of range.
    for (;; ) {
      try {
        //if(canrun)  {
          writePixelsThreaded();
          //canrun = false;
        //}
      }
      catch (Exception e) {
        if (debug) println(e);
      }

//      // Pause thread to avoid massive CPU load
      try {
        Thread.sleep(10);
      }
      catch(InterruptedException e) {
      }
    }
  }

  int panelw = 16;
  int panelh = 32;

  void ledGrid(float x, float y, float w, float h) {

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
  void ledGrid(int index, int stripLength, int numStrips, float x, float y, 
    float ledSpacing, float stripSpacing, float angle, boolean zigzag, 
    boolean flip)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength, 
        x + (i - (numStrips-1)/2.0) * stripSpacing * c, 
        y + (i - (numStrips-1)/2.0) * stripSpacing * s, ledSpacing, 
        angle, zigzag && ((i % 2) == 1) != flip);
    }

    setPixelCount(pixelLocations.length);
  }

  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i), 
        (int)(x + (i - (count-1)/2.0) * spacing * c + 0.5), 
        (int)(y + (i - (count-1)/2.0) * spacing * s + 0.5));
    }
  }


  // Set the location of a single LED
  void led(int index, int x, int y)  
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
  void setPixelCount(int numPixels)
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

  void draw() {
    if (pixelLocations == null) {
      return;
    }

    if (output == null) {      
      return;
    }


    pmillis = millis();
    int ledAddress = 4;
    for (int i = 0; i < pixelLocations.length; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = parent.pixels[pixelLocation];
      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;
    }
  }

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  String writePixelsThreaded()
  {
    if (packetData == null || packetData.length == 0) {
      return "null \t";
    }
    if (output == null) {
      return "null \t";
    }
    try {
      output.write(packetData);
    } 
    catch (Exception e) {
      dispose();
    }
    return "" + (millis() - pmillis) + '\t';
  }
  
  String writePixels(){
    canrun = true;
    return "" + (millis() - pmillis) + '\t';
  }


  void keepConnected() {  
    if (this.output == null) { // No OPC connection?
      try {              // Make one!
        if (debug) println("trying to connect: " + port + ":"+ host);
        socket = new Socket();

        //socket.setPerformancePreferences(0,1,0); // esto no hace nada.. no está implementado...
        String ip;
        if (addresses.containsKey(host)) {
          ip = (String) addresses.get(host);
        } else {
          String resolved = InetAddress.getByName(host).getCanonicalHostName();
          addresses.put(host, resolved);
          ip = resolved;
        }        
        socket.connect(new InetSocketAddress(ip, port), 100);        
        socket.setTcpNoDelay(true);
        pending = socket.getOutputStream(); // Avoid race condition...
        if (debug)  println("Connected to OPC server");
        if (debug) System.out.println("socket: " +socket);
        output = pending;                   // rest of code given access.
        // pending not set null, more config packets are OK!
      } 
      catch (ConnectException e) {
        if (debug)  println(e.getMessage());
        dispose();
      } 
      catch (IOException e) {
        if (debug)   println(e.getMessage());
        dispose();
      }
    }
  }

  void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    // (Thread continues to run)
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = pending = null;
  }
}
