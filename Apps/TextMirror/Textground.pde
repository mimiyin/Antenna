class Textground {
  Word [] words = new Word[cols*rows];
  ArrayList<Word>after = new ArrayList<Word>();
  String [] text = new String [40];

  Textground() {
    text = loadStrings("words.txt");
    for (int w = 0; w < words.length; w++) {
      int wIndex = int(w%text.length);
      String word = text[wIndex];
      words[w] = new Word(w, word, false);
    }
  }


  void run() {
    track();
    display();
  }

  void track() {
    int y, x;
    int interval = int(30*speed); 

    for (int row = 0; row < rows; row++) {
      y = row*cellHeight;
      for (int col = 0; col < cols; col++) {
        x = col*cellWidth;
        int index = (row*cols)+col;
        float bVideo = analyze(video.getCell(x, y, true));

        // Choose random interval for this cell
        if (!isUnison)
          interval = int(random(5, 20)*speed);

        if (isBlobbing)
          blob(index, x, y, bVideo, interval);

        if (isMoving) {
          float diff = diff(video.getCell(x, y, true), video.getCell(x, y, false));
          //println("DIFF: " + diff);

          if (frameCount > 5 && diff > 5000) {
            after.add(new Word(index, words[index].word, true));
          }
        }
        words[index].display();
      }
    }
  }

  void blob(int index, int x, int y, float b, int interval) {
    Word thisWord = words[index];
    if (b < 50 ) {
      thisWord.isBlob = true;
      if (isFading)
        thisWord.decay();

      interval = constrain(interval, 1, 300);

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
    for (int i = after.size()-1; i > 0; i--) {
      Word thisWord = after.get(i);
      //println("DECAY: " + thisWord.decay());
      thisWord.decay();
      if (frameCount%int(sin(i*.1)*10 + 11) == 0) {
        thisWord.randomizeColor();
        thisWord.update(text[int(random(text.length-1))]);
      }
      thisWord.display();
      if (thisWord.isDead()) {
        println("DIE!");
        after.remove(i);
      }
    }
  }
}

