import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.net.URLEncoder; 
import java.util.*; 
import java.awt.Toolkit; 
import java.awt.event.KeyEvent; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TextMirror extends PApplet {






//Key event utils
Toolkit t = Toolkit.getDefaultToolkit();
public boolean isCapsLocked() {
  return t.getLockingKeyState(KeyEvent.VK_CAPS_LOCK);
}




// Camera object
Capture capture;

// Our video object
Video video;

// Textground object
Textscape ts;

// Total number of cells
int numCells;
int cols = 6;
int rows = 16;
int cellWidth, cellHeight;


// Effects
boolean isMoving = true;


// Rate of change for cycling through words
int speed = 1;

// Font-size
float fSize = 56;

// Decay rate
float dRate = 15;

// Kerning
int kern = -1;

// Static Grey
int grey = 160;

// Ripple Boundaries
int rMin = 72;
int rMax = 120;

// Font
PFont font;

// Color palette
String [] colorStrings;
Color [] colors;

// Feedback counter
float fCounter;


public void setup() {
  size(1920, 1080);
  //size(1280, 720);
  
  

  // Load color palette
  colorStrings = loadStrings("colorsAnt.txt");
  colors = new Color [colorStrings.length];

  for (int i = 0; i < colorStrings.length; i++) {
    String [] rgb = colorStrings[i].split(","); 
    colors[i] = new Color(PApplet.parseInt(rgb[0]), PApplet.parseInt(rgb[1]), PApplet.parseInt(rgb[2]));
  }

  // Init cell calculations
  initCells();

  video = new Video(this);

  // Load font
  font = loadFont("Helvetica-Bold-48.vlw");
  smooth();
}


public void initCells() {
  cols = constrain(cols, 1, 100);
  rows = constrain(rows, 1, 100);

  numCells = cols*rows;
  cellWidth = PApplet.parseInt(width/cols);
  cellHeight = PApplet.parseInt(height/rows);

  // Create textscape
  ts = new Textscape();
}

public void draw() {
  background(255);
  //println(frameRate);
  video.run();
  ts.run();

  if (fCounter > 0)
    feedback();
}

public void feedback() {
  String [] messages = {
    "(m)ove: " + isMoving, 
    "(u-d)speed: " + 100/speed, 
    "(l-r)decay: " + dRate, 
    "([-])font: " + fSize, 
    "(j-k)kern: " + kern, 
    "(f-g)grey: " + grey,
    "(e-r)rMax: " + rMax,
    "(q-w)rMin: " + rMin,

    " ", 
    "CAPS LOCK:", 
    "(l-r)cols: " + cols, 
    "(u-d)rows: " + rows,
  };

  noStroke();
  fill(255, 200, 200, fCounter);
  rect(0, 0, 180, messages.length*22);

  for (int m = 0; m < messages.length; m++) { 
    fill(255, fCounter);    
    textSize(17);  
    text(messages[m], 20, (m*20 + 20));
  }

  fCounter -=.25f;
}

public void keyPressed() {
  fCounter = 255;

  if (isCapsLocked()) {
    switch(keyCode) {
    case UP:
      rows++;
      break;
    case DOWN:
      rows--;
      break;
    case RIGHT:
      cols++;
      break;
    case LEFT:
      cols--;
      break;
    }
    initCells();
  }
  else if (key == CODED) {
    switch(keyCode) {
    case UP:
      speed --;
      speed = constrain(speed, 1, 1000);
      break;
    case DOWN:
      speed ++;
      speed = constrain(speed, 1, 1000);
      break;
    case RIGHT:
      dRate += 1;
      break;
    case LEFT:
      dRate -= 1;
      break;
    }
  }
  else {
    switch(key) {
    case 'm':
      isMoving = !isMoving;
      break;
    case ']':
      fSize++;
      break;
    case '[':
      fSize--;
      break;
    case 'k':
      kern++;
      break;
    case 'j':
      kern--;
      break;
    case 'r':
      rMax++;
      break;
    case 'e':
      rMax--;
      break;
    case 'w':
      rMin++;
      break;
    case 'q':
      rMin--;
      break;
    case 'g':
      grey++;
      break;
    case 'f':
      grey--;
      break;
    }
    
    grey = constrain(grey, 0, 255);
  }
}

class Color {
  float r, g, b;

  Color(float _r, float _b, float _g) {
    r = _r;
    g = _g;
    b = _b;
  }

  public float[] getColor() {
    float [] colors = { r, g, b };
    return colors;
  }
}

class Textscape {
  ArrayList<Word> words = new ArrayList<Word>();
  ArrayList<Integer>after = new ArrayList<Integer>();
  ArrayList<Integer>ripple = new ArrayList<Integer>();
  String [] text = new String [40];

  Textscape() {
    text = loadStrings("words.txt");
    loadWords();
  }


  public void run() {
    if (frameCount%PApplet.parseInt(random(rMin, rMax)) == 0)
      ripple();
    track();
    display();
  }

  public void loadWords() {
    for (int w = 0; w < numCells; w++) {
      int wIndex = PApplet.parseInt(w%text.length);
      String word = text[wIndex];
      words.add(new Word(w, word, false));
    }
  }

  public void track() {
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
  public void ripple() {
    int randomIndex = PApplet.parseInt(random(words.size()));
    ripple.add(randomIndex);
    Word thisWord = words.get(randomIndex);
    thisWord.decay = dRate*2;
  }

  public void display() {

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
        if (frameCount%PApplet.parseInt(random(10, 20)*speed) == 0) {
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
        if (frameCount%PApplet.parseInt(random(5, 20)*speed) == 0) {
          randomizeWord(thisWord);
        }
        thisWord.display();
      }
    }
  }

  // Change the color
  // Change the words
  // Turn on blobbing
  public void randomizeWord(Word word) {
    word.randomizeColor();
    word.update(text[PApplet.parseInt(random(text.length-1))]);
    word.isBlob = true;
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
  float scaleX = .08f;
  float scaleY = .11f;

  PApplet parent;


  Video(PApplet p) {
    parent = p;
    Capture.list();
    capture = new Capture(parent, 160, 120, 30);
    capture.start();

    // Create an empty image the same size as the video
    prevFrame = createImage(capture.width, capture.height, RGB);
  }

  public void run() {
    load();
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

  public PImage getCell(int x, int y, boolean isCurrent) {
    if(isCurrent)
      return capture.get(PApplet.parseInt(scaleX*width-(scaleX*(x+cellWidth))), PApplet.parseInt(scaleY*y), PApplet.parseInt(scaleX*cellWidth), PApplet.parseInt(scaleY*cellHeight));
    else
      return prevFrame.get(PApplet.parseInt(scaleX*width-(scaleX*(x+cellWidth))), PApplet.parseInt(scaleY*y), PApplet.parseInt(scaleX*cellWidth), PApplet.parseInt(scaleY*cellHeight));
  }
}

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

    x = PApplet.parseInt(index%cols)*cellWidth;
    y = PApplet.parseInt(index/cols)*cellHeight;

    decay = dRate;
  }

  // When the frameRate is high, image decays too quickly
  public void decay() {
    decay--;
  }

  public void update(String _word) {
    word = _word;
    characterize();
  }
  
  public void characterize() {
     letters = word.split(""); 
  }

  public void randomizeColor() {
    randomColor = colors[PApplet.parseInt(random(colors.length))].getColor();
  }

  public void display() {
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

  public boolean isDead() {
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
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "TextMirror" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
