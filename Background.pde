class Background {
  // Whether to load local data or grab from google images
  boolean isLocal = true;
  String queryString = "vintage%20knoll";  
  Image [] images = new Image[cols*rows];
  ArrayList<Image> current = new ArrayList<Image>();
  ArrayList<Image> next = new ArrayList<Image>();
  ArrayList<Integer> transferred = new ArrayList<Integer>();


  Background() {
    if (isLocal) {
      
      for (int i = 0; i < images.length; i++) {
        int imgI = i%25;
        images[i] = new Image(i, loadImage(imgI + ".jpg"));
        current.add(new Image(i, loadImage(imgI + ".jpg")));
        next.add(new Image(i, loadImage(imgI + ".jpg")));
        transferred.add(i);
      }
    }
    else  
      loadFromFlickr();
  }

  // Create abstract images from video footage
  void run() {
    display();
  }

  void display() {
    int y, x;
    boolean isSnapshot = false;
    if (frameCount%300 == 0 && transferred.size() >= current.size()) {
      transferred.clear();
      isSnapshot = true;
    }
    for (int row = 0; row < rows; row++) {
      y = row*cellHeight;
      for (int col = 0; col < cols; col++) {
        x = col*cellWidth;

        float bVideo = analyze(video.get(x, y, true));

        // Take another snapshot if the next array is empty
        if (isSnapshot)
          takeSnapshot(col, row, x, y, bVideo);


        int index = (row*cols)+col;

        // Once in a while, transfer an index if it hasn't been transferred
        float rand = random(1);
        if ( rand > .99 && !transferred(index)) {
          transferred.add(index);
          current.set(index, new Image(index, next.get(index).img));
          //println("TRANSFERRING!!! " + index + "\t" + current.get(index).index);
        }
        //println("INDEX: " + index + "\t" + thisImage.getIndex()); 
        current.get(index).display();

        mirror(index, x, y, bVideo);

      }
    }
  }

  boolean transferred(int index) {
    for (Integer i : transferred) {
      if (index == i)
        return true;
    }

    return false;
  }

  void mirror(int index, int x, int y, float b) {
    fill(b, 127-b);
    noStroke();
    rect(x, y, cellWidth, cellHeight);
//    if(b<100)
//      image(fg.images[index].img, x, y, cellWidth, cellHeight);
  }

  public void takeSnapshot(int col, int row, int x, int y, float bVideo) {
    //println("SNAPSHOT!!! " + frameCount);

    float smallestDiff=255;
    Image theOne = images[0];

    // Load and analyze images
    for (Image i : images) {
      float bImage = i.getBrightness();
      float diff = abs(bVideo - bImage);
      if (diff < smallestDiff) {
        theOne = i;
        smallestDiff=diff;
      }
    }
    int index = (row*cols)+col;
    next.set(index, theOne);
    next.get(index).update(index);
  }

  void loadFromFlickr() {
    println("Getting images from Flickr...");
    String url = "http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3661e810a9fb745a76412ee098724510&text=" + queryString + "&format=rest";
    println(url);
    XML xml = loadXML(url);
    xml = xml.getChild("photos");
    XML[] photos = xml.getChildren();
    // Workaround for bug in XML library - every other child in XML tree is bogus
    for (int i=1; i < images.length*2+1; i+=2) {
      XML photo = photos[i];
      if (photo != null) {
        String imgURL = "http://farm" + photo.getInt("farm")
          + ".static.flickr.com/"
            + photo.getString("server") + "/"
            + photo.getString("id") + "_"
            + photo.getString("secret") + "_z.jpg";

        println(imgURL);
        int imageIndex = (int)((i-1)/2);
        println(imageIndex);
        images[imageIndex] = new Image(imageIndex, loadImage(imgURL));
        imageIndex++;
        println("downloading " + imageIndex + " of " + (int)images.length + " images...");
      }
    }
  }
}

