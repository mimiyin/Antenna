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

    for (int row = 0; row < rows; row++) {
      y = row*cellHeight;
      for (int col = 0; col < cols; col++) {
        x = col*cellWidth;
        int index = (row*cols)+col;
        float bVideo = analyze(video.getCell(x, y, true));
        Word thisWord = words.get(index);

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

  // Pick random word to flip in stillness
  void ripple() {
    int randomIndex = int(random(words.size()));
    ripple.add(randomIndex);
    Word thisWord = words.get(randomIndex);
    thisWord.decay = dRate*2;
  }

  void display() {

    // Display the ripple words
    for (int i = ripple.size()-1; i >= 0; i--) {
      int thisIndex = ripple.get(i);
      Word thisWord = words.get(thisIndex);
      //println("RIPPLING");
      //println("DECAY: " + thisWord.decay);
      thisWord.decay();
      if (thisWord.isDead()) {
        thisWord.isBlob = false;
        thisWord.decay = dRate;
        //println(thisWord.word + "\t" + thisWord.isBlob);
        ripple.remove(i);
      }
      else {
        if (frameCount%int(random(10, 20)*speed) == 0) {
          randomizeWord(thisWord);
        }
        thisWord.display();
      }
    }

    // Display the blobbed words
    for (int i = after.size()-1; i >= 0; i--) {
      int thisIndex = (int) after.get(i);
      Word thisWord = words.get(thisIndex);
      //println("DECAY: " + thisWord.decay());
      thisWord.decay();
      if (thisWord.isDead()) {
        after.remove(i);
      }
      else {
        //println(thisIndex + " is ALIVE!!!");
        //println("MOVING: " + thisIndex);
        if (frameCount%int(random(5, 20)*speed) == 0) {
          randomizeWord(thisWord);
        }
        thisWord.display();
      }
    }
  }

  // Change the color
  // Change the words
  // Turn on blobbing
  void randomizeWord(Word word) {
    word.randomizeColor();
    word.update(text[int(random(text.length-1))]);
    word.isBlob = true;
  }
}

