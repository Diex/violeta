
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


void colorTestPattern(){
  
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
