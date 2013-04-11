
class Video {


  // Capture object
  Capture capture;

  // Previous Frame
  PImage prevFrame;
  // How different must a pixel be to be a "motion" pixel
  float threshold = 50;
  // Video is 1/10th output of screen
  float scale = .1;

  PApplet parent;


  Video(PApplet p) {
    parent = p;
    capture = new Capture(parent, int(width*scale), int(height*scale), 30);
    capture.start();

    // Create an empty image the same size as the video
    prevFrame = createImage(capture.width, capture.height, RGB);
  }

  void run() {
    load();
    //track();
  }

  void load() {

    // Capture video
    if (capture.available()) {
      // Save previous frame for motion detection!!
      prevFrame.copy(capture, 0, 0, capture.width, capture.height, 0, 0, capture.width, capture.height); // Before we read the new frame, we always save the previous frame for comparison!
      prevFrame.updatePixels();
      capture.read();
    }
  }

  void track() {

    capture.loadPixels();
    prevFrame.loadPixels();

    // Begin loop to walk through every pixel
    for (int x = 0; x < capture.width; x ++ ) {
      for (int y = 0; y < capture.height; y ++ ) {

        int loc = x + y*capture.width;            // Step 1, what is the 1D pixel location
        color current = capture.pixels[loc];      // Step 2, what is the current color
        color previous = prevFrame.pixels[loc]; // Step 3, what is the previous color

        // Step 4, compare colors (previous vs. current)
        float r1 = red(current); 
        float g1 = green(current); 
        float b1 = blue(current);
        float r2 = red(previous); 
        float g2 = green(previous); 
        float b2 = blue(previous);
        float diff = dist(r1, g1, b1, r2, g2, b2);

        // Step 5, How different are the colors?
        // If the color at that pixel has changed, then there is motion at that pixel.
        //        if (diff > threshold) { 
        //          // If motion, display black
        //          pixels[loc] = color(0);
        //        } 
        //        else {
        //          // If not, display white
        //          pixels[loc] = color(255);
        //        }
      }
    }
    //updatePixels();
  }

  PImage get(int x, int y, boolean isCurrent) {
    if(isCurrent)
      return capture.get(int(scale*width-(scale*(x+cellWidth))), int(scale*y), int(scale*cellWidth), int(scale*cellHeight));
    else
      return prevFrame.get(int(scale*width-(scale*(x+cellWidth))), int(scale*y), int(scale*cellWidth), int(scale*cellHeight));
  }
}

