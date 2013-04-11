class Image {
  float b, decay;
  int index, x, y;
  PImage img;

  Image(int _index, PImage _img) {
    index = _index;
    x = int(index%cols)*cellWidth;
    y = int(index/rows)*cellHeight;
    img = _img;
    b = analyze(img);
    decay = 255;
    //println("Brightness: " + b);
  }

  // When the frameRate is high, image decays too quickly
  void decay() {
    decay-= 10/frameRate;
  }  

  void update(int _index) {
    index = _index;
    x = int(index%cols)*cellWidth;
    y = int(index/rows)*cellHeight;
  }

  int getIndex() {
    return index;   
  }
  
  void display() {
    tint(255, decay);
    image(img, x, y, cellWidth, cellHeight);
  }

  float getBrightness() {
    return b;
  }

  PImage getImage() {
    return img;
  }

  boolean isDead() {
    if (decay < 0)
      return true; 
    else
      return false;
  }
}

