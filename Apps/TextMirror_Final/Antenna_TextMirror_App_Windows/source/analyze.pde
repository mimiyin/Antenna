
// Calculate average brightness of an image
// Accepts pixel 
float analyze(PImage img) {
  float totalBrightness = 0;

  img.loadPixels();
  for (int p : img.pixels) {
    float b = brightness(p);
    totalBrightness += b;
  }
  return totalBrightness / img.pixels.length;
}

float diff(PImage current, PImage prev) {
  current.loadPixels();
  prev.loadPixels();
  float diffRGB = 0;

  for (int i = 0; i < current.pixels.length; i++) {
    color currentRGB = current.pixels[i];
    color prevRGB = prev.pixels[i];
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

