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

int cols = 10;
int rows = 6;
int cellWidth;
int cellHeight;

boolean isGhosting = false;
boolean isBlobbing = false;
boolean isMoving = false;



void setup() {
  size(1280, 768);
  video = new Video(this);

  cellWidth = (int) width/cols;
  cellHeight = (int) height/rows;

  bg = new Background();
  fg = new Foreground();

  colorMode(HSB, 255);
}

void draw() {
  println(frameRate);
  //background(0);
  video.run();
  bg.run();
  fg.run();
  
  
}

void keyPressed() {
  switch(key) {
  case 'g':
    isGhosting = !isGhosting; 
    break;
  case 'b':  
    isBlobbing = !isBlobbing; 
     break;
  case 'm':
    isMoving = !isMoving;
     break;
  }
}

