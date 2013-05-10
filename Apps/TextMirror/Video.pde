
class Video {


  // Capture object
  Capture capture;

  // Previous Frame
  PImage prevFrame;
  // How different must a pixel be to be a "motion" pixel
  float threshold = 50;
  // Video is 1/10th output of screen
  float scaleX = .1;
  float scaleY = .1;

  PApplet parent;


  Video(PApplet p) {
    parent = p;
    Capture.list();
    capture = new Capture(parent, int(width*scaleX), int(height*scaleY), 30);
    capture.start();

    // Create an empty image the same size as the video
    prevFrame = createImage(capture.width, capture.height, RGB);
  }

  void run() {
    load();
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

  PImage getCell(int x, int y, boolean isCurrent) {
    if(isCurrent)
      return capture.get(int(scaleX*width-(scaleX*(x+cellWidth))), int(scaleY*y), int(scaleX*cellWidth), int(scaleY*cellHeight));
    else
      return prevFrame.get(int(scaleX*width-(scaleX*(x+cellWidth))), int(scaleY*y), int(scaleX*cellWidth), int(scaleY*cellHeight));
  }
}

