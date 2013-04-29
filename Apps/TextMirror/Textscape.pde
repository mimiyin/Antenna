class Textscape {
  ArrayList<Word> words = new ArrayList<Word>();
  ArrayList<Integer>after = new ArrayList<Integer>();
  ArrayList<Integer>ripple = new ArrayList<Integer>();
  String [] text = new String [40];

  Textscape() {
    text = loadStrings("words.txt");
    loadWords();
  }


  void run() {
    if (frameCount%int(random(rMin, rMax)) == 0)
      ripple();
    track();
    display();
  }

  void loadWords() {
    for (int w = 0; w < numCells; w++) {
      int wIndex = int(w%text.length);
      String word = text[wIndex];
      words.add(new Word(w, word, false));
    }
  }

  void track() {
    int y, x;
    int interval = speed; 

    for (int row = 0; row < rows; row++) {
      y = row*cellHeight;
      for (int col = 0; col < cols; col++) {
        x = col*cellWidth;
        int index = (row*cols)+col;
        float bVideo = analyze(video.getCell(x, y, true));
        Word thisWord = words.get(index);

        // Choose random interval for this cell
        if (!isUnison)
          interval = int(random(5, 20)*speed);

        if (isBlobbing)
          blob(index, x, y, bVideo, interval);



        if (isMoving) {
          float diff = diff(video.getCell(x, y, true), video.getCell(x, y, false));
          //println("DIFF: " + diff);

          if (frameCount > 5 && diff > 5000) {
            after.add(index);
            thisWord.isBlob = true;
          }
        }
        thisWord.display();
      }
    }
  }

  void ripple() {
    int randomIndex = int(random(words.size()));
    ripple.add(randomIndex);
    for (int i = ripple.size()-1; i >= 0; i--) {
      int thisIndex = ripple.get(i);
      Word thisWord = words.get(thisIndex);
      //println("DECAY: " + thisWord.decay());
      thisWord.decay();
      if (thisWord.isDead()) {
        ripple.remove(i);
      }
      else {
        //println("MOVING: " + thisIndex);
        if (frameCount%int(sin(i*.1)*10 + 11) == 0) {
          thisWord.update(text[int(random(text.length-1))]);
        }
        thisWord.display();
      }
    }
  }

  void blob(int index, int x, int y, float b, int interval) {
    Word thisWord = words.get(index);
    if (b < 50 ) {
      thisWord.isBlob = true;
      if (isFading)
        thisWord.decay();

      if (frameCount%interval == 0) {
        thisWord.randomizeColor();
        thisWord.update(text[int(random(text.length-1))]);
      }
    }
    else {
      thisWord.isBlob = false;
      thisWord.recay();
    }
  }

  void display() {
    for (int i = after.size()-1; i >= 0; i--) {
      int thisIndex = (int) after.get(i);
      Word thisWord = words.get(thisIndex);
      //println("DECAY: " + thisWord.decay());
      thisWord.decay();
      if (thisWord.isDead()) {
        after.remove(i);
      }
      else {
        println(thisIndex + " is ALIVE!!!");
        //println("MOVING: " + thisIndex);
        if (frameCount%int(sin(i*.1)*10 + 11) == 0) {
          thisWord.randomizeColor();
          thisWord.update(text[int(random(text.length-1))]);
          thisWord.isBlob = true;
        }
        thisWord.display();
      }
    }
  }
}

