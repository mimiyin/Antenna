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
    track();
    display();
  }

  void track() {
    int y, x;
    for (int row = 0; row < rows; row++) {
      y = row*cellHeight;
      for (int col = 0; col < cols; col++) {
        x = col*cellWidth;
        int index = (row*cols)+col;
        
        if(isBlobbing) {
          float bVideo = analyze(video.getCell(x, y, true));
          blob(index, x, y, bVideo);
        }
        else if(isMoving) {
          float diff = diff(video.getCell(x, y, true), video.getCell(x, y, false));
          //println("DIFF: " + diff);
  
          if (frameCount > 5 && diff > 5000) {
            after.add(images[index]);
          }
        }
      }
    }
  }

  void display() {
    println("SIZE: " + after.size());
    //    Iterator it = after.iterator();
    //    while(it.hasNext()) {
    //      Image thisImage = (Image) it.next();
    //      println("DECAY: " + thisImage.decay());
    //      thisImage.display();
    //      if (thisImage.isDead()) {
    //        println("DIE!");
    //        after.remove(thisImage);
    //      } 
    //    }
    for (int i = after.size()-1; i > 0; i--) {
      Image thisImage = after.get(i);
      //println("DECAY: " + thisImage.decay());
      thisImage.decay();
      thisImage.display();
      if (thisImage.isDead()) {
        println("DIE!");
        after.remove(i);
      }
    }
  }

  void blob(int index, int x, int y, float b) {
    if (b < 50) {
      image(images[index].img, x, y, cellWidth, cellHeight);
    }
  }
}

