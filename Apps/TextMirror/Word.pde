class Word {
  int index, x, y;
  String word;
  float decay;
  boolean isBlob;

  Word(int _index, String _word, boolean _isBlob) {
    index = _index;
    word = _word;
    isBlob = _isBlob;
    
    x = int(index%cols)*cellWidth;
    y = int(index/cols)*cellHeight;

    decay = 255;
  }

  // When the frameRate is high, image decays too quickly
  float decay() {
    decay-= 100/frameRate;
    //println("DECAY: " + decay);
    return decay;
  }

  void recay() {
    decay += 100/frameRate; 
    decay = constrain(decay, 0, 255);
  }

  void update(String _word) {
    word = _word;
  }

  void display() {
    textAlign(LEFT, CENTER);
    noStroke();
    fill(255);
    rect(x, y, cellWidth, cellHeight);
    textFont(font);
    textSize(fSize);
    if (isBlob)
      fill(0, 255, 255, decay);
    else
      fill(0, decay);
    text(word, x + 15, y+cellHeight/2);
  }

  boolean isDead() {
    if (decay < random(-3000, 0)) { 
      decay = 255;
      return true;
    }
    else
      return false;
  }
}

