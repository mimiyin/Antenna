import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.net.URLEncoder; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class myMosaic extends PApplet {




// Camera object
Capture capture;

// Our video object
Video video;

// Background object
Background bg;
// Foreground object
Foreground fg;

int cols = 10;
int rows = 10;
int cellWidth;
int cellHeight;



public void setup() {
  size(1280, 768);
  video = new Video(this);

  cellWidth = (int) width/cols;
  cellHeight = (int) height/rows;

  bg = new Background();
  fg = new Foreground();
  
  colorMode(HSB, 255);
}

public void draw() {
  println(frameRate);
  background(0);
  video.run();
  bg.run();
  fg.run();
}



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
  public void run() {
    display();
  }

  public void display() {
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

        //        mirror(x, y, bVideo);

        int index = (row*cols)+col;

        // Once in a while, transfer an index if it hasn't been transferred
        float rand = random(1);
        if ( rand > .99f && !transferred(index)) {
          transferred.add(index);
          current.set(index, new Image(index, next.get(index).img));
          //println("TRANSFERRING!!! " + index + "\t" + current.get(index).index);
        }
        Image thisImage = current.get(index); 
        //println("INDEX: " + index + "\t" + thisImage.getIndex()); 
        current.get(index).display();
      }
    }
  }

  public boolean transferred(int index) {
    for (Integer i : transferred) {
      if (index == i)
        return true;
    }

    return false;
  }

  public void mirror(int x, int y, float b) {
    fill(b);
    noStroke();
    rect(x, y, cellWidth, cellHeight);
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

  public void loadFromFlickr() {
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
  public void run() {
    detect();
    display();
  }

  public void detect() {
    int y, x;
    for (int row = 0; row < rows; row++) {
      y = row*cellHeight;
      for (int col = 0; col < cols; col++) {
        x = col*cellWidth;

        float diff = diff(video.get(x, y, true), video.get(x, y, false));

        //println("DIFF: " + diff);
        //mirror(x, y, bVideo);

        int index = (row*cols)+col;
        if (frameCount > 5 && diff > 2500) {
          after.add(images[index]);
        }
      }
    }
  }

  public void display() {
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

  public void mirror(int x, int y, float b) {
    fill(b, 127);
    noStroke();
    rect(x, y, cellWidth, cellHeight);
  }
}

class Image {
  float b;
  int index, x, y, decay;
  PImage img;

  Image(int _index, PImage _img) {
    index = _index;
    x = PApplet.parseInt(index%cols)*cellWidth;
    y = PApplet.parseInt(index/rows)*cellHeight;
    img = _img;
    b = analyze(img);
    decay = PApplet.parseInt(random(100, 2500));
    //println("Brightness: " + b);
  }

  public void decay() {
    decay--;
    //tint(255, decay);
  }  

  public void update(int _index) {
    index = _index;
    x = PApplet.parseInt(index%cols)*cellWidth;
    y = PApplet.parseInt(index/rows)*cellHeight;
  }

  public int getIndex() {
    return index;   
  }
  
  public void display() {
    image(img, x, y, cellWidth, cellHeight);
  }

  public float getBrightness() {
    return b;
  }

  public PImage getImage() {
    return img;
  }

  public boolean isDead() {
    if (decay < 0)
      return true; 
    else
      return false;
  }
}


class Video {


  // Capture object
  Capture capture;

  // Previous Frame
  PImage prevFrame;
  // How different must a pixel be to be a "motion" pixel
  float threshold = 50;
  // Video is 1/10th output of screen
  float scale = .1f;

  PApplet parent;


  Video(PApplet p) {
    parent = p;
    capture = new Capture(parent, PApplet.parseInt(width*scale), PApplet.parseInt(height*scale), 30);
    capture.start();

    // Create an empty image the same size as the video
    prevFrame = createImage(capture.width, capture.height, RGB);
  }

  public void run() {
    load();
    //track();
  }

  public void load() {

    // Capture video
    if (capture.available()) {
      // Save previous frame for motion detection!!
      prevFrame.copy(capture, 0, 0, capture.width, capture.height, 0, 0, capture.width, capture.height); // Before we read the new frame, we always save the previous frame for comparison!
      prevFrame.updatePixels();
      capture.read();
    }
  }

  public void track() {

    capture.loadPixels();
    prevFrame.loadPixels();

    // Begin loop to walk through every pixel
    for (int x = 0; x < capture.width; x ++ ) {
      for (int y = 0; y < capture.height; y ++ ) {

        int loc = x + y*capture.width;            // Step 1, what is the 1D pixel location
        int current = capture.pixels[loc];      // Step 2, what is the current color
        int previous = prevFrame.pixels[loc]; // Step 3, what is the previous color

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

  public PImage get(int x, int y, boolean isCurrent) {
    if(isCurrent)
      return capture.get(PApplet.parseInt(scale*width-(scale*(x+cellWidth))), PApplet.parseInt(scale*y), PApplet.parseInt(scale*cellWidth), PApplet.parseInt(scale*cellHeight));
    else
      return prevFrame.get(PApplet.parseInt(scale*width-(scale*(x+cellWidth))), PApplet.parseInt(scale*y), PApplet.parseInt(scale*cellWidth), PApplet.parseInt(scale*cellHeight));
  }
}


// Calculate average brightness of an image
// Accepts pixel 
public float analyze(PImage img) {
  float totalBrightness = 0;

  img.loadPixels();
  for (int p : img.pixels) {
    float b = brightness(p);
    totalBrightness += b;
  }
  return totalBrightness / img.pixels.length;
}

public float diff(PImage current, PImage prev) {
  current.loadPixels();
  prev.loadPixels();
  float diffRGB = 0;
  for (int i = 0; i < current.pixels.length; i++) {
    int currentRGB = current.pixels[i];
    int prevRGB = prev.pixels[i];
    float r1 = red(currentRGB); 
    float g1 = green(currentRGB); 
    float b1 = blue(currentRGB);
    float r2 = red(prevRGB); 
    float g2 = green(prevRGB); 
    float b2 = blue(prevRGB);
    diffRGB += dist(r1, g1, b1, r2, g2, b2);
  }
  return diffRGB;
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "myMosaic" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
