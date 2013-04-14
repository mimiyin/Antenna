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
boolean isUnison = false;

// Rate of change for cycling through words
float speed = 1;

// Font-size
float fSize = 36;

PFont font;

// Feedback counter
float fCounter;



void setup() {
  size(1280, 720);
  cols = int(width/210);
  rows = int(height/45);
  video = new Video(this);

  cellWidth = (int) width/cols;
  cellHeight = (int) height/rows;

  tg = new Textground();

  font = loadFont("Helvetica-Bold-48.vlw");

  colorMode(HSB, 255);
  
  smooth();
}

void draw() {
  println(frameRate);
  video.run();
  tg.run();
  
  if(fCounter > 0)
    feedback();
}

void feedback() {
  fill(255, 200, 200, fCounter);
  rect(0, 0, 150, 100);
  String [] messages = {
    "blob: " + isBlobbing, 
    "move: " + isMoving, 
    "fade: " + isFading, 
    "unison: " + isUnison,
  };
  
  for (int m = 0; m < messages.length; m++) { 
    fill(255, fCounter);    
    textSize(17);  
    text(messages[m], 20, (m*20 + 20));
  }  
}

void keyPressed() {
  fCounter = 255;

  switch(key) {
  case 'b':  
    isBlobbing = !isBlobbing; 
    if (isBlobbing)
      isMoving = false;
    break;
  case 'm':
    isMoving = !isMoving;
    break;
  case 'f':
    isFading = !isFading;
    break;
  case 'u':
    isUnison = !isUnison;
    break;
  }

  if (key == CODED) {

    switch(keyCode) {
    case UP:
      speed -= .1;
      break;
    case DOWN:
      speed += .1;
      break;
    case RIGHT:
      fSize += 1;
      break;
    case LEFT:
      fSize -= 1;
      break;
    }
  }
}

