import java.net.URLEncoder;
import java.util.*;
import processing.video.*;

// Camera object
Capture capture;

// Our video object
Video video;

// Textground object
Textground tg;

int cols, rows;
int cellWidth, cellHeight;

boolean isGhosting = false;
boolean isBlobbing = false;
boolean isMoving = false;
boolean isFading = false;
boolean isUnison = true;

// Rate of change for cycling through words
float speed = 1;

// Font-size
float fSize = 48;

PFont font;

// Feedback counter
float fCounter;

// Decay rate
float dRate = 255;


String [] colorStrings;
Color [] colors;

void setup() {
  size(1920, 1080);
  
  colorStrings = loadStrings("colors.txt");
  colors = new Color [colorStrings.length];


  for (int i = 0; i < colorStrings.length; i++) {
    String [] rgb = colorStrings[i].split(","); 
    colors[i] = new Color(int(rgb[0]), int(rgb[1]), int(rgb[2]));
  }

  cellWidth = 320;
  cellHeight = 67;

  cols = int(width/cellWidth);
  rows = int(height/cellHeight);
  video = new Video(this);

  tg = new Textground();

  font = loadFont("Helvetica-Bold-48.vlw");

  smooth();
}

void draw() {
  //println(frameRate);
  video.run();
  tg.run();

  if (fCounter > 0)
    feedback();
}

void feedback() {
  String [] messages = {
    "blob: " + isBlobbing, 
    "move: " + isMoving, 
    "fade: " + isFading, 
    "unison: " + isUnison, 
    "decay: " + dRate,
  };

  noStroke();
  fill(255, 200, 200, fCounter);
  rect(0, 0, 150, messages.length*25);

  for (int m = 0; m < messages.length; m++) { 
    fill(255, fCounter);    
    textSize(17);  
    text(messages[m], 20, (m*20 + 20));
  }

  fCounter -= .25;
}

void keyPressed() {
  fCounter = 255;
  if (key == CODED) {

    switch(keyCode) {
    case UP:
      speed -= .1;
      break;
    case DOWN:
      speed += .1;
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
    case 'f':
      isFading = !isFading;
      break;
    case 'u':
      isUnison = !isUnison;
      break;
    }
  }
}

