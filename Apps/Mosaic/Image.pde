class Image {
  float b, decay;
  int index, x, y;
  PImage img;

  Image(int _index, PImage _img) {
    index = _index;
    x = int(index%cols)*cellWidth;
    y = int(index/cols)*cellHeight;
    img = _img;    
    b = analyze(img);
    decay = random(50, 150);
    //println("Brightness: " + b);
  }

  // When the frameRate is high, image decays too quickly
  float decay() {
    decay-= 10/frameRate;
    return decay;
  }  

  void update(int _index) {
    index = _index;
    x = int(index%cols)*cellWidth;
    y = int(index/rows)*cellHeight;
  }
  
  void display() {
    //tint(255, decay);
    image(img, x, y, cellWidth, cellHeight);
  }
  
  int getIndex() {
    return index;   
  }

  PImage getImage() {
    return img;
  }
  
  float getBrightness() {
    return b;
  }

  boolean isDead() {
    if (decay < 0)
      return true; 
    else
      return false;
  }
}

