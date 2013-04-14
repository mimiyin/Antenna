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
float fSize = 36;

PFont font;




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
}

void draw() {
  println(frameRate);
  video.run();
  tg.run();
}

void keyPressed() {
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

