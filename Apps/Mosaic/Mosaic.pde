import java.net.URLEncoder;
import java.util.*;
import processing.video.*;

// Camera object
Capture capture;

// Our video object
Video video;

// Background object
Background bg;
// Foreground object
Foreground fg;

int cols;
int rows;
int cellWidth;
int cellHeight;

boolean isGhosting = false;
boolean isBlobbing = false;
boolean isMoving = false;

float fCounter = 0;
PFont font;

float dRate = 1;

void setup() {
  size(1920, 1080);
  video = new Video(this);

  cellWidth = 120;
  cellHeight = 120;

  cols = int(width/cellWidth);
  rows = int(height/cellHeight);

  bg = new Background();
  fg = new Foreground();

  font = loadFont("Helvetica-Bold-48.vlw");
  colorMode(HSB, 255);
}

void draw() {
  println(frameRate);
  video.run();
  bg.run();
  fg.run();
  if (fCounter > 0)
    feedback();
}

void feedback() {
  String [] messages = {
    "blob: " + isBlobbing, 
    "move: " + isMoving, 
    "ghost: " + isGhosting,
    "decay: " + dRate,
  };

  noStroke();
  fill(255, 200, 200, fCounter);
  rect(0, 0, 150, messages.length*25);

  for (int m = 0; m < messages.length; m++) { 
    fill(255, fCounter);    
    textFont(font); 
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
      dRate += 1;
      break;
    case DOWN:
      dRate -= 1;
      break;
    }
  }
  else {

    switch(key) {
    case 'g':
      isGhosting = !isGhosting; 
      break;
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
    }
  }
}

