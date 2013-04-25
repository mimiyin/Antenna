int red = 0;
int green = 0;
int blue = 0;

int leftMargin;
int colorLoaded = 0;

Color [] colors;

void setup() {
  size(400, 400);

  String [] colorStrings = loadStrings("colors.txt");
  colors = new Color [colorStrings.length];

  for (int i = 0; i < colorStrings.length; i++) {
    String [] rgb = colorStrings[i].split(","); 
    colors[i] = new Color(int(rgb[0]), int(rgb[1]), int(rgb[2]));
  }

  textAlign(LEFT);
  smooth();
  
  leftMargin = width/2 - 120;
}

void draw() {

  fill(red, green, blue);
  rect(0, 0, width, height);
  fill(255);
  textSize(48);
  text("LOADED: " + colorLoaded, leftMargin, height/2 - 100);
  text("(e-r)R: " + red, leftMargin, height/2);
  text("(f-g)G: " + green, leftMargin, height/2 + 50);
  text("(v-b)B: " + blue, leftMargin, height/2 + 100);
}


void keyPressed() {
  switch(key) {

  case 'r':
    red++;
    break;
  case 'e':
    red--;
    break;
  case 'g':
    green++;
    break;
  case 'f':
    green--;
    break;
  case 'b':
    blue++;
    break;
  case 'v':
    blue--;
    break;
  }
  
  red = constrain(red, 0, 255);
  green = constrain(green, 0, 255);
  blue = constrain(blue, 0, 255);

  for (int i = 0; i < colors.length; i++) {
    int colorIndex = i+1;
    if (key == Character.forDigit(colorIndex, 10)) {
      colorLoaded = colorIndex;
      colors[i].loadColor();
    }
  }
}

