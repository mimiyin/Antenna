class Word {
  int index, x, y;
  String word;
  float decay;
  boolean isBlob;
  float [] randomColor = new float [3];

  Word(int _index, String _word, boolean _isBlob) {
    index = _index;
    word = _word;
    isBlob = _isBlob;

    x = int(index%cols)*cellWidth;
    y = int(index/cols)*cellHeight;

    decay = dRate;
  }

  // When the frameRate is high, image decays too quickly
  void decay() {
    decay--;
  }

  void recay() {
    decay += 100/frameRate; 
    decay = constrain(decay, 0, 255);
  }

  void update(String _word) {
    word = _word;
  }

  void randomizeColor() {
    randomColor = colors[int(random(colors.length))].getColor();
  }

  void display() {
    textAlign(LEFT, CENTER);
    noStroke();
    fill(255);
    rect(x, y, cellWidth, cellHeight);
    textFont(font);
    textSize(fSize);

    float alpha = 255;

    if (isFading)
      alpha = decay;

    if (isBlob) {
      fill(randomColor[0], randomColor[1], randomColor[2], alpha);
    }
    else
      fill(0, alpha);
    text(word, x + 15, y+cellHeight/2);
  }

  boolean isDead() {
    if (decay < random(-120*dRate, 0)) { 
      decay = dRate;
      return true;
    }
    else
      return false;
  }
}

