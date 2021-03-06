class Word {
  int index, x, y;
  String word;
  String [] letters;
  float decay;
  boolean isBlob;
  float [] randomColor = new float [3];

  Word(int _index, String _word, boolean _isBlob) {
    index = _index;
    word = _word;
    characterize();
    isBlob = _isBlob;
    
    randomizeColor();

    x = int(index%cols)*cellWidth;
    y = int(index/cols)*cellHeight;

    decay = dRate;
  }

  // When the frameRate is high, image decays too quickly
  void decay() {
    decay--;
  }

  void update(String _word) {
    word = _word;
    characterize();
  }
  
  void characterize() {
     letters = word.split(""); 
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

    if (isBlob) {
      fill(randomColor[0], randomColor[1], randomColor[2], alpha);
    }
    else
      fill(grey, alpha);
    
    float newLeft = x+15;  
    for(int l = 0; l < letters.length; l++) {
      String thisLetter = letters[l];
      float letterWidth = textWidth(thisLetter) + kern;
      text(thisLetter, newLeft, y+cellHeight/2);
      newLeft += letterWidth;
    }
  }

  boolean isDead() {
    if (decay < 0) { 
      //println("DIE!!!: " + index + "\tDECAY: " + decay);
      isBlob = false;
      decay = dRate;
      return true;
    }
    else
      return false;
  }
}

