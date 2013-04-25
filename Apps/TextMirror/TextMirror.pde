import java.net.URLEncoder;
import java.util.*;
import java.awt.Toolkit;
import java.awt.event.KeyEvent;

//Key event utils
Toolkit t = Toolkit.getDefaultToolkit();
boolean isCapsLocked() {
  return t.getLockingKeyState(KeyEvent.VK_CAPS_LOCK);
}


import processing.video.*;

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
boolean isBlobbing = false;
boolean isMoving = true;
boolean isFading = false;
boolean isUnison = true;


// Rate of change for cycling through words
int speed = 1;

// Font-size
float fSize = 56;

// Decay rate
float dRate = 3;

// Kerning
int kern = -1;

// Static Grey
int grey = 127;

// Ripple Boundaries
int rMin = 120;
int rMax = 600;

// Font
PFont font;

// Color palette
String [] colorStrings;
Color [] colors;

// Feedback counter
float fCounter;


void setup() {
  size(1920, 1080);
  //size(1280, 720);

  // Load color palette
  colorStrings = loadStrings("colors.txt");
  colors = new Color [colorStrings.length];

  for (int i = 0; i < colorStrings.length; i++) {
    String [] rgb = colorStrings[i].split(","); 
    colors[i] = new Color(int(rgb[0]), int(rgb[1]), int(rgb[2]));
  }

  // Init cell calculations
  initCells();

  video = new Video(this);

  // Load font
  font = loadFont("Helvetica-Bold-48.vlw");
  smooth();
}


void initCells() {
  cols = constrain(cols, 1, 100);
  rows = constrain(rows, 1, 100);

  numCells = cols*rows;
  cellWidth = int(width/cols);
  cellHeight = int(height/rows);

  // Create textscape
  ts = new Textscape();
}

void draw() {
  background(255);
  //println(frameRate);
  video.run();
  ts.run();

  if (fCounter > 0)
    feedback();
}

void feedback() {
  String [] messages = {
    "(b)lob: " + isBlobbing, 
    "(m)ove: " + isMoving, 
    "(u-d)speed: " + 1000/speed, 
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

  fCounter -=.25;
}

void keyPressed() {
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
      speed = constrain(speed, 1, 100);
      break;
    case DOWN:
      speed ++;
      speed = constrain(speed, 1, 100);
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
    case 'b':  
      isBlobbing = !isBlobbing; 
      if (isBlobbing)
        isMoving = false;
      break;
    case 'm':
      isMoving = !isMoving;
      if (isMoving)
        isBlobbing = false;
      break;
    case 'a':
      isFading = !isFading;
      break;
    case 'u':
      isUnison = !isUnison;
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

