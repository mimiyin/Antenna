class Foreground {
  Image [] images = new Image[cols*rows];
  ArrayList<Image>after = new ArrayList<Image>();


  Foreground() {
    for (int i = 0; i < images.length; i++) {
      int imgI = i%11;
      images[i] = new Image(i, loadImage("c" + imgI + ".jpg"));
    }
  }

  // Create abstract images from video footage
  void run() {
    detect();
    display();
  }

  void detect() {
    int y, x;
    for (int row = 0; row < rows; row++) {
      y = row*cellHeight;
      for (int col = 0; col < cols; col++) {
        x = col*cellWidth;

        float diff = diff(video.get(x, y, true), video.get(x, y, false));

        println("DIFF: " + diff);
        //mirror(x, y, bVideo);

        int index = (row*cols)+col;
        if (frameCount > 5 && diff > 2500 && after.size() < 20) {
          after.add(images[index]);
        }
      }
    }
  }

  void display() {
    for (int i = after.size()-1; i > 0; i--) {
      Image thisImage = after.get(i);
      thisImage.decay();
      thisImage.display();
      if (thisImage.isDead()) {
        println("DIE!");
        after.remove(i);
      }
    }
  }

  void mirror(int x, int y, float b) {
    fill(b, 127);
    noStroke();
    rect(x, y, cellWidth, cellHeight);
  }
}

